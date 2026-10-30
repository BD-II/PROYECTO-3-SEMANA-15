-- PEDIDO: 50 registros originales.
CREATE TEMP TABLE _original_pedido (LIKE public.pedido INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_pedido (id_pedido, id_empleado, id_cliente, fecha, tipo_pedido, estado, legado) VALUES
('PD001', 'E001', 'C001', '2026-08-01 12:00:00', 'Presencial', '2', true),
('PD002', 'E002', 'C002', '2026-08-01 12:30:00', 'Delivery', '2', true),
('PD003', 'E001', 'C003', '2026-08-01 13:00:00', 'Presencial', '2', true),
('PD004', 'E002', 'C004', '2026-08-01 13:30:00', 'Recojo', '2', true),
('PD005', 'E003', 'C005', '2026-08-01 14:00:00', 'Delivery', '3', true),
('PD006', 'E001', 'C006', '2026-08-03 12:15:00', 'Presencial', '2', true),
('PD007', 'E002', 'C007', '2026-08-03 12:45:00', 'Delivery', '2', true),
('PD008', 'E003', 'C008', '2026-08-03 13:10:00', 'Presencial', '2', true),
('PD009', 'E001', 'C009', '2026-08-03 13:40:00', 'Recojo', '1', true),
('PD010', 'E002', 'C010', '2026-08-03 14:20:00', 'Delivery', '2', true),
('PD011', 'E003', 'C011', '2026-08-05 12:00:00', 'Presencial', '2', true),
('PD012', 'E001', 'C012', '2026-08-05 12:25:00', 'Delivery', '2', true),
('PD013', 'E002', 'C013', '2026-08-05 13:00:00', 'Presencial', '2', true),
('PD014', 'E003', 'C014', '2026-08-05 13:30:00', 'Recojo', '2', true),
('PD015', 'E001', 'C015', '2026-08-05 14:00:00', 'Delivery', '3', true),
('PD016', 'E002', 'C016', '2026-08-07 12:10:00', 'Presencial', '2', true),
('PD017', 'E003', 'C017', '2026-08-07 12:40:00', 'Delivery', '2', true),
('PD018', 'E001', 'C018', '2026-08-07 13:15:00', 'Presencial', '2', true),
('PD019', 'E002', 'C019', '2026-08-07 13:45:00', 'Recojo', '2', true),
('PD020', 'E003', 'C020', '2026-08-07 14:15:00', 'Delivery', '1', true),
('PD021', 'E001', 'C021', '2026-08-10 12:00:00', 'Presencial', '2', true),
('PD022', 'E002', 'C022', '2026-08-10 12:30:00', 'Delivery', '2', true),
('PD023', 'E003', 'C023', '2026-08-10 13:00:00', 'Presencial', '2', true),
('PD024', 'E001', 'C024', '2026-08-10 13:30:00', 'Recojo', '2', true),
('PD025', 'E002', 'C025', '2026-08-10 14:00:00', 'Delivery', '3', true),
('PD026', 'E003', 'C026', '2026-08-12 12:15:00', 'Presencial', '2', true),
('PD027', 'E001', 'C027', '2026-08-12 12:45:00', 'Delivery', '2', true),
('PD028', 'E002', 'C028', '2026-08-12 13:15:00', 'Presencial', '2', true),
('PD029', 'E003', 'C029', '2026-08-12 13:45:00', 'Recojo', '1', true),
('PD030', 'E001', 'C030', '2026-08-12 14:15:00', 'Delivery', '2', true),
('PD031', 'E002', 'C001', '2026-08-14 12:00:00', 'Delivery', '2', true),
('PD032', 'E003', 'C005', '2026-08-14 12:30:00', 'Presencial', '2', true),
('PD033', 'E001', 'C010', '2026-08-14 13:00:00', 'Recojo', '2', true),
('PD034', 'E002', 'C015', '2026-08-14 13:30:00', 'Delivery', '2', true),
('PD035', 'E003', 'C020', '2026-08-14 14:00:00', 'Presencial', '3', true),
('PD036', 'E001', 'C003', '2026-08-16 12:10:00', 'Presencial', '2', true),
('PD037', 'E002', 'C008', '2026-08-16 12:40:00', 'Delivery', '2', true),
('PD038', 'E003', 'C013', '2026-08-16 13:10:00', 'Recojo', '2', true),
('PD039', 'E001', 'C018', '2026-08-16 13:40:00', 'Delivery', '2', true),
('PD040', 'E002', 'C023', '2026-08-16 14:10:00', 'Presencial', '1', true),
('PD041', 'E003', 'C002', '2026-08-18 12:00:00', 'Delivery', '2', true),
('PD042', 'E001', 'C007', '2026-08-18 12:30:00', 'Presencial', '2', true),
('PD043', 'E002', 'C012', '2026-08-18 13:00:00', 'Recojo', '2', true),
('PD044', 'E003', 'C017', '2026-08-18 13:30:00', 'Delivery', '2', true),
('PD045', 'E001', 'C022', '2026-08-18 14:00:00', 'Presencial', '3', true),
('PD046', 'E002', 'C004', '2026-08-19 12:00:00', 'Delivery', '2', true),
('PD047', 'E003', 'C009', '2026-08-19 12:30:00', 'Presencial', '2', true),
('PD048', 'E001', 'C014', '2026-08-19 13:00:00', 'Recojo', '2', true),
('PD049', 'E002', 'C019', '2026-08-19 13:30:00', 'Delivery', '2', true),
('PD050', 'E003', 'C024', '2026-08-19 14:00:00', 'Presencial', '2', true);
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.pedido t JOIN _original_pedido s ON t.id_pedido=s.id_pedido WHERE t.id_empleado IS DISTINCT FROM s.id_empleado OR t.id_cliente IS DISTINCT FROM s.id_cliente OR t.fecha IS DISTINCT FROM s.fecha OR t.tipo_pedido IS DISTINCT FROM s.tipo_pedido OR t.estado IS DISTINCT FROM s.estado OR t.legado IS DISTINCT FROM s.legado) THEN
 RAISE EXCEPTION 'Conflicto en pedido: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.pedido (id_pedido, id_empleado, id_cliente, fecha, tipo_pedido, estado, legado)
 SELECT id_pedido, id_empleado, id_cliente, fecha, tipo_pedido, estado, legado FROM _original_pedido
 ON CONFLICT (id_pedido) DO NOTHING;

