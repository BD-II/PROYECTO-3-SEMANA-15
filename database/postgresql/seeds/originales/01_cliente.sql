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

