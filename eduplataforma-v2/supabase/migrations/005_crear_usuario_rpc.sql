-- ═══════════════════════════════════
-- 005_crear_usuario_rpc.sql
-- EduPlataforma v2.0
-- Función para crear usuarios sin cerrar la sesión del admin.
-- ═══════════════════════════════════
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION crear_usuario_admin(
    p_email TEXT,
    p_password TEXT,
    p_nombre TEXT,
    p_rol TEXT
) RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
    encrypted_pw TEXT;
BEGIN
    -- Validar rol
    IF p_rol NOT IN ('alumno', 'docente', 'directivo') THEN
        RAISE EXCEPTION 'Rol inválido. Debe ser alumno, docente o directivo.';
    END IF;

    -- Generar UUID y password encriptado
    new_user_id := gen_random_uuid();
    encrypted_pw := crypt(p_password, gen_salt('bf'));

    -- 1. Insertar en auth.users
    INSERT INTO auth.users (
        id, instance_id, role, aud, email, encrypted_password,
        email_confirmed_at, created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data, is_super_admin
    ) VALUES (
        new_user_id,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        p_email,
        encrypted_pw,
        now(),
        now(),
        now(),
        '{"provider":"email","providers":["email"]}',
        '{}',
        FALSE
    );

    -- 2. Insertar en auth.identities
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id,
        last_sign_in_at, created_at, updated_at
    ) VALUES (
        new_user_id,
        new_user_id,
        json_build_object('sub', new_user_id::text, 'email', p_email),
        'email',
        new_user_id::text,
        now(),
        now(),
        now()
    );

    -- 3. Insertar en public.perfiles
    INSERT INTO public.perfiles (
        id, nombre, rol, xp, monedas, nivel, email,
        creado_en, actualizado
    ) VALUES (
        new_user_id,
        p_nombre,
        p_rol,
        0, 0, 1,
        p_email,
        now(),
        now()
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
