-- 024_fix_materiales_rls.sql
-- Corrección de Políticas RLS para asegurar que el docente pueda gestionar TODO lo de su curso

-- Eliminar la política anterior estricta que requería coincidencia exacta de docente_id
DROP POLICY IF EXISTS "Docente gestiona sus materiales" ON materiales;

-- Crear nueva política más robusta: El docente puede gestionar los materiales si es el dueño del CURSO
CREATE POLICY "Docente gestiona sus materiales" ON materiales
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM cursos c
      WHERE c.id = materiales.curso_id AND c.docente_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM cursos c
      WHERE c.id = materiales.curso_id AND c.docente_id = auth.uid()
    )
  );

-- Nos aseguramos que si son directivos puedan gestionar (opcional pero seguro)
DROP POLICY IF EXISTS "Directivo gestiona todos los materiales" ON materiales;
CREATE POLICY "Directivo gestiona todos los materiales" ON materiales
  FOR ALL USING (public.get_user_role(auth.uid()) = 'directivo');
