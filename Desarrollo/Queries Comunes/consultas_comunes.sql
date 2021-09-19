--Consulta Todos los Empleado con Roles
select e.legajo, e.apellido,e.nombre, r.descripcion_rol from empleado e
    join roles_empleados re on e.legajo = re.legajo_empleado
    join roles r on r.id = re.id_rol

--Todas las tareas con Empleados y Roles
select t.id, t.descripcion,t.proyecto_id, e.legajo,r.descripcion_rol from tareas t
    join empleado e on e.legajo = t.legajo_id
    join roles_empleados re on e.legajo = re.legajo_empleado
    join roles r on r.id = re.id_rol