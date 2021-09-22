call alta_cc('Marketing');
call alta_cf('Buenos Aires');
call alta_cliente('Walter','Arce' ,1,1);
call alta_proyecto('Formulario de clientes',1,200);
call alta_empleado('Geronimo', 'Perez',1220,25187617,'D');
call alta_rol('Analista Full Stack');
call asignar_rol_empleado(1220,1);
call alta_tarea('Analisis implementacion React',1220,1);
call rendicion_horas_diaria(4.3,1)
call actualizar_tarea(null,null,'','C',null,1)
call alta_tarea('Implementar cambios CSS',1220,null,1)