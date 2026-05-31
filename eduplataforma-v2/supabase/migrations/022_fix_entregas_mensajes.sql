-- 022_fix_entregas_mensajes.sql

-- 1. Añadir columnas a entregas que faltaban para el frontend
ALTER TABLE entregas ADD COLUMN IF NOT EXISTS archivos JSONB DEFAULT '[]'::jsonb;
ALTER TABLE entregas ADD COLUMN IF NOT EXISTS feedback_docente TEXT;

-- 2. Permitir que los alumnos creen conversaciones (iniciar chat con profesor)
DROP POLICY IF EXISTS "Docente crea conversaciones" ON conversaciones;
DROP POLICY IF EXISTS "Usuarios crean conversaciones" ON conversaciones;

CREATE POLICY "Usuarios crean conversaciones" ON conversaciones
  FOR INSERT WITH CHECK (
    -- Alumno puede crear chat individual con un docente
    (public.get_user_role(auth.uid()) = 'alumno' AND tipo = 'individual')
    OR
    -- Docente puede crear cualquier conversacion
    (public.get_user_role(auth.uid()) = 'docente')
  );

-- 3. Función RPC para otorgar recompensas a alumnos
CREATE OR REPLACE FUNCTION otorgar_recompensa(p_alumno_id UUID, p_xp INTEGER, p_monedas INTEGER, p_razon TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE perfiles
  SET xp = xp + p_xp,
      monedas = monedas + p_monedas
  WHERE id = p_alumno_id;
END;
$$;

-- 4. Añadir columna enlace a notificaciones y eliminar restricción de tipos que fallan por las nuevas notificaciones
ALTER TABLE notificaciones ADD COLUMN IF NOT EXISTS enlace TEXT;
ALTER TABLE notificaciones DROP CONSTRAINT IF EXISTS notificaciones_tipo_check;
