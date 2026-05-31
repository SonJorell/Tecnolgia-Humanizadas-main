-- ═══════════════════════════════════
-- 004_add_missing.sql — EduPlataforma v2.0
-- ═══════════════════════════════════

-- Columnas faltantes en perfiles
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS telefono TEXT;
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS ultimo_login TIMESTAMPTZ;
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS marco_activo_id TEXT;

-- Tabla notificaciones
CREATE TABLE IF NOT EXISTS notificaciones (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id  UUID REFERENCES perfiles(id),
  titulo      TEXT NOT NULL,
  mensaje     TEXT NOT NULL,
  tipo        TEXT CHECK (tipo IN ('info', 'alerta', 'exito', 'error')) DEFAULT 'info',
  leida       BOOLEAN DEFAULT FALSE,
  creado_en   TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla comunicados
CREATE TABLE IF NOT EXISTS comunicados (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  autor_id    UUID REFERENCES perfiles(id),
  titulo      TEXT NOT NULL,
  contenido   TEXT NOT NULL,
  importante  BOOLEAN DEFAULT FALSE,
  para_roles  TEXT[] DEFAULT ARRAY['alumno', 'docente', 'directivo'],
  creado_en   TIMESTAMPTZ DEFAULT NOW(),
  expira_en   TIMESTAMPTZ
);
