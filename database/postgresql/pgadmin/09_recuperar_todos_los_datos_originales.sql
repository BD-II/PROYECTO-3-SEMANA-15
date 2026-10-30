-- Generado: editar fuentes modulares y recompilar.
-- 09_recuperar_todos_los_datos_originales.sql
-- REEMPLAZA al 09_datos_operativos.sql de datos nuevos. No ejecutar aquel 09.
-- Ejecutar COMPLETO en Query Tool, como postgres, en la base V2 ya instalada.
-- Compatible con 04_demo y 08 cargados: conserva esos registros sin duplicarlos.
-- No ejecutar 01 ni 02 otra vez. Recomendacion: guardar backup previo.
-- IMPORTANTE: pedidos PC1 se conservan como historicos protegidos (legado=true).
-- No descuenta stock otra vez ni inventa los consumos antiguos.
-- Las cuatro facturas inconsistentes se conservan y se muestran al final.
-- Si un identificador existente tiene contenido diferente, se aborta toda la carga.
-- No sobrescribe stock existente. Los nuevos ingredientes reciben su saldo PC1.
-- No restaura contrasenas ni rutinas antiguas: conserva las mejoras de V2.
BEGIN;
SET LOCAL search_path=public,pg_catalog;
SET LOCAL standard_conforming_strings=on;
LOCK TABLE public.cliente,public.empleado,public.proveedor,public.ingrediente,
 public.plato,public.receta,public.pedido,public.detalle_pedido,public.factura,
 public.mesa,public.reserva,public.historial_reserva,public.detalle_insumo,
 public.movimiento_inventario IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.schema_version WHERE version=2) THEN
 RAISE EXCEPTION 'Se requiere la base mejorada V2'; END IF;
END $$;

-- Importacion historica controlada: suspender SOLO triggers de negocio,
-- conservando PK, FK, CHECK, UNIQUE y exclusion de reservas activas.
-- La transaccion revierte tambien este cambio si falla la carga.
CREATE TEMP TABLE _original_triggers ON COMMIT DROP AS
SELECT n.nspname,c.relname,t.tgname,t.tgenabled
FROM pg_catalog.pg_trigger t
JOIN pg_catalog.pg_class c ON c.oid=t.tgrelid
JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relname IN ('pedido','detalle_pedido','factura','reserva','historial_reserva')
AND NOT t.tgisinternal;
DO $$ DECLARE r record; BEGIN
 FOR r IN SELECT * FROM _original_triggers LOOP
 EXECUTE format('ALTER TABLE %I.%I DISABLE TRIGGER %I',r.nspname,r.relname,r.tgname);
 END LOOP;
END $$;

-- CLIENTE: 30 registros originales.
CREATE TEMP TABLE _original_cliente (LIKE public.cliente INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_cliente (id_cliente, nombre, apellido, telefono, direccion) VALUES
('C001', 'Juan', 'Perez', '987654321', 'Av. Universitaria 123'),
('C002', 'Maria', 'Lopez', '912345678', 'Jr. Los Olivos 456'),
('C003', 'Carlos', 'Ramirez', '998877665', 'Av. Tupac Amaru 789'),
('C004', 'Ana', 'Torres', '955443322', 'Calle Las Flores 321'),
('C005', 'Luis', 'Gomez', '977665544', 'Av. Lima 654'),
('C006', 'Miguel', 'Rojas', '987111111', 'Av. Peru 101'),
('C007', 'Sofia', 'Vargas', '987111112', 'Jr. Los Pinos 202'),
('C008', 'Diego', 'Mendoza', '987111113', 'Av. Proceres 303'),
('C009', 'Valeria', 'Castro', '987111114', 'Calle Los Cedros 404'),
('C010', 'Fernando', 'Silva', '987111115', 'Av. Central 505'),
('C011', 'Daniela', 'Ruiz', '987111116', 'Jr. Las Palmeras 606'),
('C012', 'Andres', 'Herrera', '987111117', 'Av. Los Alamos 707'),
('C013', 'Camila', 'Flores', '987111118', 'Calle Los Jazmines 808'),
('C014', 'Ricardo', 'Navarro', '987111119', 'Av. Los Girasoles 909'),
('C015', 'Gabriela', 'Paredes', '987111120', 'Jr. San Martin 110'),
('C016', 'Javier', 'Ortega', '987111121', 'Av. Grau 120'),
('C017', 'Paula', 'Sanchez', '987111122', 'Jr. Amazonas 130'),
('C018', 'Luis', 'Vega', '987111123', 'Av. Arequipa 140'),
('C019', 'Andrea', 'Salazar', '987111124', 'Calle Los Robles 150'),
('C020', 'Jose', 'Morales', '987111125', 'Av. Colonial 160'),
('C021', 'Luciana', 'Cruz', '987111126', 'Jr. Libertad 170'),
('C022', 'Martin', 'Aguilar', '987111127', 'Av. Universitaria 180'),
('C023', 'Mariana', 'Delgado', '987111128', 'Calle Primavera 190'),
('C024', 'Alex', 'Espinoza', '987111129', 'Av. El Sol 200'),
('C025', 'Karen', 'Gutierrez', '987111130', 'Jr. Los Sauces 210'),
('C026', 'Kevin', 'Rios', '987111131', 'Av. Los Heroes 220'),
('C027', 'Natalia', 'Campos', '987111132', 'Calle Santa Rosa 230'),
('C028', 'Bruno', 'Valdez', '987111133', 'Av. Metropolitana 240'),
('C029', 'Diana', 'Benites', '987111134', 'Jr. Las Magnolias 250'),
('C030', 'Alvaro', 'Reyes', '987111135', 'Av. Las Americas 260');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.cliente t JOIN _original_cliente s ON t.id_cliente=s.id_cliente WHERE t.nombre IS DISTINCT FROM s.nombre OR t.apellido IS DISTINCT FROM s.apellido OR t.telefono IS DISTINCT FROM s.telefono OR t.direccion IS DISTINCT FROM s.direccion) THEN
 RAISE EXCEPTION 'Conflicto en cliente: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.cliente (id_cliente, nombre, apellido, telefono, direccion)
 SELECT id_cliente, nombre, apellido, telefono, direccion FROM _original_cliente
 ON CONFLICT (id_cliente) DO NOTHING;


-- EMPLEADO: 3 registros originales.
CREATE TEMP TABLE _original_empleado (LIKE public.empleado INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_empleado (id_empleado, nombre_empleado, apellido_empleado, cargo, telefono_empleado) VALUES
('E001', 'Pedro', 'Martinez', 'Cajero', '999111222'),
('E002', 'Lucia', 'Fernandez', 'Mesera', '988222333'),
('E003', 'Jorge', 'Castillo', 'Administrador', '977333444');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.empleado t JOIN _original_empleado s ON t.id_empleado=s.id_empleado WHERE t.nombre_empleado IS DISTINCT FROM s.nombre_empleado OR t.apellido_empleado IS DISTINCT FROM s.apellido_empleado OR t.cargo IS DISTINCT FROM s.cargo OR t.telefono_empleado IS DISTINCT FROM s.telefono_empleado) THEN
 RAISE EXCEPTION 'Conflicto en empleado: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.empleado (id_empleado, nombre_empleado, apellido_empleado, cargo, telefono_empleado)
 SELECT id_empleado, nombre_empleado, apellido_empleado, cargo, telefono_empleado FROM _original_empleado
 ON CONFLICT (id_empleado) DO NOTHING;


-- PROVEEDOR: 12 registros originales.
CREATE TEMP TABLE _original_proveedor (LIKE public.proveedor INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_proveedor (id_proveedor, razon_social, ruc, telefono, contacto) VALUES
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
 IF EXISTS(SELECT 1 FROM public.proveedor t JOIN _original_proveedor s ON t.id_proveedor=s.id_proveedor WHERE t.razon_social IS DISTINCT FROM s.razon_social OR t.ruc IS DISTINCT FROM s.ruc OR t.telefono IS DISTINCT FROM s.telefono OR t.contacto IS DISTINCT FROM s.contacto) THEN
 RAISE EXCEPTION 'Conflicto en proveedor: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.proveedor (id_proveedor, razon_social, ruc, telefono, contacto)
 SELECT id_proveedor, razon_social, ruc, telefono, contacto FROM _original_proveedor
 ON CONFLICT (id_proveedor) DO NOTHING;


-- INGREDIENTE: 62 registros originales.
CREATE TEMP TABLE _original_ingrediente (LIKE public.ingrediente INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_ingrediente (id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida) VALUES
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
 IF EXISTS(SELECT 1 FROM public.ingrediente t JOIN _original_ingrediente s ON t.id_ingrediente=s.id_ingrediente WHERE t.id_proveedor IS DISTINCT FROM s.id_proveedor OR t.nombre_ingrediente IS DISTINCT FROM s.nombre_ingrediente OR t.unidad_medida IS DISTINCT FROM s.unidad_medida) THEN
 RAISE EXCEPTION 'Conflicto en ingrediente: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
WITH nuevos AS (
 INSERT INTO public.ingrediente (id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida)
 SELECT id_ingrediente, id_proveedor, nombre_ingrediente, stock_actual, unidad_medida FROM _original_ingrediente
 ON CONFLICT(id_ingrediente) DO NOTHING RETURNING id_ingrediente,stock_actual
) INSERT INTO public.movimiento_inventario(id_ingrediente,variacion,saldo_resultante,motivo)
 SELECT id_ingrediente,stock_actual,stock_actual,'Saldo inicial PC1; historial anterior no reconstruido' FROM nuevos;


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


-- RECETA: 143 registros originales.
CREATE TEMP TABLE _original_receta (LIKE public.receta INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_receta (id_plato, id_ingrediente, cantidad_requerida) VALUES
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
 IF EXISTS(SELECT 1 FROM public.receta t JOIN _original_receta s ON t.id_plato=s.id_plato AND t.id_ingrediente=s.id_ingrediente WHERE t.cantidad_requerida IS DISTINCT FROM s.cantidad_requerida) THEN
 RAISE EXCEPTION 'Conflicto en receta: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.receta (id_plato, id_ingrediente, cantidad_requerida)
 SELECT id_plato, id_ingrediente, cantidad_requerida FROM _original_receta
 ON CONFLICT (id_plato, id_ingrediente) DO NOTHING;


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


-- DETALLE_PEDIDO: 150 registros originales.
CREATE TEMP TABLE _original_detalle_pedido (LIKE public.detalle_pedido INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_detalle_pedido (id_detalle, id_pedido, id_plato, cantidad, subtotal, precio_unitario) VALUES
('D002', 'PD001', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D003', 'PD001', 'P002', '1', '14.00', ('14.00'::numeric / '1'::numeric)),
('D005', 'PD002', 'P037', '2', '9.00', ('9.00'::numeric / '2'::numeric)),
('D006', 'PD002', 'P029', '1', '9.50', ('9.50'::numeric / '1'::numeric)),
('D007', 'PD003', 'P012', '1', '20.00', ('20.00'::numeric / '1'::numeric)),
('D008', 'PD003', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D009', 'PD003', 'P004', '2', '22.00', ('22.00'::numeric / '2'::numeric)),
('D010', 'PD004', 'P017', '1', '26.00', ('26.00'::numeric / '1'::numeric)),
('D011', 'PD004', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D012', 'PD004', 'P006', '1', '16.00', ('16.00'::numeric / '1'::numeric)),
('D013', 'PD005', 'P018', '1', '32.00', ('32.00'::numeric / '1'::numeric)),
('D014', 'PD005', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D015', 'PD005', 'P031', '2', '14.00', ('14.00'::numeric / '2'::numeric)),
('D016', 'PD006', 'P014', '2', '48.00', ('48.00'::numeric / '2'::numeric)),
('D017', 'PD006', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D018', 'PD006', 'P001', '1', '12.00', ('12.00'::numeric / '1'::numeric)),
('D019', 'PD007', 'P016', '1', '22.00', ('22.00'::numeric / '1'::numeric)),
('D020', 'PD007', 'P037', '2', '9.00', ('9.00'::numeric / '2'::numeric)),
('D021', 'PD007', 'P033', '1', '11.00', ('11.00'::numeric / '1'::numeric)),
('D022', 'PD008', 'P020', '1', '31.00', ('31.00'::numeric / '1'::numeric)),
('D023', 'PD008', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D024', 'PD008', 'P007', '1', '18.00', ('18.00'::numeric / '1'::numeric)),
('D025', 'PD009', 'P022', '1', '24.50', ('24.50'::numeric / '1'::numeric)),
('D026', 'PD009', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D027', 'PD009', 'P009', '2', '18.00', ('18.00'::numeric / '2'::numeric)),
('D028', 'PD010', 'P021', '1', '23.00', ('23.00'::numeric / '1'::numeric)),
('D029', 'PD010', 'P036', '2', '10.00', ('10.00'::numeric / '2'::numeric)),
('D030', 'PD010', 'P034', '1', '12.00', ('12.00'::numeric / '1'::numeric)),
('D031', 'PD011', 'P015', '1', '28.00', ('28.00'::numeric / '1'::numeric)),
('D032', 'PD011', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D033', 'PD011', 'P005', '1', '15.00', ('15.00'::numeric / '1'::numeric)),
('D034', 'PD012', 'P019', '2', '58.00', ('58.00'::numeric / '2'::numeric)),
('D035', 'PD012', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D036', 'PD012', 'P010', '1', '14.50', ('14.50'::numeric / '1'::numeric)),
('D037', 'PD013', 'P023', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D038', 'PD013', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D039', 'PD013', 'P032', '1', '10.00', ('10.00'::numeric / '1'::numeric)),
('D040', 'PD014', 'P026', '1', '36.00', ('36.00'::numeric / '1'::numeric)),
('D041', 'PD014', 'P038', '2', '12.00', ('12.00'::numeric / '2'::numeric)),
('D042', 'PD014', 'P003', '1', '13.50', ('13.50'::numeric / '1'::numeric)),
('D043', 'PD015', 'P024', '1', '35.00', ('35.00'::numeric / '1'::numeric)),
('D044', 'PD015', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D045', 'PD015', 'P035', '1', '8.50', ('8.50'::numeric / '1'::numeric)),
('D046', 'PD016', 'P027', '1', '30.00', ('30.00'::numeric / '1'::numeric)),
('D047', 'PD016', 'P040', '2', '11.00', ('11.00'::numeric / '2'::numeric)),
('D048', 'PD016', 'P008', '1', '10.00', ('10.00'::numeric / '1'::numeric)),
('D049', 'PD017', 'P025', '1', '34.00', ('34.00'::numeric / '1'::numeric)),
('D050', 'PD017', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D051', 'PD017', 'P030', '2', '14.00', ('14.00'::numeric / '2'::numeric)),
('D052', 'PD018', 'P028', '2', '50.00', ('50.00'::numeric / '2'::numeric)),
('D053', 'PD018', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D054', 'PD018', 'P011', '1', '25.00', ('25.00'::numeric / '1'::numeric)),
('D055', 'PD019', 'P021', '1', '23.00', ('23.00'::numeric / '1'::numeric)),
('D056', 'PD019', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D057', 'PD019', 'P034', '1', '12.00', ('12.00'::numeric / '1'::numeric)),
('D058', 'PD020', 'P022', '1', '24.50', ('24.50'::numeric / '1'::numeric)),
('D059', 'PD020', 'P039', '2', '16.00', ('16.00'::numeric / '2'::numeric)),
('D060', 'PD020', 'P006', '1', '16.00', ('16.00'::numeric / '1'::numeric)),
('D061', 'PD021', 'P012', '2', '40.00', ('40.00'::numeric / '2'::numeric)),
('D062', 'PD021', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D063', 'PD021', 'P029', '1', '9.50', ('9.50'::numeric / '1'::numeric)),
('D064', 'PD022', 'P018', '1', '32.00', ('32.00'::numeric / '1'::numeric)),
('D065', 'PD022', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D066', 'PD022', 'P004', '1', '11.00', ('11.00'::numeric / '1'::numeric)),
('D067', 'PD023', 'P016', '2', '44.00', ('44.00'::numeric / '2'::numeric)),
('D068', 'PD023', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D069', 'PD023', 'P001', '1', '12.00', ('12.00'::numeric / '1'::numeric)),
('D070', 'PD024', 'P020', '1', '31.00', ('31.00'::numeric / '1'::numeric)),
('D071', 'PD024', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D072', 'PD024', 'P032', '1', '10.00', ('10.00'::numeric / '1'::numeric)),
('D074', 'PD025', 'P036', '2', '10.00', ('10.00'::numeric / '2'::numeric)),
('D075', 'PD025', 'P031', '1', '7.00', ('7.00'::numeric / '1'::numeric)),
('D076', 'PD026', 'P014', '1', '24.00', ('24.00'::numeric / '1'::numeric)),
('D077', 'PD026', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D078', 'PD026', 'P005', '1', '15.00', ('15.00'::numeric / '1'::numeric)),
('D079', 'PD027', 'P017', '1', '26.00', ('26.00'::numeric / '1'::numeric)),
('D080', 'PD027', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D081', 'PD027', 'P007', '1', '18.00', ('18.00'::numeric / '1'::numeric)),
('D082', 'PD028', 'P019', '1', '29.00', ('29.00'::numeric / '1'::numeric)),
('D083', 'PD028', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D084', 'PD028', 'P033', '1', '11.00', ('11.00'::numeric / '1'::numeric)),
('D085', 'PD029', 'P023', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D086', 'PD029', 'P038', '2', '12.00', ('12.00'::numeric / '2'::numeric)),
('D087', 'PD029', 'P009', '1', '9.00', ('9.00'::numeric / '1'::numeric)),
('D088', 'PD030', 'P024', '1', '35.00', ('35.00'::numeric / '1'::numeric)),
('D089', 'PD030', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D090', 'PD030', 'P002', '1', '14.00', ('14.00'::numeric / '1'::numeric)),
('D091', 'PD031', 'P011', '1', '25.00', ('25.00'::numeric / '1'::numeric)),
('D092', 'PD031', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D093', 'PD031', 'P035', '1', '8.50', ('8.50'::numeric / '1'::numeric)),
('D094', 'PD032', 'P015', '1', '28.00', ('28.00'::numeric / '1'::numeric)),
('D095', 'PD032', 'P036', '2', '10.00', ('10.00'::numeric / '2'::numeric)),
('D096', 'PD032', 'P010', '1', '14.50', ('14.50'::numeric / '1'::numeric)),
('D097', 'PD033', 'P026', '1', '36.00', ('36.00'::numeric / '1'::numeric)),
('D098', 'PD033', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D099', 'PD033', 'P003', '1', '13.50', ('13.50'::numeric / '1'::numeric)),
('D100', 'PD034', 'P021', '1', '23.00', ('23.00'::numeric / '1'::numeric)),
('D101', 'PD034', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D102', 'PD034', 'P030', '1', '7.00', ('7.00'::numeric / '1'::numeric)),
('D103', 'PD035', 'P025', '1', '34.00', ('34.00'::numeric / '1'::numeric)),
('D104', 'PD035', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D105', 'PD035', 'P034', '2', '24.00', ('24.00'::numeric / '2'::numeric)),
('D106', 'PD036', 'P022', '1', '24.50', ('24.50'::numeric / '1'::numeric)),
('D107', 'PD036', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D108', 'PD036', 'P006', '1', '16.00', ('16.00'::numeric / '1'::numeric)),
('D109', 'PD037', 'P027', '1', '30.00', ('30.00'::numeric / '1'::numeric)),
('D110', 'PD037', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D111', 'PD037', 'P008', '1', '10.00', ('10.00'::numeric / '1'::numeric)),
('D112', 'PD038', 'P028', '1', '25.00', ('25.00'::numeric / '1'::numeric)),
('D113', 'PD038', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D114', 'PD038', 'P029', '1', '9.50', ('9.50'::numeric / '1'::numeric)),
('D115', 'PD039', 'P020', '1', '31.00', ('31.00'::numeric / '1'::numeric)),
('D116', 'PD039', 'P037', '2', '9.00', ('9.00'::numeric / '2'::numeric)),
('D117', 'PD039', 'P001', '1', '12.00', ('12.00'::numeric / '1'::numeric)),
('D118', 'PD040', 'P016', '1', '22.00', ('22.00'::numeric / '1'::numeric)),
('D119', 'PD040', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D120', 'PD040', 'P032', '1', '10.00', ('10.00'::numeric / '1'::numeric)),
('D122', 'PD041', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D123', 'PD041', 'P035', '1', '8.50', ('8.50'::numeric / '1'::numeric)),
('D124', 'PD042', 'P014', '1', '24.00', ('24.00'::numeric / '1'::numeric)),
('D125', 'PD042', 'P039', '1', '8.00', ('8.00'::numeric / '1'::numeric)),
('D126', 'PD042', 'P004', '1', '11.00', ('11.00'::numeric / '1'::numeric)),
('D127', 'PD043', 'P019', '1', '29.00', ('29.00'::numeric / '1'::numeric)),
('D128', 'PD043', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D129', 'PD043', 'P031', '1', '7.00', ('7.00'::numeric / '1'::numeric)),
('D130', 'PD044', 'P018', '1', '32.00', ('32.00'::numeric / '1'::numeric)),
('D131', 'PD044', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D132', 'PD044', 'P007', '1', '18.00', ('18.00'::numeric / '1'::numeric)),
('D133', 'PD045', 'P017', '1', '26.00', ('26.00'::numeric / '1'::numeric)),
('D134', 'PD045', 'P036', '2', '10.00', ('10.00'::numeric / '2'::numeric)),
('D135', 'PD045', 'P033', '1', '11.00', ('11.00'::numeric / '1'::numeric)),
('D136', 'PD046', 'P012', '1', '20.00', ('20.00'::numeric / '1'::numeric)),
('D001', 'PD001', 'P011', '4', '50.00', ('50.00'::numeric / '4'::numeric)),
('D137', 'PD046', 'P038', '1', '6.00', ('6.00'::numeric / '1'::numeric)),
('D138', 'PD046', 'P005', '1', '15.00', ('15.00'::numeric / '1'::numeric)),
('D139', 'PD047', 'P023', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D140', 'PD047', 'P037', '1', '4.50', ('4.50'::numeric / '1'::numeric)),
('D141', 'PD047', 'P002', '1', '14.00', ('14.00'::numeric / '1'::numeric)),
('D142', 'PD048', 'P024', '1', '35.00', ('35.00'::numeric / '1'::numeric)),
('D143', 'PD048', 'P039', '2', '16.00', ('16.00'::numeric / '2'::numeric)),
('D144', 'PD048', 'P009', '1', '9.00', ('9.00'::numeric / '1'::numeric)),
('D145', 'PD049', 'P011', '1', '25.00', ('25.00'::numeric / '1'::numeric)),
('D146', 'PD049', 'P036', '1', '5.00', ('5.00'::numeric / '1'::numeric)),
('D147', 'PD049', 'P029', '1', '9.50', ('9.50'::numeric / '1'::numeric)),
('D148', 'PD050', 'P026', '1', '36.00', ('36.00'::numeric / '1'::numeric)),
('D149', 'PD050', 'P040', '1', '5.50', ('5.50'::numeric / '1'::numeric)),
('D004', 'PD002', 'P013', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D073', 'PD025', 'P013', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D121', 'PD041', 'P013', '1', '27.00', ('27.00'::numeric / '1'::numeric)),
('D150', 'PD050', 'P029', '2', '19.00', ('19.00'::numeric / '2'::numeric));
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.detalle_pedido t JOIN _original_detalle_pedido s ON t.id_detalle=s.id_detalle WHERE t.id_pedido IS DISTINCT FROM s.id_pedido OR t.id_plato IS DISTINCT FROM s.id_plato OR t.cantidad IS DISTINCT FROM s.cantidad OR t.subtotal IS DISTINCT FROM s.subtotal OR t.precio_unitario IS DISTINCT FROM s.precio_unitario) THEN
 RAISE EXCEPTION 'Conflicto en detalle_pedido: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
INSERT INTO public.detalle_pedido (id_detalle, id_pedido, id_plato, cantidad, subtotal, precio_unitario)
 SELECT id_detalle, id_pedido, id_plato, cantidad, subtotal, precio_unitario FROM _original_detalle_pedido
 ON CONFLICT (id_detalle) DO NOTHING;


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


-- RESERVA: 101 registros originales.
CREATE TEMP TABLE _original_reserva (LIKE public.reserva INCLUDING DEFAULTS) ON COMMIT DROP;
INSERT INTO _original_reserva (id_reserva, id_cliente, fecha_reserva, numero_mesa, cantidad_personas, estado_reserva) VALUES
('R001', 'C001', '2026-08-01 12:30:00', '1', '2', 'Atendida'),
('R002', 'C002', '2026-08-01 13:00:00', '5', '4', 'Atendida'),
('R003', 'C003', '2026-08-01 13:30:00', '8', '3', 'Atendida'),
('R004', 'C004', '2026-08-01 14:00:00', '12', '6', 'Atendida'),
('R005', 'C005', '2026-08-01 19:00:00', '3', '2', 'Atendida'),
('R006', 'C006', '2026-08-01 19:30:00', '7', '5', 'Atendida'),
('R007', 'C007', '2026-08-01 20:00:00', '10', '4', 'Atendida'),
('R008', 'C008', '2026-08-01 20:30:00', '15', '8', 'Atendida'),
('R009', 'C009', '2026-08-01 21:00:00', '2', '3', 'Atendida'),
('R010', 'C010', '2026-08-01 21:30:00', '6', '2', 'Atendida'),
('R011', 'C011', '2026-08-02 12:00:00', '4', '4', 'Atendida'),
('R012', 'C012', '2026-08-02 12:30:00', '9', '2', 'Atendida'),
('R013', 'C013', '2026-08-02 13:00:00', '13', '5', 'Atendida'),
('R014', 'C014', '2026-08-02 13:30:00', '16', '3', 'Atendida'),
('R015', 'C015', '2026-08-02 14:00:00', '18', '6', 'Atendida'),
('R016', 'C016', '2026-08-02 19:00:00', '1', '2', 'Atendida'),
('R017', 'C017', '2026-08-02 19:30:00', '5', '7', 'Atendida'),
('R018', 'C018', '2026-08-02 20:00:00', '8', '4', 'Atendida'),
('R019', 'C019', '2026-08-02 20:30:00', '11', '3', 'Atendida'),
('R020', 'C020', '2026-08-02 21:00:00', '14', '5', 'Atendida'),
('R021', 'C021', '2026-08-03 12:00:00', '2', '2', 'Atendida'),
('R022', 'C022', '2026-08-03 12:30:00', '6', '4', 'Atendida'),
('R023', 'C023', '2026-08-03 13:00:00', '10', '6', 'Atendida'),
('R024', 'C024', '2026-08-03 13:30:00', '14', '3', 'Atendida'),
('R025', 'C025', '2026-08-03 14:00:00', '17', '2', 'Atendida'),
('R026', 'C026', '2026-08-03 19:00:00', '3', '5', 'Atendida'),
('R027', 'C027', '2026-08-03 19:30:00', '7', '4', 'Atendida'),
('R028', 'C028', '2026-08-03 20:00:00', '12', '8', 'Atendida'),
('R029', 'C029', '2026-08-03 20:30:00', '15', '3', 'Atendida'),
('R030', 'C030', '2026-08-03 21:00:00', '19', '2', 'Atendida'),
('R031', 'C001', '2026-08-04 12:30:00', '4', '3', 'Atendida'),
('R032', 'C003', '2026-08-04 13:00:00', '8', '5', 'Atendida'),
('R033', 'C005', '2026-08-04 13:30:00', '11', '2', 'Atendida'),
('R034', 'C007', '2026-08-04 14:00:00', '16', '4', 'Atendida'),
('R035', 'C009', '2026-08-04 19:00:00', '2', '6', 'Atendida'),
('R036', 'C011', '2026-08-04 19:30:00', '5', '3', 'Atendida'),
('R037', 'C013', '2026-08-04 20:00:00', '9', '5', 'Atendida'),
('R038', 'C015', '2026-08-04 20:30:00', '13', '2', 'Atendida'),
('R039', 'C017', '2026-08-04 21:00:00', '17', '4', 'Atendida'),
('R040', 'C019', '2026-08-04 21:30:00', '20', '7', 'Atendida'),
('R041', 'C002', '2026-08-05 12:00:00', '1', '2', 'Atendida'),
('R042', 'C004', '2026-08-05 12:30:00', '6', '5', 'Atendida'),
('R043', 'C006', '2026-08-05 13:00:00', '10', '4', 'Atendida'),
('R044', 'C008', '2026-08-05 13:30:00', '14', '3', 'Atendida'),
('R045', 'C010', '2026-08-05 19:00:00', '18', '6', 'Atendida'),
('R046', 'C012', '2026-08-05 19:30:00', '3', '2', 'Atendida'),
('R047', 'C014', '2026-08-05 20:00:00', '7', '5', 'Atendida'),
('R048', 'C016', '2026-08-05 20:30:00', '12', '4', 'Atendida'),
('R049', 'C018', '2026-08-05 21:00:00', '15', '3', 'Atendida'),
('R050', 'C020', '2026-08-05 21:30:00', '19', '8', 'Atendida'),
('R051', 'C021', '2026-08-06 12:00:00', '2', '3', 'Confirmada'),
('R052', 'C022', '2026-08-06 12:30:00', '5', '4', 'Confirmada'),
('R053', 'C023', '2026-08-06 13:00:00', '9', '2', 'Confirmada'),
('R054', 'C024', '2026-08-06 13:30:00', '13', '6', 'Confirmada'),
('R055', 'C025', '2026-08-06 14:00:00', '17', '5', 'Confirmada'),
('R056', 'C026', '2026-08-06 19:00:00', '1', '2', 'Confirmada'),
('R057', 'C027', '2026-08-06 19:30:00', '6', '4', 'Confirmada'),
('R058', 'C028', '2026-08-06 20:00:00', '10', '7', 'Confirmada'),
('R059', 'C029', '2026-08-06 20:30:00', '14', '3', 'Confirmada'),
('R060', 'C030', '2026-08-06 21:00:00', '18', '5', 'Confirmada'),
('R061', 'C001', '2026-08-07 12:30:00', '3', '2', 'Confirmada'),
('R062', 'C004', '2026-08-07 13:00:00', '8', '4', 'Confirmada'),
('R063', 'C007', '2026-08-07 13:30:00', '12', '6', 'Confirmada'),
('R064', 'C010', '2026-08-07 19:00:00', '16', '3', 'Confirmada'),
('R065', 'C013', '2026-08-07 19:30:00', '20', '5', 'Confirmada'),
('R067', 'C005', '2026-08-08 12:30:00', '7', '2', 'Pendiente'),
('R068', 'C008', '2026-08-08 13:00:00', '11', '5', 'Pendiente'),
('R069', 'C011', '2026-08-08 19:00:00', '15', '3', 'Pendiente'),
('R070', 'C014', '2026-08-08 19:30:00', '19', '6', 'Pendiente'),
('R071', 'C017', '2026-08-09 12:00:00', '2', '2', 'Pendiente'),
('R072', 'C020', '2026-08-09 13:00:00', '6', '4', 'Pendiente'),
('R073', 'C023', '2026-08-09 19:00:00', '9', '5', 'Pendiente'),
('R074', 'C026', '2026-08-09 20:00:00', '13', '3', 'Pendiente'),
('R075', 'C029', '2026-08-09 20:30:00', '17', '7', 'Pendiente'),
('R076', 'C003', '2026-08-10 12:30:00', '1', '3', 'Cancelada'),
('R077', 'C006', '2026-08-10 13:00:00', '5', '2', 'Cancelada'),
('R078', 'C009', '2026-08-10 19:00:00', '8', '4', 'Cancelada'),
('R079', 'C012', '2026-08-10 20:00:00', '12', '6', 'Cancelada'),
('R080', 'C015', '2026-08-10 21:00:00', '16', '3', 'Cancelada'),
('R081', 'C018', '2026-08-11 12:00:00', '3', '5', 'Cancelada'),
('R082', 'C021', '2026-08-11 13:30:00', '7', '2', 'Cancelada'),
('R083', 'C024', '2026-08-11 19:30:00', '10', '4', 'Cancelada'),
('R084', 'C027', '2026-08-11 20:30:00', '14', '3', 'Cancelada'),
('R085', 'C030', '2026-08-11 21:00:00', '18', '5', 'Cancelada'),
('R086', 'C002', '2026-08-12 12:00:00', '4', '2', 'Pendiente'),
('R087', 'C006', '2026-08-12 13:00:00', '8', '6', 'Confirmada'),
('R088', 'C010', '2026-08-12 19:00:00', '11', '4', 'Pendiente'),
('R089', 'C014', '2026-08-12 20:00:00', '15', '3', 'Confirmada'),
('R090', 'C018', '2026-08-12 21:00:00', '19', '7', 'Pendiente'),
('R091', 'C003', '2026-08-13 12:30:00', '2', '4', 'Confirmada'),
('R092', 'C007', '2026-08-13 13:30:00', '6', '2', 'Pendiente'),
('R093', 'C011', '2026-08-13 19:00:00', '10', '5', 'Confirmada'),
('R094', 'C015', '2026-08-13 20:00:00', '13', '3', 'Pendiente'),
('R095', 'C019', '2026-08-13 21:00:00', '17', '6', 'Confirmada'),
('R096', 'C004', '2026-08-14 12:00:00', '1', '2', 'Pendiente'),
('R097', 'C008', '2026-08-14 13:00:00', '5', '4', 'Confirmada'),
('R098', 'C012', '2026-08-14 19:30:00', '9', '5', 'Pendiente'),
('R100', 'C020', '2026-08-14 21:00:00', '18', '8', 'Pendiente'),
('R066', 'C002', '2026-08-08 12:00:00', '4', '4', 'Confirmada'),
('R099', 'C016', '2026-08-14 20:30:00', '14', '3', 'Cancelada'),
('R101', 'C001', '2026-09-06 19:54:45.272152', '5', '4', 'Confirmada');
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.reserva t JOIN _original_reserva s ON t.id_reserva=s.id_reserva WHERE t.id_cliente IS DISTINCT FROM s.id_cliente OR t.fecha_reserva IS DISTINCT FROM s.fecha_reserva OR t.numero_mesa IS DISTINCT FROM s.numero_mesa OR t.cantidad_personas IS DISTINCT FROM s.cantidad_personas OR t.estado_reserva IS DISTINCT FROM s.estado_reserva) THEN
 RAISE EXCEPTION 'Conflicto en reserva: un ID existente tiene datos distintos del respaldo original. Ejecutar ROLLBACK y revisar; no se sobrescribe.';
 END IF;
END $$;
-- Capacidades provisionales: maximo historico, confirmar con el negocio.
INSERT INTO public.mesa(numero_mesa,capacidad)
 SELECT numero_mesa,max(cantidad_personas) FROM _original_reserva GROUP BY numero_mesa
 ON CONFLICT(numero_mesa) DO NOTHING;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM _original_reserva r JOIN public.mesa m USING(numero_mesa) WHERE r.cantidad_personas>m.capacidad) THEN
 RAISE EXCEPTION 'Una mesa existente tiene capacidad inferior a una reserva original. Revisar antes de importar.'; END IF;
END $$;
INSERT INTO public.reserva (id_reserva, id_cliente, fecha_reserva, numero_mesa, cantidad_personas, estado_reserva)
 SELECT id_reserva, id_cliente, fecha_reserva, numero_mesa, cantidad_personas, estado_reserva FROM _original_reserva
 ON CONFLICT (id_reserva) DO NOTHING;


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


-- Restaurar exactamente el estado previo de los triggers de negocio.
DO $$ DECLARE r record; accion text; BEGIN
 FOR r IN SELECT * FROM _original_triggers LOOP
 accion=CASE r.tgenabled WHEN 'D' THEN 'DISABLE' WHEN 'R' THEN 'ENABLE REPLICA'
 WHEN 'A' THEN 'ENABLE ALWAYS' ELSE 'ENABLE' END;
 EXECUTE format('ALTER TABLE %I.%I %s TRIGGER %I',r.nspname,r.relname,accion,r.tgname);
 END LOOP;
END $$;

-- Continuar la numeracion del historial sin colisiones con H001 y H002.
SELECT setval('public.seq_historial_reserva',greatest(
 (SELECT last_value FROM public.seq_historial_reserva),
 coalesce((SELECT max(substring(id_historial from '^H([0-9]+)$')::bigint) FROM public.historial_reserva),0),1),true);

-- Cantidades de registros ORIGINALES recuperados (no incluyen los demo).
SELECT 'cliente' tabla,count(*) recuperados,30 esperados FROM public.cliente t JOIN _original_cliente s USING(id_cliente)
UNION ALL SELECT 'empleado',count(*),3 FROM public.empleado t JOIN _original_empleado s USING(id_empleado)
UNION ALL SELECT 'proveedor',count(*),12 FROM public.proveedor t JOIN _original_proveedor s USING(id_proveedor)
UNION ALL SELECT 'ingrediente',count(*),62 FROM public.ingrediente t JOIN _original_ingrediente s USING(id_ingrediente)
UNION ALL SELECT 'plato',count(*),40 FROM public.plato t JOIN _original_plato s USING(id_plato)
UNION ALL SELECT 'receta',count(*),143 FROM public.receta t JOIN _original_receta s USING(id_plato,id_ingrediente)
UNION ALL SELECT 'pedido',count(*),50 FROM public.pedido t JOIN _original_pedido s USING(id_pedido)
UNION ALL SELECT 'detalle_pedido',count(*),150 FROM public.detalle_pedido t JOIN _original_detalle_pedido s USING(id_detalle)
UNION ALL SELECT 'factura',count(*),41 FROM public.factura t JOIN _original_factura s USING(id_factura)
UNION ALL SELECT 'reserva',count(*),101 FROM public.reserva t JOIN _original_reserva s USING(id_reserva)
UNION ALL SELECT 'historial_reserva',count(*),2 FROM public.historial_reserva t JOIN _original_historial_reserva s USING(id_historial);

COMMIT;

-- DIAGNOSTICO: 4 diferencias originales conocidas, conservadas sin inventar causas.
-- No significan fallo de instalacion ni deben corregirse sin revision del equipo.
SELECT f.id_factura,f.id_pedido,f.total_pagado,
 public.fn_calcular_total_pedido(f.id_pedido) total_detalles
FROM public.factura f JOIN public.pedido p USING(id_pedido)
WHERE p.legado AND f.total_pagado<>public.fn_calcular_total_pedido(f.id_pedido)
ORDER BY f.id_factura;

-- Pedidos originales pendientes/en preparacion: quedan consultables y protegidos.
-- Para continuar su atencion hay que conciliar inventario y consumo original.
SELECT id_pedido,estado,legado FROM public.pedido WHERE legado AND estado IN (0,1) ORDER BY id_pedido;

-- Carta original; precios, recetas y stock siguen siendo responsabilidad de PostgreSQL.
SELECT id_plato,nombre_plato,categoria,precio FROM public.plato ORDER BY id_plato;
-- Finalmente, generar un NUEVO backup para incluir los datos recuperados.
