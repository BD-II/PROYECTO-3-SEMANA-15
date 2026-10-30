-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.historial_reserva (
  id_historial character varying(10) DEFAULT ('H'::text || (nextval('seq_historial_reserva'::regclass))::text) NOT NULL,
  id_reserva character varying(10) NOT NULL,
  estado_anterior character varying(30) NOT NULL,
  estado_nuevo character varying(30) NOT NULL,
  fecha_cambio timestamp without time zone NOT NULL,
  CONSTRAINT fk_historial_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
  CONSTRAINT historial_reserva_estado_anterior_not_null NOT NULL estado_anterior,
  CONSTRAINT historial_reserva_estado_nuevo_not_null NOT NULL estado_nuevo,
  CONSTRAINT historial_reserva_fecha_cambio_not_null NOT NULL fecha_cambio,
  CONSTRAINT historial_reserva_id_historial_not_null NOT NULL id_historial,
  CONSTRAINT historial_reserva_id_reserva_not_null NOT NULL id_reserva,
  CONSTRAINT historial_reserva_pkey PRIMARY KEY (id_historial)
);
