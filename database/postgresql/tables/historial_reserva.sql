CREATE TABLE public.historial_reserva (
    id_historial character varying(10) NOT NULL,
    id_reserva character varying(10) NOT NULL,
    estado_anterior character varying(30) NOT NULL,
    estado_nuevo character varying(30) NOT NULL,
    fecha_cambio timestamp without time zone NOT NULL
);
