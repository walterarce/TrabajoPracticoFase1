create or replace  procedure alta_empleado(IN in_nombre varchar(200), IN in_apellido varchar(200), IN in_legajo int, IN in_dni int)
begin
    INSERT INTO empleado(nombre,apellido, legajo,dni) values (in_nombre,in_apellido,in_legajo,in_dni);
end;

create or replace  procedure alta_empleado_rol(IN in_legajo int, IN in_idrol int)
begin
    INSERT INTO roles_empleados(id_rol,legajo_empleado) values (in_idrol,in_legajo);
end;

create or replace  procedure alta_rol(IN in_descripcion_rol varchar(255))
begin
    INSERT INTO roles(descripcion_rol) values (in_descripcion_rol);
end;

create or replace
   procedure rendicion_horas_diaria(IN in_horas decimal, IN v_in_tarea_id int)
begin
    INSERT INTO rendicion(horas,tipo_rendicion, tarea_id) values (in_horas,'D',v_in_tarea_id);
    SELECT LAST_INSERT_ID() INTO @rendicion_id;
    INSERT INTO tarea_rendicion(id_tarea, id_rendicion) values (v_in_tarea_id,@rendicion_id);
end;