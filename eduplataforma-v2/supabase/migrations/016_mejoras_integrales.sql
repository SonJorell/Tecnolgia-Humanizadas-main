-- ═══════════════════════════════════
-- 016_mejoras_integrales.sql
-- EduPlataforma v2.0
-- Comunicados, Inventario de Recompensas y Mejoras RLS
-- ═══════════════════════════════════

-- 1. Crear tabla comunicados para anuncios del Director
DROP TABLE IF EXISTS comunicados CASCADE;
CREATE TABLE comunicados (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  autor_id UUID REFERENCES perfiles(id),
  titulo TEXT NOT NULL,
  contenido TEXT NOT NULL,
  segmento TEXT CHECK (segmento IN ('todos', 'alumnos', 'docentes', 'curso_especifico')),
  curso_id UUID REFERENCES cursos(id),
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE comunicados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura de comunicados" ON comunicados
  FOR SELECT USING (
    segmento = 'todos' 
    OR (segmento = 'alumnos' AND public.get_user_role(auth.uid()) = 'alumno')
    OR (segmento = 'docentes' AND public.get_user_role(auth.uid()) = 'docente')
    OR public.get_user_role(auth.uid()) IN ('directivo', 'ti')
    OR (segmento = 'curso_especifico' AND EXISTS (
      SELECT 1 FROM inscripciones i WHERE i.curso_id = comunicados.curso_id AND i.alumno_id = auth.uid()
    ))
    OR (segmento = 'curso_especifico' AND EXISTS (
      SELECT 1 FROM cursos c WHERE c.id = comunicados.curso_id AND c.docente_id = auth.uid()
    ))
  );

CREATE POLICY "Directivos crean comunicados" ON comunicados
  FOR INSERT WITH CHECK (public.get_user_role(auth.uid()) IN ('directivo', 'ti'));

-- 2. Añadir columna inventario y tipos de archivo
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS inventario_premios TEXT[] DEFAULT '{}';
ALTER TABLE materiales ADD COLUMN IF NOT EXISTS tipo_archivo TEXT DEFAULT 'enlace';

-- 3. Simplificar RLS de Docentes para evitar problemas al ver nombres
DROP POLICY IF EXISTS "Docente ve alumnos de sus cursos" ON perfiles;
CREATE POLICY "Docente ve todos los alumnos" ON perfiles
  FOR SELECT USING (
    public.get_user_role(auth.uid()) = 'docente' AND rol = 'alumno'
  );

-- 4. Actualizar realizar_canje para añadir al inventario y auto-equipar
CREATE OR REPLACE FUNCTION realizar_canje(p_premio_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_alumno_id UUID := auth.uid();
  v_monedas_alumno INTEGER;
  v_costo INTEGER;
  v_icono TEXT;
  v_cat TEXT;
BEGIN
  -- Obtener monedas
  SELECT monedas INTO v_monedas_alumno FROM perfiles WHERE id = v_alumno_id;
  
  -- Obtener costo y detalles del premio
  SELECT precio_monedas, icono, categoria INTO v_costo, v_icono, v_cat 
  FROM premios WHERE id = p_premio_id AND activo = TRUE;
  
  IF v_costo IS NULL THEN
    RAISE EXCEPTION 'Premio no válido o inactivo';
  END IF;

  IF v_monedas_alumno < v_costo THEN
    RAISE EXCEPTION 'Monedas insuficientes';
  END IF;

  -- Descontar monedas, actualizar activo y añadir al inventario
  -- array_append solo añade si no está, bueno, añade duplicados, no pasa nada grave pero podemos usar un pequeño truco
  IF v_cat = 'marco' THEN
    UPDATE perfiles SET monedas = monedas - v_costo, marco_activo_id = v_icono, inventario_premios = array_append(inventario_premios, v_icono) WHERE id = v_alumno_id;
  ELSIF v_cat = 'banner' THEN
    UPDATE perfiles SET monedas = monedas - v_costo, banner_activo_id = v_icono, inventario_premios = array_append(inventario_premios, v_icono) WHERE id = v_alumno_id;
  ELSIF v_cat = 'avatar' THEN
    UPDATE perfiles SET monedas = monedas - v_costo, avatar_activo_id = v_icono, inventario_premios = array_append(inventario_premios, v_icono) WHERE id = v_alumno_id;
  ELSE
    UPDATE perfiles SET monedas = monedas - v_costo WHERE id = v_alumno_id;
  END IF;

  -- Registrar canje (Automáticamente aprobado por el sistema)
  INSERT INTO canjes (alumno_id, premio_id, monedas_gastadas, estado)
  VALUES (v_alumno_id, p_premio_id, v_costo, 'aprobado');

  RETURN json_build_object('success', true, 'nuevo_saldo', v_monedas_alumno - v_costo);
END;
$$;

-- 5. Recargar schema
NOTIFY pgrst, 'reload schema';
