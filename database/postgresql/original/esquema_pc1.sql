-- Referencia extraida del catalogo del dump. Sin datos ni roles. NO ejecutar sobre v2.
CREATE FUNCTION public.fn_ajustar_stock_actualizado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Ingrediente i
    SET Stock_Actual =
        Stock_Actual - (
            r.Cantidad_Requerida * (NEW.Cantidad - OLD.Cantidad)
        )
    FROM Receta r
    WHERE r.ID_Plato = NEW.ID_Plato
      AND i.ID_Ingrediente = r.ID_Ingrediente;

    RETURN NEW;

END; $$;

CREATE FUNCTION public.fn_calcular_total_pedido(pe_id_pedido character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

DECLARE v_total numeric(10,2);

BEGIN
	SELECT COALESCE(SUM(dp.Subtotal),0) INTO v_total
	FROM Detalle_Pedido dp
	WHERE dp.ID_Pedido = pe_id_pedido;

	RETURN v_total;
	
END;$$;

CREATE FUNCTION public.fn_calcularperdidaporcancelacion() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    TotalPerdido NUMERIC(8,2);
BEGIN
    SELECT COALESCE(SUM(dp.Subtotal), 0) INTO TotalPerdido
    FROM Pedido p
    INNER JOIN Detalle_pedido dp ON p.ID_Pedido = dp.ID_Pedido
    WHERE p.Estado = 3;

    RETURN TotalPerdido;
END;
$$;

CREATE FUNCTION public.fn_descontar_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE Ingrediente i
    SET Stock_Actual =
        Stock_Actual - (r.Cantidad_Requerida * NEW.Cantidad)
    FROM Receta r
    WHERE r.ID_Plato = NEW.ID_Plato
      AND i.ID_Ingrediente = r.ID_Ingrediente;

    RETURN NEW;

END; $$;

CREATE FUNCTION public.fn_ingredientes_stock_bajo(p_stock_minimo numeric) RETURNS TABLE(id_ingrediente character varying, nombre_ingrediente character varying, stock_actual numeric, unidad_medida character varying, id_proveedor character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY
    SELECT
        i.ID_Ingrediente,
        i.Nombre_Ingrediente,
        i.Stock_Actual,
        i.Unidad_Medida,
        i.ID_Proveedor
    FROM Ingrediente AS i
    WHERE i.Stock_Actual <= p_stock_minimo
    ORDER BY i.Stock_Actual ASC;

END;
$$;

CREATE FUNCTION public.fn_normalizar_estado_reserva() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Estado_Reserva := INITCAP(LOWER(NEW.Estado_Reserva));
    RETURN NEW;
END; $$;

CREATE FUNCTION public.fn_registrar_historial_reserva() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO Historial_Reserva(
        ID_Historial,
        ID_Reserva,
        Estado_Anterior,
        Estado_Nuevo,
        Fecha_Cambio
    )
    VALUES(
        'H' || LPAD(nextval('seq_historial_reserva')::text, 3, '0'),
        NEW.ID_Reserva,
        OLD.Estado_Reserva,
        NEW.Estado_Reserva,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;

END; $$;

CREATE FUNCTION public.fn_resumen_pedido(pe_id_pedido character varying) RETURNS TABLE(id_pedido character varying, id_cliente character varying, fecha timestamp without time zone, tipo_pedido character varying, estado integer, cantidad_platos bigint, total_pedido numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY
    SELECT
        pe.ID_Pedido,
        pe.ID_Cliente,
        pe.Fecha,
        pe.Tipo_Pedido,
        pe.Estado,
        COALESCE(SUM(dp.Cantidad), 0),
        COALESCE(SUM(dp.Cantidad * p.Precio), 0)
    FROM Pedido pe
    LEFT JOIN Detalle_Pedido dp
        ON pe.ID_Pedido = dp.ID_Pedido
    LEFT JOIN Plato p
        ON dp.ID_Plato = p.ID_Plato
    WHERE pe.ID_Pedido = pe_id_pedido
    GROUP BY
        pe.ID_Pedido,
        pe.ID_Cliente,
        pe.Fecha,
        pe.Tipo_Pedido,
        pe.Estado;

END;
$$;

CREATE PROCEDURE public.sp_actualizar_estado_reserva(IN p_id_reserva character varying, IN p_nuevo_estado character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

    -- Validamos que el estado sea permitido
    IF LOWER(p_nuevo_estado) NOT IN (
        'pendiente',
        'confirmada',
        'cancelada',
        'atendida'
    ) THEN

        RAISE EXCEPTION 'Estado de reserva no válido: %', p_nuevo_estado;

    END IF;

    -- Verificamos que la reserva exista
    IF NOT EXISTS (
        SELECT 1
        FROM Reserva
        WHERE ID_Reserva = p_id_reserva
    ) THEN

        RAISE EXCEPTION 'No existe la reserva con ID %', p_id_reserva;

    END IF;

    -- Actualizamos el estado
    UPDATE Reserva
    SET Estado_Reserva = INITCAP(LOWER(p_nuevo_estado))
    WHERE ID_Reserva = p_id_reserva;

    RAISE NOTICE 'La reserva % ahora tiene estado: %.', p_id_reserva, p_nuevo_estado;

EXCEPTION
    WHEN OTHERS THEN

        RAISE EXCEPTION 'No se pudo actualizar la reserva %: %', p_id_reserva, SQLERRM;

END; $$;

CREATE PROCEDURE public.sp_actualizar_stock(IN p_id_ingrediente character varying, IN p_nuevo_stock numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF p_nuevo_stock < 0 THEN
        RAISE EXCEPTION 'El stock no puede ser negativo. Valor recibido: %', p_nuevo_stock;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Ingrediente
        WHERE ID_Ingrediente = p_id_ingrediente
    ) THEN
        RAISE EXCEPTION 'No existe el ingrediente con ID %', p_id_ingrediente;
    END IF;

    UPDATE Ingrediente
    SET Stock_Actual = p_nuevo_stock
    WHERE ID_Ingrediente = p_id_ingrediente;

    RAISE NOTICE 'Stock del ingrediente % actualizado a %.', p_id_ingrediente, p_nuevo_stock;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al actualizar el stock del ingrediente %: %', p_id_ingrediente, SQLERRM;
END; $$;

CREATE PROCEDURE public.sp_eliminar_detalle_pedido(IN p_id_detalle character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

    -- Verificamos que el detalle exista
    IF NOT EXISTS (
        SELECT 1
        FROM Detalle_Pedido
        WHERE ID_Detalle = p_id_detalle
    ) THEN
        RAISE EXCEPTION 'No existe el detalle de pedido con ID %', p_id_detalle;
    END IF;

    -- Eliminamos el detalle
    DELETE FROM Detalle_Pedido
    WHERE ID_Detalle = p_id_detalle;

    RAISE NOTICE 'Detalle de pedido % eliminado correctamente.', p_id_detalle;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'No se pudo eliminar el detalle de pedido %: %', p_id_detalle, SQLERRM;
END;
$$;

CREATE PROCEDURE public.sp_registrar_pago_pedido(IN p_id_factura character varying, IN p_id_pedido character varying, IN p_num_comprobante integer, IN p_metodo_pago character varying, IN p_total_pagado numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Paso A: Modificar el estado del pedido a Entregado (2)
    UPDATE Pedido
    SET Estado = 2
    WHERE ID_Pedido = p_id_pedido;

    -- Paso B: Insertar la factura correspondiente
    INSERT INTO Factura (ID_Factura, ID_Pedido, Numero_Comprobante, Metodo_Pago, Total_Pagado)
    VALUES (p_id_factura, p_id_pedido, p_num_comprobante, p_metodo_pago, p_total_pagado);

    -- NOTA: Quitamos el COMMIT manual de aquí para evitar el error de subtransacción activa.
    -- PostgreSQL guardará los datos automáticamente si llegamos exitosamente al final (END).

EXCEPTION
    WHEN OTHERS THEN
        -- Si algo falla, el bloque EXCEPTION ya revierte los cambios físicamente.
        -- Solo relanzamos la alerta para notificar en la consola el motivo exacto de la caída.
        RAISE EXCEPTION 'Error crítico en la transacción. Operación cancelada: %', SQLERRM;
END;
$$;

CREATE TABLE public.cliente (
    id_cliente character varying(10) NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    telefono character varying(20) NOT NULL,
    direccion character varying(200) NOT NULL
);

CREATE TABLE public.detalle_pedido (
    id_detalle character varying(10) NOT NULL,
    id_pedido character varying(10) NOT NULL,
    id_plato character varying(10) NOT NULL,
    cantidad integer NOT NULL,
    subtotal numeric(8,2) NOT NULL
);

CREATE TABLE public.empleado (
    id_empleado character varying(10) NOT NULL,
    nombre_empleado character varying(100) NOT NULL,
    apellido_empleado character varying(100) NOT NULL,
    cargo character varying(40) NOT NULL,
    telefono_empleado character varying(20) NOT NULL
);

CREATE TABLE public.factura (
    id_factura character varying(10) NOT NULL,
    id_pedido character varying(10) NOT NULL,
    numero_comprobante integer NOT NULL,
    metodo_pago character varying(20) NOT NULL,
    total_pagado numeric(8,2) NOT NULL
);

CREATE TABLE public.historial_reserva (
    id_historial character varying(10) NOT NULL,
    id_reserva character varying(10) NOT NULL,
    estado_anterior character varying(30) NOT NULL,
    estado_nuevo character varying(30) NOT NULL,
    fecha_cambio timestamp without time zone NOT NULL
);

CREATE TABLE public.ingrediente (
    id_ingrediente character varying(10) NOT NULL,
    id_proveedor character varying(10) NOT NULL,
    nombre_ingrediente character varying(100) NOT NULL,
    stock_actual numeric(10,2) NOT NULL,
    unidad_medida character varying(20) NOT NULL,
    CONSTRAINT chk_ingrediente_stock CHECK ((stock_actual >= (0)::numeric))
);

CREATE TABLE public.pedido (
    id_pedido character varying(10) NOT NULL,
    id_empleado character varying(10) NOT NULL,
    id_cliente character varying(10) NOT NULL,
    fecha timestamp without time zone NOT NULL,
    tipo_pedido character varying(20) NOT NULL,
    estado integer NOT NULL,
    CONSTRAINT chk_pedido_estado CHECK ((estado = ANY (ARRAY[0, 1, 2, 3])))
);

CREATE TABLE public.plato (
    id_plato character varying(10) NOT NULL,
    nombre_plato character varying(50) NOT NULL,
    categoria character varying(30) NOT NULL,
    precio numeric(8,2) NOT NULL
);

CREATE TABLE public.proveedor (
    id_proveedor character varying(10) NOT NULL,
    razon_social character varying(100) NOT NULL,
    ruc character varying(11) NOT NULL,
    telefono character varying(20) NOT NULL,
    contacto character varying(100) NOT NULL
);

CREATE TABLE public.receta (
    id_plato character varying(10) NOT NULL,
    id_ingrediente character varying(10) NOT NULL,
    cantidad_requerida numeric(10,2) NOT NULL,
    CONSTRAINT chk_receta_cantidad CHECK ((cantidad_requerida > (0)::numeric))
);

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

CREATE SEQUENCE public.seq_historial_reserva
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_pkey PRIMARY KEY (id_detalle);

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_pedido_key UNIQUE (id_pedido);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_numero_comprobante_key UNIQUE (numero_comprobante);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);

ALTER TABLE ONLY public.historial_reserva
    ADD CONSTRAINT historial_reserva_pkey PRIMARY KEY (id_historial);

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT ingrediente_pkey PRIMARY KEY (id_ingrediente);

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);

ALTER TABLE ONLY public.plato
    ADD CONSTRAINT plato_pkey PRIMARY KEY (id_plato);

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id_proveedor);

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_ruc_key UNIQUE (ruc);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_plato, id_ingrediente);

ALTER TABLE ONLY public.reserva
    ADD CONSTRAINT reserva_pkey PRIMARY KEY (id_reserva);

CREATE TRIGGER trg_ajustar_stock_actualizado AFTER UPDATE OF cantidad ON public.detalle_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_ajustar_stock_actualizado();

CREATE TRIGGER trg_descontar_stock AFTER INSERT ON public.detalle_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_descontar_stock();

CREATE TRIGGER trg_historial_reserva AFTER UPDATE OF estado_reserva ON public.reserva FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_historial_reserva();

CREATE TRIGGER trg_normalizar_estado_reserva BEFORE INSERT OR UPDATE OF estado_reserva ON public.reserva FOR EACH ROW EXECUTE FUNCTION public.fn_normalizar_estado_reserva();

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleado(id_empleado);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT fk_factura_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);

ALTER TABLE ONLY public.historial_reserva
    ADD CONSTRAINT fk_historial_reserva FOREIGN KEY (id_reserva) REFERENCES public.reserva(id_reserva);

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT fk_ingrediente_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id_proveedor);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT fk_plato FOREIGN KEY (id_plato) REFERENCES public.plato(id_plato);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT fk_receta_ingrediente FOREIGN KEY (id_ingrediente) REFERENCES public.ingrediente(id_ingrediente);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT fk_receta_plato FOREIGN KEY (id_plato) REFERENCES public.plato(id_plato);

ALTER TABLE ONLY public.reserva
    ADD CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);
