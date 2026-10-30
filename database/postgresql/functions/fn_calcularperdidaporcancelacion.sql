CREATE OR REPLACE FUNCTION fn_calcularperdidaporcancelacion() RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT coalesce(sum(d.subtotal),0) FROM public.pedido p JOIN public.detalle_pedido d USING(id_pedido) WHERE p.estado=3 $$;
COMMENT ON FUNCTION fn_calcularperdidaporcancelacion() IS 'Compatibilidad PC1: valor de ventas canceladas, NO costo real de merma.';
