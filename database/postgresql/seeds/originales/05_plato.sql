-- PLATO: 40 registros originales.
CREATE TEMP TABLE _original_plato (LIKE public.plato INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_plato (id_plato, nombre_plato, categoria, precio) VALUES
('P001', 'Papa a la Huancaina', 'Entrada', '12.00'),
('P002', 'Causa Limeña', 'Entrada', '14.00'),
('P003', 'Ocopa Arequipeña', 'Entrada', '13.50'),
('P004', 'Tequeños de Queso', 'Entrada', '11.00'),
('P005', 'Ensalada Cesar', 'Entrada', '15.00'),
('P006', 'Anticuchos', 'Entrada', '16.00'),
('P008', 'Tamal Criollo', 'Entrada', '10.00'),
('P009', 'Wantan Frito', 'Entrada', '9.00'),
('P010', 'Sopa Criolla', 'Entrada', '14.50'),
('P011', 'Lomo Saltado', 'Fondo', '25.00'),
('P012', 'Arroz Chaufa', 'Fondo', '20.00'),
('P014', 'Aji de Gallina', 'Fondo', '24.00'),
('P016', 'Tallarines Verdes', 'Fondo', '22.00'),
('P017', 'Pollo a la Brasa', 'Fondo', '26.00'),
('P020', 'Tacu Tacu con Lomo', 'Fondo', '31.00'),
('P021', 'Carapulcra', 'Fondo', '23.00'),
('P022', 'Arroz con Pollo', 'Fondo', '24.50'),
('P023', 'Milanesa con Papas', 'Fondo', '27.00'),
('P029', 'Suspiro a la Limeña', 'Postre', '9.50'),
('P030', 'Arroz con Leche', 'Postre', '7.00'),
('P031', 'Mazamorra Morada', 'Postre', '7.00'),
('P032', 'Picarones', 'Postre', '10.00'),
('P033', 'Torta de Chocolate', 'Postre', '11.00'),
('P034', 'Cheesecake de Fresa', 'Postre', '12.00'),
('P035', 'Helado Artesanal', 'Postre', '8.50'),
('P036', 'Inca Kola', 'Bebida', '5.00'),
('P037', 'Chicha Morada', 'Bebida', '4.50'),
('P038', 'Limonada', 'Bebida', '6.00'),
('P039', 'Maracuya Frozen', 'Bebida', '8.00'),
('P040', 'Cafe Americano', 'Bebida', '5.50'),
('P007', 'Tequeños de Pollo', 'Entrada', '13.00'),
('P013', 'Arroz con Pollo Especial', 'Fondo', '27.00'),
('P015', 'Pollo Saltado', 'Fondo', '25.00'),
('P018', 'Pollo Broaster', 'Fondo', '25.00'),
('P019', 'Alitas Broaster', 'Fondo', '23.00'),
('P024', 'Pollo al Horno', 'Fondo', '26.00'),
('P025', 'Pollo Guisado', 'Fondo', '24.00'),
('P026', 'Pollo a la Leña', 'Fondo', '18.00'),
('P027', 'Pollo a la Plancha', 'Fondo', '25.00'),
('P028', 'Pollo Frito con Arroz', 'Fondo', '24.00');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.plato t JOIN _original_plato s ON t.id_plato=s.id_plato WHERE t.nombre_plato IS DISTINCT FROM s.nombre_plato OR t.categoria IS DISTINCT FROM s.categoria OR t.precio IS DISTINCT FROM s.precio) THEN
 RAISE EXCEPTION 'Conflicto en plato: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.plato (id_plato, nombre_plato, categoria, precio)
 SELECT id_plato, nombre_plato, categoria, precio FROM _original_plato
 ON CONFLICT (id_plato) DO NOTHING;

