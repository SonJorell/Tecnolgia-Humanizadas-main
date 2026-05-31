-- ═══════════════════════════════════
-- 017_rediseno_docente.sql
-- EduPlataforma v2.0
-- Rediseño del Módulo Docente: Estadísticas, Mensajería y Logros Docentes
-- ═══════════════════════════════════

-- 1. Modificar tabla cursos
ALTER TABLE cursos ADD COLUMN IF NOT EXISTS descripcion TEXT DEFAULT '';
ALTER TABLE cursos ADD COLUMN IF NOT EXISTS banner_url TEXT DEFAULT '/banners/default-course.jpg';
ALTER TABLE cursos ADD COLUMN IF NOT EXISTS objetivos TEXT[] DEFAULT '{}';
ALTER TABLE cursos ADD COLUMN IF NOT EXISTS estado TEXT DEFAULT 'activo';

-- 2. Modificar tabla materiales
ALTER TABLE materiales ADD COLUMN IF NOT EXISTS visualizaciones INTEGER DEFAULT 0;
ALTER TABLE materiales ADD COLUMN IF NOT EXISTS descargas INTEGER DEFAULT 0;

-- 3. Logros Docente
CREATE TABLE IF NOT EXISTS logros_docente (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  docente_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  icono TEXT NOT NULL DEFAULT '🌟',
  rareza TEXT DEFAULT 'comun',
  recompensa_xp INTEGER DEFAULT 10,
  recompensa_monedas INTEGER DEFAULT 5,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE logros_docente ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Docente gestiona sus logros" ON logros_docente FOR ALL USING (public.get_user_role(auth.uid()) = 'docente' AND docente_id = auth.uid());
CREATE POLICY "Alumnos leen logros" ON logros_docente FOR SELECT USING (true); 

CREATE TABLE IF NOT EXISTS logros_asignados (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  alumno_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  logro_docente_id UUID REFERENCES logros_docente(id) ON DELETE CASCADE,
  fecha TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE logros_asignados ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Docente otorga logros" ON logros_asignados FOR INSERT WITH CHECK (public.get_user_role(auth.uid()) = 'docente');
CREATE POLICY "Lectura de logros asignados" ON logros_asignados FOR SELECT USING (true);

-- 4. Mensajería Reestructurada
DROP TABLE IF EXISTS mensajes CASCADE;

CREATE TABLE IF NOT EXISTS conversaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tipo TEXT NOT NULL CHECK (tipo IN ('individual', 'curso')),
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  participante_1 UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  participante_2 UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mensajes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversacion_id UUID REFERENCES conversaciones(id) ON DELETE CASCADE,
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  autor_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  contenido TEXT NOT NULL,
  leido BOOLEAN DEFAULT FALSE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE conversaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participantes ven conversaciones" ON conversaciones
  FOR SELECT USING (
    (tipo = 'individual' AND (participante_1 = auth.uid() OR participante_2 = auth.uid()))
    OR
    (tipo = 'curso' AND (
      EXISTS (SELECT 1 FROM cursos c WHERE c.id = conversaciones.curso_id AND c.docente_id = auth.uid()) OR
      EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = conversaciones.curso_id AND i.alumno_id = auth.uid())
    ))
  );

CREATE POLICY "Docente crea conversaciones" ON conversaciones
  FOR INSERT WITH CHECK (public.get_user_role(auth.uid()) = 'docente');

CREATE POLICY "Lectura de mensajes" ON mensajes
  FOR SELECT USING (
    (conversacion_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
        (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
        OR
        (c.tipo = 'curso' AND (
          EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = c.curso_id AND curso.docente_id = auth.uid()) OR
          EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = c.curso_id AND i.alumno_id = auth.uid())
        ))
      )
    ))
    OR
    (curso_id IS NOT NULL AND (
      EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = mensajes.curso_id AND curso.docente_id = auth.uid()) OR
      EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid())
    ))
  );

CREATE POLICY "Escritura de mensajes" ON mensajes
  FOR INSERT WITH CHECK (
    autor_id = auth.uid() AND (
      (conversacion_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
          (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
          OR
          (c.tipo = 'curso' AND (
            EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = c.curso_id AND curso.docente_id = auth.uid()) OR
            EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = c.curso_id AND i.alumno_id = auth.uid())
          ))
        )
      ))
      OR
      (curso_id IS NOT NULL AND (
        EXISTS (SELECT 1 FROM cursos curso WHERE curso.id = mensajes.curso_id AND curso.docente_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM inscripciones i WHERE i.curso_id = mensajes.curso_id AND i.alumno_id = auth.uid())
      ))
    )
  );
  
CREATE POLICY "Actualizar mensajes" ON mensajes
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM conversaciones c WHERE c.id = mensajes.conversacion_id AND (
        (c.tipo = 'individual' AND (c.participante_1 = auth.uid() OR c.participante_2 = auth.uid()))
      )
    )
  );

-- 5. Notificaciones
CREATE TABLE IF NOT EXISTS notificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  tipo TEXT DEFAULT 'sistema',
  leido BOOLEAN DEFAULT FALSE,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuario ve sus notificaciones" ON notificaciones FOR SELECT USING (usuario_id = auth.uid());
CREATE POLICY "Sistema inserta notificaciones" ON notificaciones FOR INSERT WITH CHECK (true);
CREATE POLICY "Usuario actualiza sus notificaciones" ON notificaciones FOR UPDATE USING (usuario_id = auth.uid());

NOTIFY pgrst, 'reload schema';
