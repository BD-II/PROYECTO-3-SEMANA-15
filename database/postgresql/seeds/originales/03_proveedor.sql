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

