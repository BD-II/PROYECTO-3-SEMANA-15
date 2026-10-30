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

