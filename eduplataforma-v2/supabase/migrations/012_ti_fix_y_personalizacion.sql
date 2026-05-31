-- ═══════════════════════════════════
-- 012_ti_fix_y_personalizacion.sql
-- EduPlataforma v2.0
-- Fix RLS Circular, Nuevas Personalizaciones (Banners, Avatars)
-- ═══════════════════════════════════

-- 1. ROMPER DEPENDENCIA CIRCULAR RLS EN PERFILES
-- Usar una función PL/pgSQL para ocultar el JOIN a la tabla cursos
CREATE OR REPLACE FUNCTION public.is_docente_of_alumno(p_docente_id UUID, p_alumno_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM inscripciones i
    JOIN cursos c ON c.id = i.curso_id
    WHERE i.alumno_id = p_alumno_id AND c.docente_id = p_docente_id
  ) INTO v_exists;
  RETURN v_exists;
END;
$$;

-- 2. REEMPLAZAR LA POLÍTICA DE DOCENTE
DROP POLICY IF EXISTS "Docente ve alumnos de sus cursos" ON perfiles;

CREATE POLICY "Docente ve alumnos de sus cursos" ON perfiles
  FOR SELECT USING (
    rol = 'alumno' AND public.is_docente_of_alumno(auth.uid(), id)
  );

-- 3. AÑADIR COLUMNAS DE PERSONALIZACIÓN A PERFILES
ALTER TABLE perfiles 
  ADD COLUMN IF NOT EXISTS banner_activo_id TEXT,
  ADD COLUMN IF NOT EXISTS avatar_activo_id TEXT;

-- 4. INSERTAR NUEVOS PREMIOS EN LA TIENDA (BANNERS Y AVATARES)
DO $$
BEGIN
  -- Insertamos algunos banners épicos
  INSERT INTO premios (id, nombre, descripcion, categoria, icono, precio_monedas, stock, activo) VALUES
  (gen_random_uuid(), 'Banner Espacial', 'Un fondo estelar para tu perfil', 'banner', '/banners/space.jpg', 800, 999, true),
  (gen_random_uuid(), 'Banner Neón', 'Luces de neón cyberpunk', 'banner', '/banners/neon.jpg', 1500, 999, true),
  (gen_random_uuid(), 'Banner Bosque Mágico', 'Un bosque misterioso animado', 'banner', '/banners/forest.jpg', 2500, 999, true);

  -- Insertamos avatares premium
  INSERT INTO premios (id, nombre, descripcion, categoria, icono, precio_monedas, stock, activo) VALUES
  (gen_random_uuid(), 'Avatar Guerrero', 'Icono de guerrero épico', 'avatar', '🥷', 300, 999, true),
  (gen_random_uuid(), 'Avatar Robot', 'Icono de robot del futuro', 'avatar', '🤖', 500, 999, true),
  (gen_random_uuid(), 'Avatar Rey', 'Corona dorada de campeón', 'avatar', '👑', 2000, 999, true);
  
  -- Insertamos marcos (algunos adicionales)
  INSERT INTO premios (id, nombre, descripcion, categoria, icono, precio_monedas, stock, activo) VALUES
  (gen_random_uuid(), 'Marco Oro', 'Borde dorado brillante', 'marco', 'gold', 1000, 999, true),
  (gen_random_uuid(), 'Marco Diamante', 'Borde de diamante animado', 'marco', 'diamond', 3000, 999, true);
END $$;

-- 5. RECARGAR EL CACHÉ DEL SCHEMA (Esto arregla el error 500 Database error querying schema automáticamente)
NOTIFY pgrst, 'reload schema';
