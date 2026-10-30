# Pollería Paredes — Base de Datos II
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-336791?style=for-the-badge&logo=postgresql&logoColor=white)
Repositorio del equipo: PostgreSQL mejorado, datos ficticios originales de PC1 y preparación para integrar MongoDB en PC3 y un frontend en PC4.

**Para leer el código:** abrir [docs/INDICE_CODIGO.md](docs/INDICE_CODIGO.md).
**Para instalar:** seguir UNA de las rutas siguientes.
**Para conocer los cambios:** [docs/CAMBIOS_DETALLADOS.md](docs/CAMBIOS_DETALLADOS.md).

## Instalar desde cero en pgAdmin

Crear una base vacía y conectarse como su propietario administrador. Abrir los archivos de `database/postgresql/pgadmin/` en Query Tool y ejecutarlos completos:

| Orden | Archivo | Función |
|---|---|---|
| 1 | [01_instalar.sql](database/postgresql/pgadmin/01_instalar.sql) | Crear estructura y reglas mejoradas |
| 2 | [03_roles.sql](database/postgresql/pgadmin/03_roles.sql) | Configurar roles y permisos sin contraseñas |
| 3 | [09_recuperar_todos_los_datos_originales.sql](database/postgresql/pgadmin/09_recuperar_todos_los_datos_originales.sql) | Cargar todos los datos originales |

No hay paso 02 en esta ruta. La numeración se conserva para que coincida con los archivos ya utilizados por el grupo.

El 09 incluye también la carta: **el 08 es opcional**, para quien solo quiera recuperar proveedores, ingredientes, platos y recetas. Si ya se ejecutó el 08, el 09 lo admite sin duplicarlos.

El 04 agrega un pequeño conjunto demo, independiente del original. Solo es obligatorio para las pruebas 05–07. Puede convivir con los datos originales. Este paquete no incluye el antiguo `09_datos_operativos.sql` que inventaba nuevos pedidos.

Al finalizar, generar un backup Custom y comprobar su restauración en otra base. Los roles del servidor se recrean con el script 03.

## Si ya instalaron V2 y ejecutaron el 08

Ejecutar únicamente el 09 de recuperación original. No repetir el 01 ni ejecutar la alternativa de actualización. Si ya cargaron el 09 correctamente, no hace falta volver a cargar datos por descargar este repositorio.

## Alternativa: actualizar una copia restaurada de PC1

Solo para una base que todavía tiene la estructura original de PC1. Crear una copia restaurada y ejecutar:

1. `pgadmin/ALTERNATIVA_actualizar_pc1.sql`.
2. `pgadmin/03_roles.sql`.
3. Revisar `tests/004_diagnostico_legado.sql`.

Esta ruta sustituye a instalar desde cero; no se combina con el 01.

## Organización del código

| Carpeta | Contenido |
|---|---|
| [tables](database/postgresql/tables/) | Definiciones iniciales por tabla; la migración aplica las mejoras |
| [constraints](database/postgresql/constraints/) | Claves primarias, foráneas y restricciones iniciales |
| [migrations](database/postgresql/migrations/) | Cambios de la versión mejorada y orden de aplicación |
| [functions](database/postgresql/functions/) | Una función por archivo, incluidas funciones de triggers |
| [procedures](database/postgresql/procedures/) | Un procedimiento almacenado por archivo |
| [triggers](database/postgresql/triggers/) | Un disparador por archivo |
| [indexes](database/postgresql/indexes/) | Índices |
| [security](database/postgresql/security/) | Roles y permisos |
| [seeds/originales](database/postgresql/seeds/originales/) | Datos originales separados por tabla |
| [pgadmin](database/postgresql/pgadmin/) | Archivos completos listos para Query Tool |
| [tests](database/postgresql/tests/) | Pruebas y consultas de diagnóstico |
| [docs/esquema_actual](docs/esquema_actual/) | Vista de lectura de las tablas finales, con columnas y restricciones |
| [scripts](scripts/) | Compilación del SQL y validación automática |

Los maestros `001_*.sql`, `install.sql`, `upgrade.sql` y los seeds maestros contienen instrucciones `\ir` para psql. Para Query Tool usar exclusivamente los archivos completos de pgadmin.

## Datos originales incluidos

| Tabla | Registros |
|---|---:|
| Cliente | 30 |
| Empleado | 3 |
| Proveedor | 12 |
| Ingrediente | 62 |
| Plato | 40 |
| Receta | 143 |
| Pedido | 50 |
| Detalle de pedido | 150 |
| Factura | 41 |
| Reserva | 101 |
| Historial de reserva | 2 |

Son datos ficticios proporcionados por el equipo. Se conservan sus identificadores. Las cuatro facturas inconsistentes se documentan, sin cambiar sus importes.

Los pedidos originales quedan como históricos protegidos. No se reconstruye el consumo de ingredientes que el sistema antiguo no registraba. Los pedidos nuevos utilizan las reglas mejoradas. Las capacidades históricas de mesa se infieren del mayor grupo registrado y la duración se asume de 120 minutos; confirmar estas reglas si se utiliza el proyecto fuera de la demostración.

## Pruebas

En su servidor, cargar `04_demo.sql` y ejecutar `05_pruebas.sql`, `06_inventario.sql` y `07_seguridad.sql`. Los pedidos de prueba se revierten con ROLLBACK, sin borrar los datos originales.

Opcionalmente, con Node.js 22 o superior:

```bash
npm ci
npm test
npm run test:originales
```

Las pruebas automáticas utilizan PostgreSQL 18.6 embebido en PGlite, sin conectarse a su base local. Validan instalación, reglas de negocio, permisos y carga de originales. La restauración con pg_restore y las pruebas concurrentes deben comprobarse en PostgreSQL nativo. La automatización de GitHub ejecuta estas comprobaciones en cada push o Pull Request.

Para regenerar los archivos completos:

```bash
python scripts/compilar_sql.py
```

Editar las fuentes modulares y recompilar; no editar únicamente un archivo generado.

## Compartir con el grupo

Descomprimir el paquete y subir **el contenido de esta carpeta** a la raíz del repositorio, de modo que este README sea visible en la portada. No subir el ZIP como única entrega ni `node_modules`.

Si el repositorio es privado, invitar a los compañeros como colaboradores. Seguir [CONTRIBUTING.md](CONTRIBUTING.md) para organizar cambios en ramas y revisiones.

No se incluye el backup de su computadora; pueden adjuntarlo a una Release. No se incluyen credenciales reales. PostgreSQL y MongoDB se integrarán mediante el backend; las colecciones MongoDB, el backend y el frontend están pendientes. Ver [INTEGRACION_FUTURA.md](docs/INTEGRACION_FUTURA.md).
