-- Lectura: ejecutar despues de upgrade.sql. No corrige los registros.
SELECT f.id_factura,f.id_pedido,f.total_pagado,fn_calcular_total_pedido(f.id_pedido) total_detalles
FROM factura f WHERE f.total_pagado<>fn_calcular_total_pedido(f.id_pedido);
SELECT id_pedido,estado FROM pedido WHERE legado AND estado IN (0,1);
SELECT numero_mesa,capacidad FROM mesa ORDER BY numero_mesa;
