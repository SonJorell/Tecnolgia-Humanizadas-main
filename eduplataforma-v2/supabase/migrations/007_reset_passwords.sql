-- ═══════════════════════════════════
-- 007_reset_passwords.sql
-- EduPlataforma v2.0
-- Resetea masivamente la contraseña de todos los usuarios
-- ═══════════════════════════════════
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Esta consulta forzará la contraseña "prueba123" para absolutamente 
-- todos los usuarios que existen actualmente en tu base de datos Supabase.
UPDATE auth.users
SET encrypted_password = crypt('prueba123', gen_salt('bf'));
