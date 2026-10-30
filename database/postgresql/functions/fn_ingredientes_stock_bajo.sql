CREATE OR REPLACE FUNCTION fn_ingredientes_stock_bajo(p_stock_minimo numeric)
RETURNS TABLE(id_ingrediente varchar,nombre_ingrediente varchar,stock_actual numeric,unidad_medida varchar,id_proveedor varchar)
LANGUAGE sql STABLE AS $$ SELECT id_ingrediente,nombre_ingrediente,stock_actual,unidad_medida,id_proveedor FROM public.ingrediente WHERE stock_actual<=p_stock_minimo ORDER BY stock_actual $$;

