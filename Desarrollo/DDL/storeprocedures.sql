create definer = root@localhost procedure alta_cc(IN in_descripcion varchar(255))
begin
    INSERT INTO centro_costos
        (CC_Descripcion)
        values (in_descripcion);
end;

create definer = root@localhost procedure alta_cf(IN in_descripcion varchar(255))
begin
    INSERT INTO centro_facturacion
        (CF_Descripcion)
        values (in_descripcion);
end;
create definer = root@localhost procedure alta_cliente(IN in_nombre varchar(255), IN in_apellido varchar(255), IN in_cc int, IN in_cf int)
begin
    INSERT INTO cliente
        (nombre, apellido, id_cc, id_cf)
        values (in_nombre,in_apellido,in_cc,in_cf);
end;

create definer = root@localhost procedure alta_empleado(IN in_nombre varchar(200), IN in_apellido varchar(200), IN in_legajo int, IN in_dni int)
begin
    INSERT INTO empleado(nombre,apellido, legajo,dni) values (in_nombre,in_apellido,in_legajo,in_dni);
end;

create definer = root@localhost procedure alta_empleado_rol(IN in_legajo int, IN in_idrol int)
begin
    INSERT INTO roles_empleados(id_rol,legajo_empleado) values (in_idrol,in_legajo);
end;

create definer = root@localhost procedure alta_proyecto(IN in_descripcion varchar(255), IN in_cliente_id int)
begin
    INSERT INTO proyecto
        (descripcion, cliente_id)
        values (in_descripcion,in_cliente_id);
end;

create definer = root@localhost procedure alta_rol(IN in_descripcion_rol varchar(255))
begin
    INSERT INTO roles(descripcion_rol) values (in_descripcion_rol);
end;

create definer = root@localhost procedure alta_tarea(IN in_descripcion varchar(255), IN in_legajo int, IN in_estado char, IN in_proyecto_id int)
begin
    INSERT INTO tareas
        (descripcion, legajo_id, estado, proyecto_id, fini)
        values (in_descripcion,in_legajo,in_estado,in_proyecto_id,NOW());
end;

create definer = root@localhost procedure liquidacion_mensual(IN in_cliente_id int, IN in_proyecto_id int, IN in_descripcion varchar(255), IN in_mes_a_liquidar int)
begin
  SET @v_total_horas :=  (select sum(r.horas) total_horas from rendicion r
join tarea_rendicion tr on r.id = tr.id_rendicion
join rendicion r2 on r2.id = tr.id_rendicion
join tareas t on t.id = r.tarea_id
join proyecto p on p.proyecto_id = t.proyecto_id
join cliente c on c.id = p.cliente_id
where c.id=in_cliente_id and p.proyecto_id = p.proyecto_id
   AND MONTH(r2.fecharendicion) = in_mes_a_liquidar AND YEAR(r2.fecharendicion) = YEAR(now()));

  SET @existeliquidacion :=  (select count(*) total from liquidacion_mensual lq
join cliente c on c.id = lq.cliente_id
join proyecto p on c.id = p.cliente_id
where c.id=in_cliente_id and p.proyecto_id = in_proyecto_id
   AND MONTH(lq.fecha) = in_mes_a_liquidar
  AND YEAR(lq.fecha) = YEAR(now()));
IF @existeliquidacion >0 then
    SELECT 'Liquidacion generada',lm.descripcion,lm.horas from liquidacion_mensual lm
    where lm.cliente_id=in_cliente_id and lm.proyecto_id = in_proyecto_id
   AND MONTH(lm.fecha) = in_mes_a_liquidar
  AND YEAR(lm.fecha) = YEAR(now());
else
      INSERT INTO liquidacion_mensual
        (cliente_id, proyecto_id, descripcion, horas, fecha)
        values (in_cliente_id,in_proyecto_id, in_descripcion,@v_total_horas,NOW());
    SELECT * from liquidacion_mensual where id = LAST_INSERT_ID();
end if;
end;

create definer = root@localhost procedure rendicion_horas_diaria(IN in_horas decimal(5,2), IN v_in_tarea_id int)
begin
    SET @v_estado := (select estado from tareas where id=v_in_tarea_id);
    IF (@v_estado = 'A') then
      INSERT INTO rendicion(horas,tipo_rendicion, tarea_id, fecharendicion)
      values (in_horas,'D',v_in_tarea_id,now());
      SELECT LAST_INSERT_ID() INTO @rendicion_id;
      INSERT INTO tarea_rendicion(id_tarea, id_rendicion)
       values (v_in_tarea_id,@rendicion_id);    
    end if;
    
end;
