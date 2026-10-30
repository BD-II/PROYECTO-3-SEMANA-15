CREATE OR REPLACE PROCEDURE sp_registrar_pago_pedido(IN p_id_factura varchar,IN p_id_pedido varchar,IN p_num_comprobante integer,IN p_metodo_pago varchar,IN p_total_pagado numeric)
LANGUAGE plpgsql AS $$ BEGIN
 INSERT INTO public.factura(id_factura,id_pedido,numero_comprobante,metodo_pago,total_pagado)
 VALUES(p_id_factura,p_id_pedido,p_num_comprobante,p_metodo_pago,p_total_pagado);
END $$;
