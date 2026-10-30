-- HISTORIAL_RESERVA: 2 registros originales.
CREATE TEMP TABLE _original_historial_reserva (LIKE public.historial_reserva INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_historial_reserva (id_historial, id_reserva, estado_anterior, estado_nuevo, fecha_cambio) VALUES
('H001', 'R066', 'Pendiente', 'Confirmada', '2026-09-06 01:09:15.138152'),
('H002', 'R099', 'Confirmada', 'Cancelada', '2026-09-06 19:31:29.45553');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.historial_reserva t JOIN _original_historial_reserva s ON t.id_historial=s.id_historial WHERE t.id_reserva IS DISTINCT FROM s.id_reserva OR t.estado_anterior IS DISTINCT FROM s.estado_anterior OR t.estado_nuevo IS DISTINCT FROM s.estado_nuevo OR t.fecha_cambio IS DISTINCT FROM s.fecha_cambio) THEN
 RAISE EXCEPTION 'Conflicto en historial_reserva: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.historial_reserva (id_historial, id_reserva, estado_anterior, estado_nuevo, fecha_cambio)
 SELECT id_historial, id_reserva, estado_anterior, estado_nuevo, fecha_cambio FROM _original_historial_reserva
 ON CONFLICT (id_historial) DO NOTHING;

