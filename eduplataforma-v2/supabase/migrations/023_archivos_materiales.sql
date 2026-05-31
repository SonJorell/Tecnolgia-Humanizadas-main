-- 023_archivos_materiales.sql
-- Agregar capacidad de almacenar archivos adjuntos en materiales

ALTER TABLE materiales ADD COLUMN IF NOT EXISTS archivos JSONB DEFAULT '[]'::jsonb;
ALTER TABLE materiales DROP CONSTRAINT IF EXISTS materiales_tipo_check;

-- Permitir eliminar materiales que ya tienen entregas (Cascade Delete)
ALTER TABLE entregas DROP CONSTRAINT IF EXISTS entregas_material_id_fkey;
ALTER TABLE entregas ADD CONSTRAINT entregas_material_id_fkey FOREIGN KEY (material_id) REFERENCES materiales(id) ON DELETE CASCADE;
