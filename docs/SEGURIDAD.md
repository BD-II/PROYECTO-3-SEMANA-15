# Seguridad

Aplicar el script como propietario administrador de todas las tablas y rutinas, después de instalar/actualizar. Los privilegios son globales por nombre de rol dentro del servidor; usar una instancia de pruebas si los roles ya se usan para otra aplicación.

- Si no existen, se crean roles NOLOGIN. No se publica ninguna contraseña. Un administrador debe crear un login independiente, asignarle el rol necesario y conceder CONNECT a esta base. Si los roles ya existían con LOGIN, se conserva esa propiedad para no romper cuentas existentes. Rotar cualquier contraseña previamente publicada.
- Invitado: USAGE de public y SELECT de Plato. Sin datos personales, sin ejecución pública de rutinas.
- Restaurante: consulta del negocio y escritura operativa limitada. No puede actualizar identificadores de pedidos/detalles, marcar legado, modificar precios históricos, borrar maestros o modificar facturas.
- El operador no puede escribir directamente movimientos, historial, instantáneas, stock o facturas. El ajuste de stock es una operación autorizada explícita mediante procedimiento; no exige supervisor en esta versión académica.
- Triggers de inventario, cancelación e historial, y procedimientos de ajuste/pago usan SECURITY DEFINER con search_path fijo. Su propietario debe ser un administrador de confianza. El esquema public no concede CREATE a usuarios operativos.
- El resto de rutinas usan privilegios del invocador. Los triggers no necesitan que el operador reciba EXECUTE directo sobre las funciones internas.
- No se configura autenticación HTTP, sesiones, contraseñas de aplicación ni seguridad por fila. El futuro backend deberá verificar quién puede operar cada pedido. Este rol representa un empleado de confianza, no un cliente final anónimo.
- El superusuario/propietario puede alterar o desactivar protecciones: usarlo solo para administración, nunca como credencial del frontend.
- Los DEFAULT PRIVILEGES se aplican al propietario que ejecuta el script. Revisar privilegios predeterminados si otro propietario crea futuros objetos.

No hay acceso de red configurado aquí. El backend se conectará con credenciales fuera del repositorio. Nunca exponer PostgreSQL directamente al navegador.
