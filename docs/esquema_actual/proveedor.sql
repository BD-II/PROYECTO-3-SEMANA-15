-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.proveedor (
  id_proveedor character varying(10) NOT NULL,
  razon_social character varying(100) NOT NULL,
  ruc character varying(11) NOT NULL,
  telefono character varying(20) NOT NULL,
  contacto character varying(100) NOT NULL,
  CONSTRAINT proveedor_contacto_not_null NOT NULL contacto,
  CONSTRAINT proveedor_id_proveedor_not_null NOT NULL id_proveedor,
  CONSTRAINT proveedor_razon_social_not_null NOT NULL razon_social,
  CONSTRAINT proveedor_ruc_not_null NOT NULL ruc,
  CONSTRAINT proveedor_telefono_not_null NOT NULL telefono,
  CONSTRAINT proveedor_pkey PRIMARY KEY (id_proveedor),
  CONSTRAINT proveedor_ruc_key UNIQUE (ruc)
);
