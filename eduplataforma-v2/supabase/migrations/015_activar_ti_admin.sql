-- ═══════════════════════════════════
-- 015_activar_ti_admin.sql
-- EduPlataforma v2.0
-- Activar el nuevo usuario TI creado por API
-- ═══════════════════════════════════

DO $$
DECLARE
  v_ti_id UUID := '2eab86fd-5459-4af5-a6ea-77271319a41e'::UUID;
BEGIN
  -- 1. Confirmar el email en auth.users para que pueda hacer login
  UPDATE auth.users 
  SET email_confirmed_at = now(),
      raw_user_meta_data = jsonb_set(COALESCE(raw_user_meta_data, '{}'::jsonb), '{email_verified}', 'true')
  WHERE id = v_ti_id;

  -- 2. Confirmar en auth.identities
  UPDATE auth.identities
  SET identity_data = jsonb_set(COALESCE(identity_data, '{}'::jsonb), '{email_verified}', 'true')
  WHERE user_id = v_ti_id;

  -- 3. Crear su perfil público
  INSERT INTO public.perfiles (id, nombre, rol, xp, monedas, nivel)
  VALUES (v_ti_id, 'Administrador TI Principal', 'ti', 0, 0, 1)
  ON CONFLICT (id) DO UPDATE SET rol = 'ti';

  -- 4. Reparar el caché de la base de datos por última vez
  NOTIFY pgrst, 'reload schema';
END $$;
