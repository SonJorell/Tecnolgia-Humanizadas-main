-- ═══════════════════════════════════
-- 010_mejoras_fase3.sql
-- EduPlataforma v2.0
-- Módulo TI, Mensajería, Mejoras RLS y Canjes
-- ═══════════════════════════════════
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. ACTUALIZAR ROL EN PERFILES PARA PERMITIR 'ti'
ALTER TABLE perfiles DROP CONSTRAINT IF EXISTS perfiles_rol_check;
ALTER TABLE perfiles ADD CONSTRAINT perfiles_rol_check CHECK (rol IN ('alumno','docente','directivo','ti'));

-- 2. INSERTAR USUARIO TI DE PRUEBA
DO $$
DECLARE
  v_ti_id UUID := 'f0000000-0000-0000-0000-000000000001'::UUID;
BEGIN
  INSERT INTO auth.users (
    id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
  ) VALUES (
    v_ti_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ti@escuela.cl', 
    crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
    '{"provider":"email","providers":["email"]}', '{}', false
  ) ON CONFLICT (id) DO UPDATE SET encrypted_password = crypt('prueba123', gen_salt('bf'));

  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
  VALUES (
    v_ti_id, v_ti_id, 
    json_build_object('sub', v_ti_id, 'email', 'ti@escuela.cl', 'email_verified', false), 
    'email', v_ti_id, current_timestamp, current_timestamp, current_timestamp
  ) ON CONFLICT (provider_id, provider) DO NOTHING;

  INSERT INTO public.perfiles (id, nombre, rol, xp, monedas, nivel)
  VALUES (v_ti_id, 'Administrador TI', 'ti', 0, 0, 1)
  ON CONFLICT (id) DO NOTHING;
END $$;

-- 3. MEJORAR RLS: Docente solo ve alumnos de sus propios cursos
DROP POLICY IF EXISTS "Docente ve alumnos" ON perfiles;

CREATE POLICY "Docente ve alumnos de sus cursos" ON perfiles
  FOR SELECT USING (
    rol = 'alumno' AND EXISTS (
      SELECT 1 FROM inscripciones i
      JOIN cursos c ON c.id = i.curso_id
      WHERE i.alumno_id = perfiles.id AND c.docente_id = auth.uid()
    )
  );

-- Permitir que un docente vea perfiles de otros docentes y directivos para colaboración
CREATE POLICY "Docente ve otros docentes" ON perfiles
  FOR SELECT USING (
    public.get_user_role(auth.uid()) = 'docente' AND (rol = 'docente' OR rol = 'directivo' OR rol = 'ti')
  );

-- 4. TABLA DE MENSAJES DEL CURSO (CHAT)
CREATE TABLE IF NOT EXISTS mensajes (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  curso_id    UUID REFERENCES cursos(id) ON DELETE CASCADE,
  autor_id    UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  contenido   TEXT NOT NULL,
  creado_en   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE mensajes ENABLE ROW LEVEL SECURITY;

-- Lectura de mensajes: Si es alumno inscrito, docente del curso, o directivo/ti
CREATE POLICY "Lectura de mensajes" ON mensajes
  FOR SELECT USING (
    (public.get_user_role(auth.uid()) = 'alumno' AND EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid()))
    OR
    (public.get_user_role(auth.uid()) = 'docente' AND EXISTS (SELECT 1 FROM cursos c WHERE c.id = mensajes.curso_id AND c.docente_id = auth.uid()))
    OR
    (public.get_user_role(auth.uid()) IN ('directivo', 'ti'))
  );

-- Inserción de mensajes
CREATE POLICY "Escritura de mensajes" ON mensajes
  FOR INSERT WITH CHECK (
    autor_id = auth.uid() AND (
      (public.get_user_role(auth.uid()) = 'alumno' AND EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid()))
      OR
      (public.get_user_role(auth.uid()) = 'docente' AND EXISTS (SELECT 1 FROM cursos c WHERE c.id = mensajes.curso_id AND c.docente_id = auth.uid()))
    )
  );

-- 5. POLÍTICAS RLS PARA ROL TI
CREATE POLICY "TI ve todo en perfiles" ON perfiles FOR SELECT USING (public.get_user_role(auth.uid()) = 'ti');
CREATE POLICY "TI gestiona feedback" ON feedback FOR ALL USING (public.get_user_role(auth.uid()) = 'ti');

-- 6. RPC: REALIZAR CANJE SEGURO
CREATE OR REPLACE FUNCTION realizar_canje(p_premio_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_alumno_id UUID := auth.uid();
  v_monedas_alumno INTEGER;
  v_costo INTEGER;
BEGIN
  -- Obtener monedas del alumno
  SELECT monedas INTO v_monedas_alumno FROM perfiles WHERE id = v_alumno_id;
  
  -- Obtener costo del premio
  SELECT precio_monedas INTO v_costo FROM premios WHERE id = p_premio_id AND activo = TRUE;
  
  IF v_costo IS NULL THEN
    RAISE EXCEPTION 'Premio no válido o inactivo';
  END IF;

  IF v_monedas_alumno < v_costo THEN
    RAISE EXCEPTION 'Monedas insuficientes';
  END IF;

  -- Descontar monedas
  UPDATE perfiles SET monedas = monedas - v_costo WHERE id = v_alumno_id;

  -- Registrar canje
  INSERT INTO canjes (alumno_id, premio_id, monedas_gastadas, estado)
  VALUES (v_alumno_id, p_premio_id, v_costo, 'pendiente');

  RETURN json_build_object('success', true, 'nuevo_saldo', v_monedas_alumno - v_costo);
END;
$$;

-- 7. RPC: EVALUAR FEEDBACK (Rol TI)
CREATE OR REPLACE FUNCTION evaluar_feedback(p_feedback_id UUID, p_estado BOOLEAN, p_monedas_premio INTEGER, p_xp_premio INTEGER)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_autor_id UUID;
  v_resuelto BOOLEAN;
BEGIN
  IF public.get_user_role(auth.uid()) != 'ti' THEN
    RAISE EXCEPTION 'No autorizado';
  END IF;

  SELECT autor_id, resuelto INTO v_autor_id, v_resuelto FROM feedback WHERE id = p_feedback_id;
  
  IF v_autor_id IS NULL THEN
    RAISE EXCEPTION 'Feedback no encontrado';
  END IF;

  IF v_resuelto THEN
    RAISE EXCEPTION 'Feedback ya evaluado';
  END IF;

  -- Actualizar estado
  UPDATE feedback SET resuelto = p_estado WHERE id = p_feedback_id;

  -- Otorgar premio si aplica
  IF p_monedas_premio > 0 OR p_xp_premio > 0 THEN
    UPDATE perfiles 
    SET monedas = monedas + p_monedas_premio, xp = xp + p_xp_premio 
    WHERE id = v_autor_id;
  END IF;
END;
$$;
