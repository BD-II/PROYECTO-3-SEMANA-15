CREATE FUNCTION fn_pedido_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r record;
BEGIN
 IF TG_OP='INSERT' THEN
  IF NEW.estado<>0 OR NEW.legado THEN RAISE EXCEPTION 'Pedido nuevo debe iniciar pendiente y sin marca legado'; END IF;
  RETURN NEW;
 END IF;
 IF OLD.legado THEN RAISE EXCEPTION 'Pedido PC1 protegido: requiere conciliacion manual antes de continuar'; END IF;
 IF NEW.id_pedido<>OLD.id_pedido OR NEW.legado<>OLD.legado THEN RAISE EXCEPTION 'Identificador y marca legado inmutables'; END IF;
 IF OLD.estado IN (2,3) AND NEW IS DISTINCT FROM OLD THEN RAISE EXCEPTION 'Pedido cerrado no editable'; END IF;
 IF NEW.estado IS DISTINCT FROM OLD.estado THEN
  IF NOT ((OLD.estado=0 AND NEW.estado IN (1,3)) OR (OLD.estado=1 AND NEW.estado IN (2,3))) THEN RAISE EXCEPTION 'Transicion de estado no permitida'; END IF;
  IF NEW.estado IN (1,2) AND NOT EXISTS(SELECT 1 FROM public.detalle_pedido WHERE id_pedido=OLD.id_pedido) THEN RAISE EXCEPTION 'Pedido sin detalles'; END IF;
  IF NEW.estado=2 AND NOT EXISTS(SELECT 1 FROM public.factura WHERE id_pedido=OLD.id_pedido) THEN RAISE EXCEPTION 'Registrar pago antes de entregar'; END IF;
  IF OLD.estado=0 AND NEW.estado=3 THEN
   FOR r IN SELECT i.id_ingrediente,sum(i.cantidad_por_unidad*d.cantidad) cantidad
    FROM public.detalle_pedido d JOIN public.detalle_insumo i USING(id_detalle)
    WHERE d.id_pedido=OLD.id_pedido GROUP BY i.id_ingrediente ORDER BY i.id_ingrediente LOOP
    PERFORM public.fn_mover_stock(r.id_ingrediente,r.cantidad,'Cancelacion antes de preparacion',OLD.id_pedido);
   END LOOP;
  END IF;
  -- Cancelar en preparacion NO devuelve ingredientes ya consumidos.
 END IF;
 RETURN NEW;
END $$;

