create definer = root@localhost function tp.ESFERIADO(target_date date) returns int
BEGIN

  SET @feriado = (select count(*) from feriados where fechaferiado=target_date);
        IF (DAYNAME(target_date) = 'Sunday' OR DAYNAME(target_date) = 'Saturday' OR @feriado=1) then
            RETURN 1;
        else
            RETURN 0;
        end if;
END;

create definer = root@localhost function tp.HABILESDELMES(target_date date) returns int
BEGIN
  DECLARE v_feriados INT DEFAULT 0;
  DECLARE incremento INT DEFAULT 0;
         while incremento < DAY(LAST_DAY(target_date)) do
            IF (ESFERIADO(DATE_SUB(target_date, INTERVAL incremento DAY))) then
                SET v_feriados= v_feriados+1;
            end if;
         SET incremento = incremento + 1;
        end while;
  RETURN  DAY(LAST_DAY(target_date)) - v_feriados;
END;

create definer = root@localhost procedure tp.actualizar_tarea(IN in_proyecto int, IN in_legajo int, IN in_descripcion varchar(255), IN in_estado char, IN in_fini datetime, IN in_idtarea int)
begin
    SET @proyecto_id = in_proyecto;
    SET @tarea_id = in_idtarea;
    SET @legajo = in_legajo;
    SET @descripcion = in_descripcion;
    SET @estado = in_estado;
    SET @fecha_inicio = in_fini;
    IF (@tarea_id != NULL AND @estado = NULL AND @proyecto_id != NULL AND @descripcion != NULL AND @legajo != NULL  ) then
       UPDATE tareas SET proyecto_id = @proyecto_id, descripcion= @descripcion, legajo_id= @legajo
                         WHERE id = @tarea_id;
    ELSEIF (@estado = 'C' AND @proyecto_id != NULL AND @descripcion != NULL AND @legajo != NULL) then
        UPDATE tareas SET proyecto_id = @proyecto_id, descripcion= @descripcion, legajo_id= @legajo, estado='C'
                         WHERE id = @tarea_id;
    end if;

end;

create definer = root@localhost procedure tp.ajuste_horas(IN in_horas decimal(5,2), IN in_id_rendicion int)
begin
    SET  @valoractual  = (select horas from rendicion where id=in_id_rendicion);
    SET  @mesrendicion  = (select MONTH(fecharendicion) from rendicion where id=in_id_rendicion);
    SET  @cliente_liq  = (select c.id from rendicion r
                            join tarea_rendicion tr on r.id = tr.id_rendicion
                            join tareas t on t.id = r.tarea_id join empleado e on e.legajo = t.legajo_id
                            join proyecto p on p.proyecto_id = t.proyecto_id join cliente c on c.id = p.cliente_id
                            where r.id= in_id_rendicion);
    SET  @proyecto_liq  = (select t.proyecto_id from rendicion r
                            join tarea_rendicion tr on r.id = tr.id_rendicion
                            join tareas t on t.id = r.tarea_id
                            where r.id=in_id_rendicion);
    SET  @mesliquidacion  = (select MONTH(fecha) from liquidacion_mensual where cliente_id=@cliente_liq  and proyecto_id =@proyecto_liq and ajuste='O' );
    SET @horasliqmensualactual = (select horas from liquidacion_mensual where cliente_id=@cliente_liq and proyecto_id =@proyecto_liq and ajuste='O');
    IF in_horas > @valoractual then
        INSERT INTO liquidacion_mensual (cliente_id, proyecto_id, descripcion, horas, fecha,ajuste)
           VALUES (@cliente_liq,@proyecto_liq,'AJUSTE Positivo',in_horas,now(),'A');
    elseif in_horas < @valoractual then
       INSERT INTO liquidacion_mensual (cliente_id, proyecto_id, descripcion, horas, fecha, ajuste)
           VALUES (@cliente_liq,@proyecto_liq,'AJUSTE Negativo',-in_horas,now(),'A');
    end if;
    UPDATE rendicion set horas = in_horas
        WHERE id=in_id_rendicion;
end;

create definer = root@localhost procedure tp.alta_cc(IN in_descripcion varchar(255))
begin
    INSERT INTO centro_costos
        (CC_Descripcion)
        values (in_descripcion);
end;

create definer = root@localhost procedure tp.alta_cf(IN in_descripcion varchar(255))
begin
    INSERT INTO centro_facturacion
        (CF_Descripcion)
        values (in_descripcion);
end;

create definer = root@localhost procedure tp.alta_cliente(IN in_nombre varchar(255), IN in_apellido varchar(255), IN in_cc int, IN in_cf int)
begin
    INSERT INTO cliente
        (nombre, apellido, id_cc, id_cf)
        values (in_nombre,in_apellido,in_cc,in_cf);
end;

create definer = root@localhost procedure tp.alta_empleado(IN in_nombre varchar(200), IN in_apellido varchar(200), IN in_legajo int, IN in_dni int, IN in_tipo_rendicion char)
begin
    INSERT INTO empleado(nombre, apellido, legajo, dni, tipo_rendicion)
      values (in_nombre,in_apellido,in_legajo,in_dni, in_tipo_rendicion);
end;

create definer = root@localhost procedure tp.alta_proyecto(IN in_descripcion varchar(255), IN in_cliente_id int, IN in_horas_totales decimal(5,2))
begin
    INSERT INTO proyecto
        (descripcion, cliente_id,  horas_asignadas_totales)
        values (in_descripcion,in_cliente_id, in_horas_totales);
end;

create definer = root@localhost procedure tp.alta_rol(IN in_descripcion_rol varchar(255))
begin
    INSERT INTO roles(descripcion_rol) values (in_descripcion_rol);
end;

create definer = root@localhost procedure tp.alta_tarea(IN in_descripcion varchar(255), IN in_legajo int, IN in_proyecto_id int)
begin
    INSERT INTO tareas
        (descripcion, legajo_id, proyecto_id, fini)
        values (in_descripcion,in_legajo,in_proyecto_id,NOW());
end;

create definer = root@localhost procedure tp.asignar_rol_empleado(IN in_legajo int, IN in_idrol int)
begin
    INSERT INTO roles_empleados(id_rol,legajo_empleado) values (in_idrol,in_legajo);
end;

create definer = root@localhost procedure tp.liquidacion_mensual(IN in_cliente_id int, IN in_proyecto_id int, IN in_descripcion varchar(255), IN in_mes_a_liquidar int)
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

create definer = root@localhost procedure tp.rendicion_horas_diaria(IN in_horas decimal(5,2), IN v_in_tarea_id int, IN infecha date)
begin
    SET @v_estado = (select estado from tareas where id=v_in_tarea_id);
    SET @NoexisteDuplicado = (select count(*) from rendicion r
        join tareas t on t.id = r.tarea_id
        join empleado e on e.legajo = t.legajo_id
    WHERE r.tarea_id = v_in_tarea_id AND r.fecharendicion =infecha);
    #solo si esta abierta, es de carga diaria, no es feriado o fin de semana , no es a futuro y no hay duplicado
    IF (@v_estado = 'A'
            AND (!ESFERIADO(infecha))
            AND infecha <=NOW() AND @NoexisteDuplicado=0
    ) then
      INSERT INTO rendicion(horas,tipo_rendicion, tarea_id, fecharendicion)
      values (in_horas,'D',v_in_tarea_id,infecha);
      SELECT LAST_INSERT_ID() INTO @rendicion_id;
      INSERT INTO tarea_rendicion(id_tarea, id_rendicion)
       values (v_in_tarea_id,@rendicion_id);
    end if;

end;

create definer = root@localhost procedure tp.rendicion_horas_mensual(IN in_horas decimal(5,2), IN v_in_tarea_id int, IN v_fecha date)
begin
    DECLARE incremento INT DEFAULT 0;
    IF (in_horas<=160 and DAY(v_fecha)=DAY(LAST_DAY(v_fecha))) then
          while incremento < DAY(LAST_DAY(v_fecha)) do
            if (MONTH(DATE_SUB(v_fecha, INTERVAL incremento DAY)) = MONTH(v_fecha)) then
              call rendicion_horas_diaria((in_horas/HABILESDELMES(v_fecha)),v_in_tarea_id,DATE_SUB(v_fecha, INTERVAL incremento DAY));
            end if;
            SET incremento = incremento + 1;
          end while;
           
    end if;
end;

create definer = root@localhost procedure tp.rendicion_horas_semanal(IN in_horas decimal(5,2), IN v_in_tarea_id int, IN v_fecha date)
begin
    DECLARE incremento INT DEFAULT 0;
    IF (DAYNAME(v_fecha) = 'Friday' and in_horas<=40) then
          while incremento < 5 do
            call rendicion_horas_diaria((in_horas/5),v_in_tarea_id,DATE_SUB(v_fecha, INTERVAL incremento DAY));
            SET incremento = incremento + 1;
          end while;
           # call rendicion_horas_diaria((in_horas/5),v_in_tarea_id,fechacambiante);
    end if;
end;

