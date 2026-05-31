-- ═══════════════════════════════════
-- seed.sql — Datos de prueba (REALISTA)
-- EduPlataforma v2.0 | J2N Software
-- ═══════════════════════════════════

-- Usuarios creados en Supabase Auth:
-- alumnos (password: alumno123)
-- jorell@escuela.cl y otros
-- docentes (password: docente123)
-- profesor.mate@escuela.cl y otros
-- directivo (password: directivo123)
-- director@escuela.cl

-- ═══════════════════════════════════
-- LIMPIEZA DE DATOS ANTERIORES
-- ═══════════════════════════════════
DELETE FROM entregas;
DELETE FROM materiales;
DELETE FROM inscripciones;
DELETE FROM cursos;
DELETE FROM logros_alumno;
DELETE FROM logros;
DELETE FROM premios;
DELETE FROM notificaciones;
DELETE FROM comunicados;

-- ═══════════════════════════════════
-- AUTH USERS (Usuarios de autenticación obligatorios por FK)
-- ═══════════════════════════════════
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO auth.users (
  id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, 
  created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin
) VALUES 
  -- Directivos (prueba123)
  ('e2367fdf-782c-4a1a-ac8e-3cd48addac16', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'director@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('e0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'coordinador@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  
  -- Docentes (prueba123)
  ('3f9a494e-0b90-4f84-898b-66efae34413b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.mate@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('d0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.lenguaje@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('d0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.ciencias@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('d0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.historia@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('d0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.ingles@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('d0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'profesor.arte@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),

  -- Alumnos (prueba123)
  ('4fc32de6-da28-488b-a941-d64581482d0a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'jorell@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maria@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'pedro@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ana@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'diego@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sofia@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'valentina@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'martin@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'camila@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'benjamin@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'antonia@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'lucas@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'isabella@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mateo@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false),
  ('a0000000-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'emilia@escuela.cl', crypt('prueba123', gen_salt('bf')), current_timestamp, current_timestamp, current_timestamp, '{"provider":"email","providers":["email"]}', '{}', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
SELECT 
  id, id, json_build_object('sub', id::text, 'email', email), 'email', id, current_timestamp, current_timestamp, current_timestamp
FROM auth.users
WHERE id IN (
  'e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'e0000000-0000-0000-0000-000000000001',
  '3f9a494e-0b90-4f84-898b-66efae34413b', 'd0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000005',
  '4fc32de6-da28-488b-a941-d64581482d0a', 'a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000014'
)
ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════
-- PERFILES (vinculados a auth.users)
-- ═══════════════════════════════════
INSERT INTO perfiles (id, nombre, rol, xp, monedas, nivel, email, telefono, marco_activo_id) VALUES
  -- Directivos
  ('e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'Director Vásquez', 'directivo', 0, 0, 1, 'director@escuela.cl', '+56999887766', NULL),
  ('e0000000-0000-0000-0000-000000000001', 'Coordinadora Silva', 'directivo', 0, 0, 1, 'coordinador@escuela.cl', '+56988776655', NULL),

  -- Docentes (6 profesores)
  ('3f9a494e-0b90-4f84-898b-66efae34413b', 'Profesor García (Matemáticas)', 'docente', 0, 0, 1, 'profesor.mate@escuela.cl', '+56911223344', NULL),
  ('d0000000-0000-0000-0000-000000000001', 'Profesora Rojas (Lenguaje)', 'docente', 0, 0, 1, 'profesor.lenguaje@escuela.cl', '+56944444444', NULL),
  ('d0000000-0000-0000-0000-000000000002', 'Profesor Soto (Ciencias)', 'docente', 0, 0, 1, 'profesor.ciencias@escuela.cl', '+56955555555', NULL),
  ('d0000000-0000-0000-0000-000000000003', 'Profesora Castro (Historia)', 'docente', 0, 0, 1, 'profesor.historia@escuela.cl', '+56966666666', NULL),
  ('d0000000-0000-0000-0000-000000000004', 'Profesor Medina (Inglés)', 'docente', 0, 0, 1, 'profesor.ingles@escuela.cl', '+56977777777', NULL),
  ('d0000000-0000-0000-0000-000000000005', 'Profesora Vega (Arte)', 'docente', 0, 0, 1, 'profesor.arte@escuela.cl', '+56988888888', NULL),

  -- Alumnos (15 estudiantes con diferentes niveles de xp y monedas)
  ('4fc32de6-da28-488b-a941-d64581482d0a', 'Jorell Inostroza', 'alumno', 850, 125, 5, 'jorell@escuela.cl', '+56912345678', NULL),
  ('a0000000-0000-0000-0000-000000000001', 'María González', 'alumno', 1200, 350, 7, 'maria@escuela.cl', '+56910000001', NULL),
  ('a0000000-0000-0000-0000-000000000002', 'Pedro Silva', 'alumno', 450, 50, 3, 'pedro@escuela.cl', '+56910000002', NULL),
  ('a0000000-0000-0000-0000-000000000003', 'Ana Morales', 'alumno', 2100, 800, 10, 'ana@escuela.cl', '+56910000003', NULL),
  ('a0000000-0000-0000-0000-000000000004', 'Diego Campos', 'alumno', 320, 10, 2, 'diego@escuela.cl', '+56910000004', NULL),
  ('a0000000-0000-0000-0000-000000000005', 'Sofía Reyes', 'alumno', 1800, 420, 8, 'sofia@escuela.cl', '+56910000005', NULL),
  ('a0000000-0000-0000-0000-000000000006', 'Valentina Rojas', 'alumno', 2400, 950, 11, 'valentina@escuela.cl', '+56910000006', NULL),
  ('a0000000-0000-0000-0000-000000000007', 'Martín Flores', 'alumno', 600, 80, 4, 'martin@escuela.cl', '+56910000007', NULL),
  ('a0000000-0000-0000-0000-000000000008', 'Camila Valdés', 'alumno', 1500, 220, 6, 'camila@escuela.cl', '+56910000008', NULL),
  ('a0000000-0000-0000-0000-000000000009', 'Benjamín Toro', 'alumno', 100, 0, 1, 'benjamin@escuela.cl', '+56910000009', NULL),
  ('a0000000-0000-0000-0000-000000000010', 'Antonia Pizarro', 'alumno', 950, 150, 5, 'antonia@escuela.cl', '+56910000010', NULL),
  ('a0000000-0000-0000-0000-000000000011', 'Lucas Herrera', 'alumno', 720, 90, 4, 'lucas@escuela.cl', '+56910000011', NULL),
  ('a0000000-0000-0000-0000-000000000012', 'Isabella Castro', 'alumno', 1650, 310, 7, 'isabella@escuela.cl', '+56910000012', NULL),
  ('a0000000-0000-0000-0000-000000000013', 'Mateo Ramírez', 'alumno', 400, 20, 3, 'mateo@escuela.cl', '+56910000013', NULL),
  ('a0000000-0000-0000-0000-000000000014', 'Emilia Tapia', 'alumno', 1300, 260, 6, 'emilia@escuela.cl', '+56910000014', NULL)
ON CONFLICT (id) DO UPDATE SET 
  nombre = EXCLUDED.nombre, 
  rol = EXCLUDED.rol, 
  xp = EXCLUDED.xp, 
  monedas = EXCLUDED.monedas, 
  nivel = EXCLUDED.nivel, 
  email = EXCLUDED.email, 
  telefono = EXCLUDED.telefono;

-- ═══════════════════════════════════
-- CURSOS (8 Cursos)
-- ═══════════════════════════════════
INSERT INTO cursos (id, nombre, descripcion, nivel, icono, color, docente_id) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'Matemáticas Avanzadas', 'Álgebra y geometría analítica', '2do Medio A', '📐', '#1a6fa8', '3f9a494e-0b90-4f84-898b-66efae34413b'),
  ('c0000000-0000-0000-0000-000000000002', 'Lenguaje y Literatura', 'Comprensión lectora y redacción', '2do Medio A', '📖', '#6c5ce7', 'd0000000-0000-0000-0000-000000000001'),
  ('c0000000-0000-0000-0000-000000000003', 'Biología Celular', 'Biología y ecosistemas', '2do Medio A', '🔬', '#2db88a', 'd0000000-0000-0000-0000-000000000002'),
  ('c0000000-0000-0000-0000-000000000004', 'Historia Contemporánea', 'Chile y el mundo en el siglo XX', '2do Medio A', '🌍', '#e8a020', 'd0000000-0000-0000-0000-000000000003'),
  
  ('c0000000-0000-0000-0000-000000000005', 'Inglés Básico', 'Gramática y vocabulario', '8vo Básico B', '🇬🇧', '#d63031', 'd0000000-0000-0000-0000-000000000004'),
  ('c0000000-0000-0000-0000-000000000006', 'Artes Visuales', 'Pintura y escultura', '8vo Básico B', '🎨', '#e84393', 'd0000000-0000-0000-0000-000000000005'),
  ('c0000000-0000-0000-0000-000000000007', 'Matemáticas Básicas', 'Aritmética y proporciones', '8vo Básico B', '➕', '#0984e3', '3f9a494e-0b90-4f84-898b-66efae34413b'),
  ('c0000000-0000-0000-0000-000000000008', 'Ciencias Naturales', 'Física y química básica', '8vo Básico B', '🧪', '#00b894', 'd0000000-0000-0000-0000-000000000002');

-- ═══════════════════════════════════
-- INSCRIPCIONES (Distribuir a los alumnos en los cursos de 2do Medio A y 8vo Básico B)
-- ═══════════════════════════════════
-- Alumnos de 2do Medio A (Jorell, María, Pedro, Ana, Diego, Sofia, Valentina)
INSERT INTO inscripciones (alumno_id, curso_id, progreso)
SELECT p.id, c.id, floor(random() * 80 + 20)
FROM perfiles p
CROSS JOIN cursos c
WHERE p.rol = 'alumno' 
AND c.nivel = '2do Medio A'
AND p.nombre IN ('Jorell Inostroza', 'María González', 'Pedro Silva', 'Ana Morales', 'Diego Campos', 'Sofía Reyes', 'Valentina Rojas');

-- Alumnos de 8vo Básico B (El resto)
INSERT INTO inscripciones (alumno_id, curso_id, progreso)
SELECT p.id, c.id, floor(random() * 80 + 20)
FROM perfiles p
CROSS JOIN cursos c
WHERE p.rol = 'alumno' 
AND c.nivel = '8vo Básico B'
AND p.nombre NOT IN ('Jorell Inostroza', 'María González', 'Pedro Silva', 'Ana Morales', 'Diego Campos', 'Sofía Reyes', 'Valentina Rojas');

-- ═══════════════════════════════════
-- LOGROS Y PREMIOS
-- ═══════════════════════════════════
INSERT INTO logros (nombre, descripcion, icono, xp_premio, categoria) VALUES
  ('Primera entrega', 'Entrega tu primera tarea', '🎯', 50, 'inicio'),
  ('Dedicado', 'Entrega 5 tareas consecutivas', '📚', 100, 'constancia'),
  ('Veloz', 'Entrega antes del plazo 3 veces', '⚡', 75, 'puntualidad'),
  ('Explorador', 'Descarga 10 materiales offline', '🗺️', 60, 'offline'),
  ('Social', 'Envía 3 feedbacks', '💬', 40, 'participacion'),
  ('Cerebrito', 'Obtén nota 7.0 en 3 tareas', '🧠', 150, 'academico'),
  ('Ave Nocturna', 'Sube una tarea después de las 22:00', '🦉', 80, 'constancia'),
  ('Intocable', 'Un mes entero sin entregas tardías', '🛡️', 200, 'puntualidad');

INSERT INTO premios (nombre, descripcion, icono, categoria, precio_monedas) VALUES
  ('Cuaderno extra', 'Cuaderno universitario', '📓', 'escolar', 15),
  ('Recreo libre 10min', 'Un recreo libre adicional', '⏰', 'recreativo', 30),
  ('Exención de tarea', 'Una tarea a elección', '✅', 'educativo', 50),
  ('Sticker digital', 'Pack de stickers', '🎨', 'digital', 5),
  ('Avatar legendario', 'Borde de oro para tu foto de perfil', '👑', 'digital', 100),
  ('Ticket de Cafetería', 'Canjeable por un jugo o snack', '🥪', 'recreativo', 80);

-- ═══════════════════════════════════
-- MATERIALES DE PRUEBA (Para cada curso)
-- ═══════════════════════════════════
-- Generar Guías
INSERT INTO materiales (curso_id, docente_id, titulo, descripcion, tipo, publicado, xp_premio, fecha_entrega)
SELECT c.id, c.docente_id, 'Guía 1 - Introducción a ' || c.nombre, 'Material de lectura obligatoria', 'guia', TRUE, 25, NULL
FROM cursos c;

INSERT INTO materiales (curso_id, docente_id, titulo, descripcion, tipo, publicado, xp_premio, fecha_entrega)
SELECT c.id, c.docente_id, 'Guía 2 - Avanzado de ' || c.nombre, 'Material de apoyo', 'guia', TRUE, 30, NULL
FROM cursos c;

-- Generar Tareas (Evaluaciones con fecha)
INSERT INTO materiales (curso_id, docente_id, titulo, descripcion, tipo, publicado, xp_premio, fecha_entrega)
SELECT c.id, c.docente_id, 'Evaluación Sumativa 1', 'Prueba escrita de la Unidad 1', 'tarea', TRUE, 100, NOW() - INTERVAL '5 days'
FROM cursos c;

INSERT INTO materiales (curso_id, docente_id, titulo, descripcion, tipo, publicado, xp_premio, fecha_entrega)
SELECT c.id, c.docente_id, 'Trabajo de Investigación', 'Ensayo crítico sobre la materia', 'tarea', TRUE, 150, NOW() + INTERVAL '3 days'
FROM cursos c;

INSERT INTO materiales (curso_id, docente_id, titulo, descripcion, tipo, publicado, xp_premio, fecha_entrega)
SELECT c.id, c.docente_id, 'Laboratorio Práctico', 'Aplicación práctica de la unidad 2', 'tarea', TRUE, 120, NOW() + INTERVAL '12 days'
FROM cursos c;

-- ═══════════════════════════════════
-- ENTREGAS DE PRUEBA (Simular un colegio funcionando)
-- ═══════════════════════════════════
-- Evaluaciones pasadas (Entregadas y Revisadas)
INSERT INTO entregas (alumno_id, material_id, contenido, estado, calificacion, comentario, entregado_en, revisado_en)
SELECT 
  p.id,
  m.id,
  'Estimado profesor, adjunto el desarrollo de mi evaluación.',
  'revisado',
  -- Notas aleatorias entre 3.5 y 7.0
  round((random() * 3.5 + 3.5)::numeric, 1),
  CASE WHEN random() > 0.5 THEN 'Buen trabajo.' ELSE 'Faltó profundizar en la conclusión, pero el resto está excelente.' END,
  NOW() - INTERVAL '6 days',
  NOW() - INTERVAL '4 days'
FROM perfiles p
JOIN inscripciones i ON p.id = i.alumno_id
JOIN materiales m ON i.curso_id = m.curso_id
WHERE p.rol = 'alumno' AND m.tipo = 'tarea' AND m.titulo = 'Evaluación Sumativa 1' AND random() > 0.1; -- 90% la entregaron

-- Tareas recientes (Solo entregadas, pendientes de revisión)
INSERT INTO entregas (alumno_id, material_id, contenido, estado, calificacion, comentario, entregado_en)
SELECT 
  p.id,
  m.id,
  'Aquí va mi avance del ensayo.',
  'entregado',
  NULL,
  NULL,
  NOW() - INTERVAL '1 days'
FROM perfiles p
JOIN inscripciones i ON p.id = i.alumno_id
JOIN materiales m ON i.curso_id = m.curso_id
WHERE p.rol = 'alumno' AND m.tipo = 'tarea' AND m.titulo = 'Trabajo de Investigación' AND random() > 0.4; -- 60% la han entregado hasta ahora

-- Algunas tareas tardías
INSERT INTO entregas (alumno_id, material_id, contenido, estado, calificacion, comentario, entregado_en)
SELECT 
  p.id,
  m.id,
  'Disculpe la demora profe, se me cayó el internet.',
  'tardio',
  NULL,
  NULL,
  NOW() - INTERVAL '1 days'
FROM perfiles p
JOIN inscripciones i ON p.id = i.alumno_id
JOIN materiales m ON i.curso_id = m.curso_id
WHERE p.rol = 'alumno' AND m.tipo = 'tarea' AND m.titulo = 'Evaluación Sumativa 1' AND random() < 0.1; -- Los que faltaron, la entregan tarde

-- ═══════════════════════════════════
-- LOGROS DESBLOQUEADOS (Random para darle vida a la vista de gamificación)
-- ═══════════════════════════════════
INSERT INTO logros_alumno (alumno_id, logro_id)
SELECT p.id, l.id 
FROM perfiles p 
CROSS JOIN logros l
WHERE p.rol = 'alumno' AND random() > 0.6;

-- ═══════════════════════════════════
-- NOTIFICACIONES Y COMUNICADOS
-- ═══════════════════════════════════
INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo)
SELECT p.id, '¡Nueva evaluación disponible!', 'El profesor ha subido Trabajo de Investigación.', 'info'
FROM perfiles p WHERE p.rol = 'alumno' AND random() > 0.5;

INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo)
SELECT p.id, '¡Logro desbloqueado!', 'Has conseguido un nuevo logro en tu perfil.', 'exito'
FROM perfiles p WHERE p.rol = 'alumno' AND random() > 0.7;

INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo)
SELECT id, 'Correcciones pendientes', 'Tienes evaluaciones sumativas por corregir.', 'alerta'
FROM perfiles WHERE rol = 'docente';

INSERT INTO comunicados (autor_id, titulo, contenido, importante, para_roles) VALUES
  ('e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'Suspensión de clases viernes 15', 'Por motivo del corte de agua programado en la comuna, se suspenden las clases este viernes.', TRUE, ARRAY['alumno', 'docente', 'directivo']),
  ('e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'Cierre de semestre académico', 'Se recuerda a todos los docentes que el plazo máximo para subir las notas de la Unidad 1 vence el próximo martes.', TRUE, ARRAY['docente', 'directivo']),
  ('e2367fdf-782c-4a1a-ac8e-3cd48addac16', 'Feria Científica 2026', 'Inscripciones abiertas para la feria científica. Habrá premios sorpresa para los mejores stands.', FALSE, ARRAY['alumno', 'docente']);
