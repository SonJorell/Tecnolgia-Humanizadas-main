-- Actualiza las claves de forma segura ignorando IDs conflictivos
UPDATE auth.users SET encrypted_password = crypt('prueba123', gen_salt('bf'));
