-- 019_fix_materiales.sql
-- Asegurar que los materiales existentes estén publicados para que los alumnos puedan verlos.

UPDATE materiales SET publicado = true WHERE publicado IS NULL OR publicado = false;
