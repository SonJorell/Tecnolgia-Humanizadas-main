-- 025_archivos_entregas.sql
-- Agregar capacidad de almacenar archivos adjuntos en las entregas de tareas de los alumnos

ALTER TABLE entregas ADD COLUMN IF NOT EXISTS archivos JSONB DEFAULT '[]'::jsonb;
