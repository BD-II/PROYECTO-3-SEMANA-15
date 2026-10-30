-- FACTURA: 41 registros originales.
CREATE TEMP TABLE _original_factura (LIKE public.factura INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_factura (id_factura, id_pedido, numero_comprobante, metodo_pago, total_pagado) VALUES
('F001', 'PD001', '1001', 'Efectivo', '69.00'),
('F002', 'PD002', '1002', 'Tarjeta', '48.50'),
('F003', 'PD003', '1003', 'Yape', '48.00'),
('F004', 'PD004', '1004', 'Efectivo', '47.50'),
('F005', 'PD006', '1005', 'Tarjeta', '65.00'),
('F006', 'PD007', '1006', 'Yape', '42.00'),
('F007', 'PD008', '1007', 'Efectivo', '55.00'),
('F008', 'PD010', '1008', 'Plin', '45.00'),
('F009', 'PD011', '1009', 'Tarjeta', '47.50'),
('F010', 'PD012', '1010', 'Efectivo', '80.50'),
('F011', 'PD013', '1011', 'Yape', '42.00'),
('F012', 'PD014', '1012', 'Tarjeta', '61.50'),
('F013', 'PD016', '1013', 'Efectivo', '51.00'),
('F014', 'PD017', '1014', 'Yape', '53.00'),
('F015', 'PD018', '1015', 'Tarjeta', '79.50'),
('F016', 'PD019', '1016', 'Efectivo', '41.00'),
('F017', 'PD021', '1017', 'Yape', '54.50'),
('F018', 'PD022', '1018', 'Tarjeta', '47.50'),
('F019', 'PD023', '1019', 'Efectivo', '61.50'),
('F020', 'PD024', '1020', 'Plin', '47.00'),
('F021', 'PD026', '1021', 'Yape', '43.50'),
('F022', 'PD027', '1022', 'Efectivo', '52.00'),
('F023', 'PD028', '1023', 'Tarjeta', '45.00'),
('F024', 'PD030', '1024', 'Yape', '54.50'),
('F025', 'PD031', '1025', 'Efectivo', '38.00'),
('F026', 'PD032', '1026', 'Tarjeta', '52.50'),
('F027', 'PD033', '1027', 'Yape', '57.50'),
('F028', 'PD034', '1028', 'Efectivo', '36.00'),
('F029', 'PD036', '1029', 'Tarjeta', '45.50'),
('F030', 'PD037', '1030', 'Yape', '48.00'),
('F031', 'PD038', '1031', 'Efectivo', '40.00'),
('F032', 'PD039', '1032', 'Tarjeta', '52.00'),
('F033', 'PD041', '1033', 'Yape', '43.50'),
('F034', 'PD042', '1034', 'Efectivo', '43.00'),
('F035', 'PD043', '1035', 'Tarjeta', '40.50'),
('F036', 'PD044', '1036', 'Yape', '55.50'),
('F037', 'PD046', '1037', 'Efectivo', '41.00'),
('F038', 'PD047', '1038', 'Tarjeta', '45.50'),
('F039', 'PD048', '1039', 'Efectivo', '60.00'),
('F040', 'PD049', '1040', 'Yape', '70.50'),
('F041', 'PD050', '1041', 'Efectivo', '50.50');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.factura t JOIN _original_factura s ON t.id_factura=s.id_factura WHERE t.id_pedido IS DISTINCT FROM s.id_pedido OR t.numero_comprobante IS DISTINCT FROM s.numero_comprobante OR t.metodo_pago IS DISTINCT FROM s.metodo_pago OR t.total_pagado IS DISTINCT FROM s.total_pagado) THEN
 RAISE EXCEPTION 'Conflicto en factura: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.factura (id_factura, id_pedido, numero_comprobante, metodo_pago, total_pagado)
 SELECT id_factura, id_pedido, numero_comprobante, metodo_pago, total_pagado FROM _original_factura
 ON CONFLICT (id_factura) DO NOTHING;

