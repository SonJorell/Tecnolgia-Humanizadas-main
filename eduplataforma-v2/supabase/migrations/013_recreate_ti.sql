-- ═══════════════════════════════════
-- 013_recreate_ti.sql
-- EduPlataforma v2.0
-- Recrear el usuario TI de forma segura
-- ═══════════════════════════════════

DO $$
DECLARE
  v_old_ti_id UUID := 'f0000000-0000-0000-0000-000000000001'::UUID;
  v_new_ti_id UUID := gen_random_uuid();
BEGIN
  -- 1. Eliminar el usuario antiguo de forma limpia (CASCADE eliminará el perfil)
  DELETE FROM auth.users WHERE email = 'ti@escuela.cl' OR id = v_old_ti_id;
  
  -- 2. Insertar el usuario TI con un UUID válido y estándar
  INSERT INTO auth.users (
    id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
  ) VALUES (
    v_new_ti_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ti@escuela.cl', 
    crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, 
    '{"provider":"email","providers":["email"]}', '{"email_verified":true}', false
  );

  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
  VALUES (
    v_new_ti_id, v_new_ti_id, 
    json_build_object('sub', v_new_ti_id, 'email', 'ti@escuela.cl', 'email_verified', true), 
    'email', v_new_ti_id, current_timestamp, current_timestamp, current_timestamp
  );

  INSERT INTO public.perfiles (id, nombre, rol, xp, monedas, nivel)
  VALUES (v_new_ti_id, 'Administrador TI', 'ti', 0, 0, 1);
  
END $$;
