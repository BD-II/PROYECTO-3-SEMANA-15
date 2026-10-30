-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.reserva (
  id_reserva character varying(10) NOT NULL,
  id_cliente character varying(10) NOT NULL,
  fecha_reserva timestamp without time zone NOT NULL,
  numero_mesa integer NOT NULL,
  cantidad_personas integer NOT NULL,
  estado_reserva character varying(30) NOT NULL,
  duracion_minutos integer DEFAULT 120 NOT NULL,
  CONSTRAINT chk_reserva_estado CHECK (((estado_reserva)::text = ANY (ARRAY[('Pendiente'::character varying)::text, ('Confirmada'::character varying)::text, ('Cancelada'::character varying)::text, ('Atendida'::character varying)::text]))),
  CONSTRAINT chk_reserva_mesa CHECK ((numero_mesa > 0)),
  CONSTRAINT chk_reserva_personas CHECK ((cantidad_personas > 0)),
  CONSTRAINT reserva_duracion_minutos_check CHECK (((duracion_minutos >= 15) AND (duracion_minutos <= 720))),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT reserva_mesa_fk FOREIGN KEY (numero_mesa) REFERENCES mesa(numero_mesa),
  CONSTRAINT reserva_cantidad_personas_not_null NOT NULL cantidad_personas,
  CONSTRAINT reserva_duracion_minutos_not_null NOT NULL duracion_minutos,
  CONSTRAINT reserva_estado_reserva_not_null NOT NULL estado_reserva,
  CONSTRAINT reserva_fecha_reserva_not_null NOT NULL fecha_reserva,
  CONSTRAINT reserva_id_cliente_not_null NOT NULL id_cliente,
  CONSTRAINT reserva_id_reserva_not_null NOT NULL id_reserva,
  CONSTRAINT reserva_numero_mesa_not_null NOT NULL numero_mesa,
  CONSTRAINT reserva_pkey PRIMARY KEY (id_reserva),
  CONSTRAINT reserva_sin_cruces EXCLUDE USING gist (int4range(numero_mesa, numero_mesa, '[]'::text) WITH &&, tsrange(fecha_reserva, (fecha_reserva + make_interval(mins => duracion_minutos)), '[)'::text) WITH &&) WHERE (((estado_reserva)::text = ANY ((ARRAY['Pendiente'::character varying, 'Confirmada'::character varying])::text[])))
);
