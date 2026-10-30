CREATE FUNCTION fn_detalle_inventario() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r record;
BEGIN
 -- DELETE se atiende BEFORE para leer la instantanea antes del borrado en cascada.
 IF TG_OP IN ('DELETE','UPDATE') THEN
  FOR r IN SELECT * FROM public.detalle_insumo WHERE id_detalle=OLD.id_detalle ORDER BY id_ingrediente LOOP
   PERFORM public.fn_mover_stock(r.id_ingrediente,r.cantidad_por_unidad*OLD.cantidad,'Devolucion por cambio de detalle',OLD.id_pedido);
  END LOOP;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 IF TG_OP='INSERT' OR NEW.id_plato IS DISTINCT FROM OLD.id_plato THEN
  DELETE FROM public.detalle_insumo WHERE id_detalle=NEW.id_detalle;
  INSERT INTO public.detalle_insumo SELECT NEW.id_detalle,id_ingrediente,cantidad_requerida FROM public.receta WHERE id_plato=NEW.id_plato;
  IF NOT FOUND THEN RAISE EXCEPTION 'El plato % no tiene receta; no se puede controlar su consumo',NEW.id_plato; END IF;
 END IF;
 FOR r IN SELECT * FROM public.detalle_insumo WHERE id_detalle=NEW.id_detalle ORDER BY id_ingrediente LOOP
  PERFORM public.fn_mover_stock(r.id_ingrediente,-r.cantidad_por_unidad*NEW.cantidad,'Reserva de ingredientes por pedido',NEW.id_pedido);
 END LOOP;
 RETURN NEW;
END $$;

