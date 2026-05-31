-- 011_fix_rls_recursion.sql
-- Fix infinite recursion caused by SQL function inlining

CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  v_rol TEXT;
BEGIN
  SELECT rol INTO v_rol FROM public.perfiles WHERE id = user_id;
  RETURN v_rol;
END;
$$;
