-- 021_alumno_ve_docente.sql
-- Permite a los alumnos ver los perfiles de los docentes de sus cursos

CREATE POLICY "Alumno ve docentes de sus cursos" ON perfiles
  FOR SELECT USING (
    rol = 'docente' AND EXISTS (
      SELECT 1 FROM inscripciones i
      JOIN cursos c ON c.id = i.curso_id
      WHERE i.alumno_id = auth.uid() AND c.docente_id = perfiles.id
    )
  );

-- También permitimos de forma general que cualquier autenticado vea nombres de docentes para evitar errores 400
-- Ya que un perfil docente es público dentro de la escuela.
DROP POLICY IF EXISTS "Alumno ve docentes de sus cursos" ON perfiles;

CREATE POLICY "Todos ven docentes" ON perfiles
  FOR SELECT USING (rol = 'docente' OR rol = 'directivo');
