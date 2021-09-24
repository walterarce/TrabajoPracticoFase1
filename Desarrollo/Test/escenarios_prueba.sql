#escenario1 creación de centros de costo y facturacion
call alta_cc('Marketing');
call alta_cf('Buenos Aires');
#assert verifico que se creo el CC,y el CF y obtengo el id en ambos casos
select id_CC from centro_costos where CC_Descripcion ='Marketing'
select id_CF from centro_facturacion where CF_Descripcion ='Buenos Aires'

#escenario2 creacion de clientes (Walter Arce)
call alta_cliente('Walter','Arce' ,1,1);
#assert simplemente valido existencia
select id from cliente where nombre ='Walter' and apellido='Arce'

#escenario3 creacion del proyecto
call alta_proyecto('Ecosistema basado en microservicios',1,200);
#valido que el proyecto este cargado con estado habilitado
select * from proyecto where estado='A'

#escenario4 creacion del empleado
call alta_empleado('Geronimo', 'Perez',1220,25187617,'D');
select * from empleado where legajo=1220

#escenario 5genero un rol para asignar al empleado
call alta_rol('Analista Full Stack');
select * from alta_rol where descripcion_rol='Analista Full Stack'

#escenario 6 generar asignacion de rol empleado
call asignar_rol_empleado(1220,1);
select * from empleado join roles_empleados re on empleado.legajo = re.legajo_empleado
join roles r on r.id = re.id_rol
where r.descripcion_rol ='Analista Full Stack'
1|Geronimo|Perez|1220|25187617|D|1|1220|1|Analista Full Stack

#escenario 7 generacion de tarea 
call alta_tarea('Analisis implementacion React',1220,1);

#escenario 8 rendicion de la tarea
call rendicion_horas_diaria(4.3,1)