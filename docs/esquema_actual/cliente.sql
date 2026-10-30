-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.cliente (
  id_cliente character varying(10) NOT NULL,
  nombre character varying(100) NOT NULL,
  apellido character varying(100) NOT NULL,
  telefono character varying(20) NOT NULL,
  direccion character varying(200) NOT NULL,
  CONSTRAINT cliente_apellido_not_null NOT NULL apellido,
  CONSTRAINT cliente_direccion_not_null NOT NULL direccion,
  CONSTRAINT cliente_id_cliente_not_null NOT NULL id_cliente,
  CONSTRAINT cliente_nombre_not_null NOT NULL nombre,
  CONSTRAINT cliente_telefono_not_null NOT NULL telefono,
  CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente)
);
