-- ═══════════════════════════════════
-- 006_directivo_rls.sql
-- EduPlataforma v2.0
-- Permite al Directivo insertar/editar cursos e inscripciones.
-- ═══════════════════════════════════

-- Cursos: Directivo gestiona todo (INSERT, UPDATE, DELETE)
CREATE POLICY "Directivo gestiona cursos" ON cursos
  FOR ALL USING (public.get_user_role(auth.uid()) = 'directivo');

-- Inscripciones: Directivo gestiona todo (INSERT, UPDATE, DELETE)
CREATE POLICY "Directivo gestiona inscripciones" ON inscripciones
  FOR ALL USING (public.get_user_role(auth.uid()) = 'directivo');
