-- Permitir a los directivos actualizar y eliminar comunicados
CREATE POLICY "Directivos actualizan comunicados" ON comunicados
    FOR UPDATE USING (public.get_user_role(auth.uid()) IN ('directivo', 'ti'));

CREATE POLICY "Directivos eliminan comunicados" ON comunicados
    FOR DELETE USING (public.get_user_role(auth.uid()) IN ('directivo', 'ti'));
