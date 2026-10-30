CREATE OR REPLACE FUNCTION fn_normalizar_estado_reserva() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE capacidad_mesa integer;
BEGIN
 NEW.estado_reserva=initcap(lower(btrim(NEW.estado_reserva)));
 IF TG_OP='UPDATE' AND NEW.id_reserva<>OLD.id_reserva THEN RAISE EXCEPTION 'ID reserva inmutable'; END IF;
 -- Se serializan reservas de la misma mesa. El backend usara READ COMMITTED.
 IF TG_OP='UPDATE' THEN
  PERFORM 1 FROM public.mesa WHERE numero_mesa IN (OLD.numero_mesa,NEW.numero_mesa) ORDER BY numero_mesa FOR UPDATE;
 END IF;
 SELECT capacidad INTO capacidad_mesa FROM public.mesa WHERE numero_mesa=NEW.numero_mesa FOR UPDATE;
 IF NOT FOUND OR NEW.cantidad_personas>capacidad_mesa THEN RAISE EXCEPTION 'Mesa inexistente o capacidad insuficiente'; END IF;
 IF NEW.estado_reserva IN ('Pendiente','Confirmada') AND EXISTS(
 SELECT 1 FROM public.reserva r WHERE r.numero_mesa=NEW.numero_mesa AND r.id_reserva<>NEW.id_reserva
 AND r.estado_reserva IN ('Pendiente','Confirmada')
 AND tsrange(r.fecha_reserva,r.fecha_reserva+make_interval(mins=>r.duracion_minutos),'[)') &&
 tsrange(NEW.fecha_reserva,NEW.fecha_reserva+make_interval(mins=>NEW.duracion_minutos),'[)')) THEN
 RAISE EXCEPTION 'La mesa tiene otra reserva en ese intervalo'; END IF;
 RETURN NEW;
END $$;
