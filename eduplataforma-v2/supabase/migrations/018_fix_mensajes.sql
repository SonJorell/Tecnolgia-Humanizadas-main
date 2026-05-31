-- 018_fix_mensajes.sql
-- Fix missing curso_id in mensajes from previous migration

ALTER TABLE mensajes ADD COLUMN IF NOT EXISTS curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE;

DROP POLICY IF EXISTS "Lectura de mensajes" ON mensajes;
CREATE POLICY "Lectura de mensajes" ON mensajes
  FOR SELECT USING (
    (conversacion_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
        (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
        OR
        (c.tipo = 'curso' AND (
          EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = c.curso_id AND curso.docente_id = auth.uid()) OR
          EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = c.curso_id AND i.alumno_id = auth.uid())
        ))
      )
    ))
    OR
    (curso_id IS NOT NULL AND (
      EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = mensajes.curso_id AND curso.docente_id = auth.uid()) OR
      EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid())
    ))
  );

DROP POLICY IF EXISTS "Escritura de mensajes" ON mensajes;
CREATE POLICY "Escritura de mensajes" ON mensajes
  FOR INSERT WITH CHECK (
    autor_id = auth.uid() AND (
      (conversacion_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
          (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
          OR
          (c.tipo = 'curso' AND (
            EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = c.curso_id AND curso.docente_id = auth.uid()) OR
            EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = c.curso_id AND i.alumno_id = auth.uid())
          ))
        )
      ))
      OR
      (curso_id IS NOT NULL AND (
        EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = mensajes.curso_id AND curso.docente_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid())
      ))
    )
  );

DROP POLICY IF EXISTS "Actualizar mensajes" ON mensajes;
CREATE POLICY "Actualizar mensajes" ON mensajes
  FOR UPDATE USING (
    (conversacion_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
        (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
      )
    ))
    OR
    (curso_id IS NOT NULL AND (
      EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = mensajes.curso_id AND curso.docente_id = auth.uid()) OR
      EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid())
    ))
  );
