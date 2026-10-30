-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.plato (
  id_plato character varying(10) NOT NULL,
  nombre_plato character varying(50) NOT NULL,
  categoria character varying(30) NOT NULL,
  precio numeric(8,2) NOT NULL,
  CONSTRAINT plato_precio_valido CHECK ((precio >= (0)::numeric)),
  CONSTRAINT plato_categoria_not_null NOT NULL categoria,
  CONSTRAINT plato_id_plato_not_null NOT NULL id_plato,
  CONSTRAINT plato_nombre_plato_not_null NOT NULL nombre_plato,
  CONSTRAINT plato_precio_not_null NOT NULL precio,
  CONSTRAINT plato_pkey PRIMARY KEY (id_plato)
);
