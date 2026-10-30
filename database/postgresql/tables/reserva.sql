CREATE TABLE public.reserva (
    id_reserva character varying(10) NOT NULL,
    id_cliente character varying(10) NOT NULL,
    fecha_reserva timestamp without time zone NOT NULL,
    numero_mesa integer NOT NULL,
    cantidad_personas integer NOT NULL,
    estado_reserva character varying(30) NOT NULL,
    CONSTRAINT chk_reserva_estado CHECK (((estado_reserva)::text = ANY (ARRAY[('Pendiente'::character varying)::text, ('Confirmada'::character varying)::text, ('Cancelada'::character varying)::text, ('Atendida'::character varying)::text]))),
    CONSTRAINT chk_reserva_mesa CHECK ((numero_mesa > 0)),
    CONSTRAINT chk_reserva_personas CHECK ((cantidad_personas > 0))
);
