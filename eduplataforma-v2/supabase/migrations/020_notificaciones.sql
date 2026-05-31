-- 020_notificaciones.sql

CREATE TABLE IF NOT EXISTS notificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES perfiles(id) NOT NULL,
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  leido BOOLEAN DEFAULT false,
  tipo TEXT DEFAULT 'general',
  enlace TEXT,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven sus propias notificaciones" 
  ON notificaciones FOR SELECT 
  USING (usuario_id = auth.uid());

CREATE POLICY "Usuarios pueden actualizar sus notificaciones" 
  ON notificaciones FOR UPDATE 
  USING (usuario_id = auth.uid());

CREATE POLICY "Usuarios pueden borrar sus notificaciones" 
  ON notificaciones FOR DELETE 
  USING (usuario_id = auth.uid());

-- Insertar notificaciones automáticamente cuando hay un nuevo mensaje (solo si no es el autor)
CREATE OR REPLACE FUNCTION notificar_nuevo_mensaje() RETURNS TRIGGER AS $$
DECLARE
  v_conversacion RECORD;
  v_receptor_id UUID;
  v_autor_nombre TEXT;
BEGIN
  -- Obtener información de la conversación
  SELECT * INTO v_conversacion FROM conversaciones WHERE id = NEW.conversacion_id;
  
  IF v_conversacion.tipo = 'individual' THEN
    -- Determinar receptor
    IF v_conversacion.participante_1 = NEW.autor_id THEN
      v_receptor_id := v_conversacion.participante_2;
    ELSE
      v_receptor_id := v_conversacion.participante_1;
    END IF;
    
    -- Obtener nombre del autor
    SELECT nombre INTO v_autor_nombre FROM perfiles WHERE id = NEW.autor_id;
    
    -- Crear notificación
    INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo, enlace)
    VALUES (
      v_receptor_id, 
      'Nuevo Mensaje', 
      v_autor_nombre || ' te ha enviado un mensaje.',
      'mensaje',
      '/' || (SELECT rol FROM perfiles WHERE id = v_receptor_id) || '/mensajeria'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_mensaje ON mensajes;
CREATE TRIGGER trigger_notificar_mensaje
  AFTER INSERT ON mensajes
  FOR EACH ROW
  EXECUTE FUNCTION notificar_nuevo_mensaje();
