-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.empleado (
  id_empleado character varying(10) NOT NULL,
  nombre_empleado character varying(100) NOT NULL,
  apellido_empleado character varying(100) NOT NULL,
  cargo character varying(40) NOT NULL,
  telefono_empleado character varying(20) NOT NULL,
  CONSTRAINT empleado_apellido_empleado_not_null NOT NULL apellido_empleado,
  CONSTRAINT empleado_cargo_not_null NOT NULL cargo,
  CONSTRAINT empleado_id_empleado_not_null NOT NULL id_empleado,
  CONSTRAINT empleado_nombre_empleado_not_null NOT NULL nombre_empleado,
  CONSTRAINT empleado_telefono_empleado_not_null NOT NULL telefono_empleado,
  CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado)
);
