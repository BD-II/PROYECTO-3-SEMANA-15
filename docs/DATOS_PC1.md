# Datos del respaldo y decisiones de conservación

Se extrajeron definiciones del catálogo y los bloques comprimidos de datos del dump custom PostgreSQL proporcionado. La reconstrucción se verificó en PGlite; no se ejecutó pg_restore nativo.

| Tabla | Registros |
|---|---:|
| cliente | 30 |
| empleado | 3 |
| proveedor | 12 |
| ingrediente | 62 |
| plato | 40 |
| receta | 143 |
| pedido | 50 |
| detalle_pedido | 150 |
| factura | 41 |
| reserva | 101 |
| historial_reserva | 2 |

Discrepancias verificadas entre importe facturado y suma de detalles:

| Factura | Pedido | Facturado S/ | Detalles S/ |
|---|---|---:|---:|
| F002 | PD002 | 48.50 | 45.50 |
| F033 | PD041 | 43.50 | 40.50 |
| F040 | PD049 | 70.50 | 39.50 |
| F041 | PD050 | 50.50 | 60.50 |

No se puede deducir del respaldo si hubo descuentos, cargos adicionales o errores manuales. No se alteran esos importes ni se presentan como pagos validados por las nuevas reglas. Consultar el diagnóstico SQL y revisar con el equipo.

Los 150 precios unitarios se pudieron reconstruir desde subtotal/cantidad bajo las comprobaciones de la actualización. No se cambian los identificadores ni se recalcula stock histórico. Los 50 pedidos se marcan legado y quedan de solo lectura operativa, incluidos aquellos que estaban pendientes o en preparación.

Este paquete SI incluye los datos ficticios originales, incluidos clientes y empleados, separados por tabla en seeds/originales. El maestro 009_originales_completos.sql los carga de forma controlada sobre V2. La alternativa de upgrade sigue disponible para una copia restaurada de PC1. El seed 001_demo.sql es opcional y solo agrega los registros auxiliares de las pruebas.
