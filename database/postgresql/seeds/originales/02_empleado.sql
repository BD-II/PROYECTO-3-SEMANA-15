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

