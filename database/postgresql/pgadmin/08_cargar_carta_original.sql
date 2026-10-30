-- Generado: editar fuentes modulares y recompilar.
-- 08_cargar_carta_original.sql
-- Abrir en Query Tool de la base v2 instalada. Ejecutar COMPLETO como postgres.
-- No ejecutar otra vez 01_instalar ni 02_actualizar_pc1.
-- Fuente: datos ficticios del respaldo PC1 proporcionado por el equipo.
-- Recupera 12 proveedores, 62 ingredientes, 40 platos y 143 filas de receta.
-- Conserva los registros demo y cualquier otro dato existente.
-- Si un ID existente tiene contenido distinto, aborta sin sobrescribirlo.
-- Si se repite con el mismo catalogo, no duplica ni repone stock consumido.
BEGIN;
SET LOCAL search_path=public,pg_catalog;
SET LOCAL standard_conforming_strings=on;
LOCK TABLE public.proveedor, public.ingrediente, public.plato, public.receta,
 public.movimiento_inventario IN SHARE ROW EXCLUSIVE MODE;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.schema_version WHERE version=2) THEN
 RAISE EXCEPTION 'Se requiere instalar primero PostgreSQL v2'; END IF;
END $$;

-- proveedor: 12 registros originales
CREATE TEMP TABLE _src_proveedor (LIKE public.proveedor) ON COMMIT DROP;
INSERT INTO _src_proveedor (id_proveedor, razon_social, ruc, telefono, contacto) VALUES
('PR001', 'Avícola San Martín S.A.C.', '20123456781', '987654321', 'Carlos Mendoza'),
('PR002', 'Distribuidora La Granja S.A.C.', '20456781239', '986543210', 'Ana Torres'),
('PR003', 'Agroverduras del Valle S.A.C.', '20678912345', '985432109', 'Luis Ramírez'),
('PR004', 'Papas Andinas S.A.C.', '20543219876', '984321098', 'María Quispe'),
('PR005', 'Comercializadora El Buen Sabor S.A.C.', '20198765432', '983210987', 'Jorge Flores'),
('PR006', 'Aceites del Pacífico S.A.C.', '20432198765', '982109876', 'Patricia Vargas'),
('PR007', 'Lácteos Santa Rosa S.A.C.', '20654321987', '981098765', 'Roberto Castillo'),
('PR008', 'Bebidas Lima Norte S.A.C.', '20567891234', '980987654', 'Daniela Rojas'),
('PR009', 'Panificados La Tradición S.A.C.', '20345678912', '979876543', 'Miguel Herrera'),
('PR010', 'Envases y Empaques Perú S.A.C.', '20789123456', '978765432', 'Claudia Medina'),
('PR011', 'Importaciones Sabores del Perú S.A.C.', '20234567891', '977654321', 'Fernando Paredes'),
('PR012', 'Distribuciones El Chef S.A.C.', '20891234567', '976543210', 'Andrea Salazar');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.proveedor t JOIN _src_proveedor s ON t.id_proveedor=s.id_proveedor WHERE t.razon_social IS DISTINCT FROM s.razon_social OR t.ruc IS DISTINCT FROM s.ruc OR t.telefono IS DISTINCT FROM s.telefono OR t.contacto IS DISTINCT FROM s.contacto) THEN
 RAISE EXCEPTION 'Conflicto en proveedor: ID existente con contenido diferente. No se sobrescribe; ejecutar ROLLBACK y revisar.';
 END IF;
END $$;
INSERT INTO public.proveedor (id_proveedor, razon_social, ruc, telefono, contacto)
 SELECT id_proveedor, razon_social, ruc, telefono, contacto FROM _src_proveedor
 ON CONFLICT (id_proveedor) DO NOTHING;

-- ingrediente: 62 registros originales
CREATE TEMP TABLE _src_ingrediente (LIKE public.ingrediente) ON COMMIT DROP;
INSERT INTO _src_ingrediente (id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida) VALUES
('ING001', 'PR001', 'Pollo entero', '85.00', 'kg'),
('ING002', 'PR001', 'Pechuga de pollo', '35.00', 'kg'),
('ING003', 'PR001', 'Alas de pollo', '25.00', 'kg'),
('ING004', 'PR001', 'Muslos de pollo', '30.00', 'kg'),
('ING005', 'PR001', 'Pierna de pollo', '25.00', 'kg'),
('ING007', 'PR002', 'Carne molida', '18.00', 'kg'),
('ING008', 'PR002', 'Chorizo', '15.00', 'kg'),
('ING009', 'PR003', 'Lechuga', '25.00', 'kg'),
('ING012', 'PR003', 'Cebolla china', '15.00', 'kg'),
('ING013', 'PR003', 'Zanahoria', '18.00', 'kg'),
('ING014', 'PR003', 'Pepino', '15.00', 'kg'),
('ING015', 'PR003', 'Ají amarillo', '10.00', 'kg'),
('ING016', 'PR003', 'Ají limo', '5.00', 'kg'),
('ING017', 'PR003', 'Limón', '20.00', 'kg'),
('ING019', 'PR004', 'Papa amarilla', '60.00', 'kg'),
('ING020', 'PR004', 'Camote', '35.00', 'kg'),
('ING021', 'PR004', 'Yuca', '30.00', 'kg'),
('ING024', 'PR005', 'Comino', '5.00', 'kg'),
('ING027', 'PR005', 'Páprika', '6.00', 'kg'),
('ING029', 'PR006', 'Aceite de oliva', '12.00', 'litros'),
('ING030', 'PR006', 'Manteca vegetal', '10.00', 'kg'),
('ING031', 'PR007', 'Queso fresco', '15.00', 'kg'),
('ING032', 'PR007', 'Queso mozzarella', '12.00', 'kg'),
('ING034', 'PR007', 'Mantequilla', '8.00', 'kg'),
('ING035', 'PR008', 'Chicha morada preparada', '30.00', 'litros'),
('ING036', 'PR008', 'Concentrado de maracuyá', '15.00', 'litros'),
('ING037', 'PR009', 'Pan para hamburguesa', '150.00', 'unidades'),
('ING038', 'PR009', 'Pan francés', '200.00', 'unidades'),
('ING039', 'PR009', 'Pan para sánguche', '100.00', 'unidades'),
('ING040', 'PR010', 'Harina de maíz', '25.00', 'kg'),
('ING042', 'PR010', 'Aceituna negra', '12.00', 'kg'),
('ING043', 'PR011', 'Arroz', '75.00', 'kg'),
('ING044', 'PR011', 'Harina de trigo', '30.00', 'kg'),
('ING045', 'PR011', 'Fideos', '25.00', 'kg'),
('ING046', 'PR012', 'Mayonesa', '18.00', 'kg'),
('ING047', 'PR012', 'Kétchup', '15.00', 'kg'),
('ING048', 'PR012', 'Mostaza', '10.00', 'kg'),
('ING049', 'PR012', 'Salsa de ají', '12.00', 'kg'),
('ING052', 'PR011', 'Cocoa en polvo', '15.00', 'kg'),
('ING053', 'PR011', 'Chocolate para cobertura', '12.00', 'kg'),
('ING055', 'PR005', 'Esencia de vainilla', '5.00', 'litros'),
('ING056', 'PR011', 'Gelatina sin sabor', '5.00', 'kg'),
('ING057', 'PR007', 'Crema de leche', '15.00', 'litros'),
('ING058', 'PR001', 'Huevos', '180.00', 'unidades'),
('ING059', 'PR007', 'Queso crema', '12.00', 'kg'),
('ING060', 'PR008', 'Inca Kola', '120.00', 'unidades'),
('ING061', 'PR008', 'Café molido', '10.00', 'kg'),
('ING062', 'PR003', 'Fresa', '15.00', 'kg'),
('ING025', 'PR005', 'Orégano', '4.00', 'kg'),
('ING041', 'PR010', 'Maní tostado', '45.50', 'kg'),
('ING033', 'PR007', 'Leche evaporada', '23.80', 'litros'),
('ING051', 'PR011', 'Azúcar', '49.92', 'kg'),
('ING054', 'PR007', 'Leche condensada', '19.80', 'kg'),
('ING006', 'PR002', 'Carne de res', '27.60', 'kg'),
('ING010', 'PR003', 'Tomate', '29.90', 'kg'),
('ING011', 'PR003', 'Cebolla roja', '27.84', 'kg'),
('ING018', 'PR004', 'Papa blanca', '99.70', 'kg'),
('ING022', 'PR005', 'Sal', '19.98', 'kg'),
('ING023', 'PR005', 'Pimienta negra', '4.98', 'kg'),
('ING026', 'PR005', 'Ajo molido', '7.98', 'kg'),
('ING028', 'PR006', 'Aceite vegetal', '44.94', 'litros'),
('ING050', 'PR012', 'Sillao', '11.96', 'litros');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.ingrediente t JOIN _src_ingrediente s ON t.id_ingrediente=s.id_ingrediente WHERE t.id_proveedor IS DISTINCT FROM s.id_proveedor OR t.nombre_ingrediente IS DISTINCT FROM s.nombre_ingrediente OR t.unidad_medida IS DISTINCT FROM s.unidad_medida) THEN
 RAISE EXCEPTION 'Conflicto en ingrediente: ID existente con contenido diferente. No se sobrescribe; ejecutar ROLLBACK y revisar.';
 END IF;
END $$;
WITH nuevos AS (
 INSERT INTO public.ingrediente (id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida)
 SELECT id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida FROM _src_ingrediente
 ON CONFLICT (id_ingrediente) DO NOTHING
 RETURNING id_ingrediente,stock_actual
)
INSERT INTO public.movimiento_inventario(id_ingrediente,variacion,saldo_resultante,motivo)
 SELECT id_ingrediente,stock_actual,stock_actual,'Saldo inicial de datos ficticios PC1; sin reconstruir movimientos pasados' FROM nuevos;

-- plato: 40 registros originales
CREATE TEMP TABLE _src_plato (LIKE public.plato) ON COMMIT DROP;
INSERT INTO _src_plato (id_plato, nombre_plato, categoria, precio) VALUES
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
 IF EXISTS(SELECT 1 FROM public.plato t JOIN _src_plato s ON t.id_plato=s.id_plato WHERE t.nombre_plato IS DISTINCT FROM s.nombre_plato OR t.categoria IS DISTINCT FROM s.categoria OR t.precio IS DISTINCT FROM s.precio) THEN
 RAISE EXCEPTION 'Conflicto en plato: ID existente con contenido diferente. No se sobrescribe; ejecutar ROLLBACK y revisar.';
 END IF;
END $$;
INSERT INTO public.plato (id_plato, nombre_plato, categoria, precio)
 SELECT id_plato, nombre_plato, categoria, precio FROM _src_plato
 ON CONFLICT (id_plato) DO NOTHING;

-- receta: 143 registros originales
CREATE TEMP TABLE _src_receta (LIKE public.receta) ON COMMIT DROP;
INSERT INTO _src_receta (id_plato, id_ingrediente, cantidad_requerida) VALUES
('P001', 'ING018', '0.25'),
('P001', 'ING031', '0.05'),
('P001', 'ING033', '0.05'),
('P001', 'ING015', '0.02'),
('P002', 'ING019', '0.25'),
('P002', 'ING031', '0.04'),
('P002', 'ING015', '0.02'),
('P003', 'ING018', '0.20'),
('P003', 'ING041', '0.03'),
('P003', 'ING015', '0.02'),
('P004', 'ING032', '0.08'),
('P004', 'ING044', '0.05'),
('P004', 'ING028', '0.03'),
('P005', 'ING009', '0.10'),
('P005', 'ING002', '0.08'),
('P005', 'ING046', '0.03'),
('P006', 'ING006', '0.20'),
('P006', 'ING026', '0.02'),
('P006', 'ING024', '0.01'),
('P006', 'ING022', '0.01'),
('P007', 'ING032', '0.06'),
('P007', 'ING044', '0.05'),
('P007', 'ING028', '0.03'),
('P007', 'ING002', '0.08'),
('P008', 'ING043', '0.15'),
('P008', 'ING040', '0.05'),
('P008', 'ING022', '0.01'),
('P009', 'ING044', '0.08'),
('P009', 'ING028', '0.03'),
('P009', 'ING047', '0.02'),
('P010', 'ING006', '0.10'),
('P010', 'ING012', '0.03'),
('P010', 'ING033', '0.05'),
('P011', 'ING006', '0.20'),
('P011', 'ING018', '0.15'),
('P011', 'ING010', '0.05'),
('P011', 'ING011', '0.08'),
('P011', 'ING050', '0.02'),
('P011', 'ING028', '0.03'),
('P011', 'ING026', '0.01'),
('P011', 'ING023', '0.01'),
('P011', 'ING022', '0.01'),
('P012', 'ING043', '0.20'),
('P012', 'ING012', '0.03'),
('P012', 'ING011', '0.03'),
('P012', 'ING006', '0.08'),
('P013', 'ING002', '0.18'),
('P013', 'ING043', '0.20'),
('P013', 'ING011', '0.04'),
('P013', 'ING015', '0.02'),
('P014', 'ING002', '0.18'),
('P014', 'ING033', '0.08'),
('P014', 'ING015', '0.02'),
('P014', 'ING026', '0.01'),
('P015', 'ING002', '0.18'),
('P015', 'ING018', '0.15'),
('P015', 'ING010', '0.05'),
('P015', 'ING011', '0.08'),
('P015', 'ING050', '0.02'),
('P015', 'ING028', '0.03'),
('P015', 'ING026', '0.01'),
('P015', 'ING023', '0.01'),
('P016', 'ING045', '0.20'),
('P016', 'ING015', '0.02'),
('P016', 'ING031', '0.04'),
('P016', 'ING028', '0.02'),
('P017', 'ING001', '1.00'),
('P017', 'ING022', '0.02'),
('P017', 'ING023', '0.01'),
('P017', 'ING024', '0.01'),
('P017', 'ING027', '0.02'),
('P018', 'ING002', '0.25'),
('P018', 'ING044', '0.08'),
('P018', 'ING028', '0.10'),
('P018', 'ING022', '0.01'),
('P019', 'ING003', '0.30'),
('P019', 'ING044', '0.08'),
('P019', 'ING028', '0.10'),
('P019', 'ING027', '0.01'),
('P020', 'ING006', '0.18'),
('P020', 'ING043', '0.18'),
('P020', 'ING018', '0.12'),
('P020', 'ING011', '0.03'),
('P021', 'ING043', '0.15'),
('P021', 'ING006', '0.12'),
('P021', 'ING011', '0.03'),
('P021', 'ING026', '0.01'),
('P022', 'ING002', '0.18'),
('P022', 'ING043', '0.20'),
('P022', 'ING011', '0.04'),
('P022', 'ING015', '0.02'),
('P023', 'ING002', '0.20'),
('P023', 'ING044', '0.08'),
('P023', 'ING028', '0.08'),
('P023', 'ING018', '0.18'),
('P024', 'ING001', '0.30'),
('P024', 'ING022', '0.02'),
('P024', 'ING023', '0.01'),
('P024', 'ING026', '0.01'),
('P025', 'ING004', '0.25'),
('P025', 'ING043', '0.15'),
('P025', 'ING011', '0.04'),
('P025', 'ING026', '0.01'),
('P026', 'ING001', '0.30'),
('P026', 'ING022', '0.02'),
('P026', 'ING023', '0.01'),
('P026', 'ING026', '0.01'),
('P027', 'ING002', '0.25'),
('P027', 'ING022', '0.01'),
('P027', 'ING023', '0.01'),
('P027', 'ING028', '0.02'),
('P028', 'ING005', '0.25'),
('P028', 'ING043', '0.20'),
('P028', 'ING028', '0.08'),
('P029', 'ING033', '0.10'),
('P029', 'ING054', '0.10'),
('P029', 'ING051', '0.04'),
('P030', 'ING043', '0.10'),
('P030', 'ING033', '0.15'),
('P030', 'ING051', '0.04'),
('P031', 'ING035', '0.20'),
('P031', 'ING051', '0.04'),
('P032', 'ING044', '0.10'),
('P032', 'ING028', '0.08'),
('P032', 'ING051', '0.03'),
('P033', 'ING044', '0.10'),
('P033', 'ING052', '0.04'),
('P033', 'ING051', '0.05'),
('P033', 'ING058', '2.00'),
('P034', 'ING059', '0.12'),
('P034', 'ING051', '0.04'),
('P034', 'ING056', '0.01'),
('P034', 'ING062', '0.08'),
('P035', 'ING033', '0.10'),
('P035', 'ING057', '0.08'),
('P035', 'ING051', '0.03'),
('P036', 'ING060', '1.00'),
('P037', 'ING035', '0.50'),
('P038', 'ING017', '0.08'),
('P038', 'ING051', '0.03'),
('P039', 'ING036', '0.20'),
('P039', 'ING051', '0.03'),
('P040', 'ING061', '0.02');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.receta t JOIN _src_receta s ON t.id_plato=s.id_plato AND t.id_ingrediente=s.id_ingrediente WHERE t.cantidad_requerida IS DISTINCT FROM s.cantidad_requerida) THEN
 RAISE EXCEPTION 'Conflicto en receta: ID existente con contenido diferente. No se sobrescribe; ejecutar ROLLBACK y revisar.';
 END IF;
END $$;
INSERT INTO public.receta (id_plato, id_ingrediente, cantidad_requerida)
 SELECT id_plato, id_ingrediente, cantidad_requerida FROM _src_receta
 ON CONFLICT (id_plato, id_ingrediente) DO NOTHING;

-- Comprobar que toda la carta recuperada tiene al menos un ingrediente.
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM _src_plato p WHERE NOT EXISTS(SELECT 1 FROM public.receta r WHERE r.id_plato=p.id_plato)) THEN
 RAISE EXCEPTION 'Hay platos originales sin receta'; END IF;
END $$;
COMMIT;

-- Resultados esperados con 04_demo ya cargado: 13, 63, 41, 144.
-- Estas son cantidades TOTALES, incluidos registros demo u otros agregados.
SELECT 'proveedores' tabla,count(*) registros FROM public.proveedor
UNION ALL SELECT 'ingredientes',count(*) FROM public.ingrediente
UNION ALL SELECT 'platos',count(*) FROM public.plato
UNION ALL SELECT 'recetas',count(*) FROM public.receta;

-- Carta recuperada (P001 a P040); los platos demo se conservan aparte.
SELECT id_plato,nombre_plato,categoria,precio FROM public.plato
WHERE id_plato ~ '^P[0-9]{3}$' ORDER BY id_plato;
