-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.pedido (
  id_pedido character varying(10) NOT NULL,
  id_empleado character varying(10) NOT NULL,
  id_cliente character varying(10) NOT NULL,
  fecha timestamp without time zone NOT NULL,
  tipo_pedido character varying(20) NOT NULL,
  estado integer NOT NULL,
  legado boolean DEFAULT false NOT NULL,
  CONSTRAINT chk_pedido_estado CHECK ((estado = ANY (ARRAY[0, 1, 2, 3]))),
  CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  CONSTRAINT pedido_estado_not_null NOT NULL estado,
  CONSTRAINT pedido_fecha_not_null NOT NULL fecha,
  CONSTRAINT pedido_id_cliente_not_null NOT NULL id_cliente,
  CONSTRAINT pedido_id_empleado_not_null NOT NULL id_empleado,
  CONSTRAINT pedido_id_pedido_not_null NOT NULL id_pedido,
  CONSTRAINT pedido_legado_not_null NOT NULL legado,
  CONSTRAINT pedido_tipo_pedido_not_null NOT NULL tipo_pedido,
  CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido)
);
