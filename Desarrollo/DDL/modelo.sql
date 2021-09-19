create table centro_costos
(
	id_CC int auto_increment
		primary key,
	CC_Descripcion varchar(255) null
);

create table centro_facturacion
(
	id_CF int auto_increment
		primary key,
	CF_Descripcion varchar(255) null
);

create table cliente
(
	id int auto_increment
		primary key,
	nombre varchar(255) null,
	apellido varchar(255) null,
	id_cc int null,
	id_cf int null,
	constraint cliente_centro_costos_id_CC_fk
		foreign key (id_cc) references centro_costos (id_CC),
	constraint cliente_centro_facturacion_id_CF_fk
		foreign key (id_cf) references centro_facturacion (id_CF)
);

create table empleado
(
	id int,
	nombre varchar(200) null,
	apellido varchar(200) null,
	legajo int not null
		primary key,
	dni int null,
	tipo_rendicion char null
);

create index empleado_id_legajo_index
	on empleado (id, legajo);

alter table empleado modify id int auto_increment;

create table liquidacion_mensual
(
	id int auto_increment
		primary key,
	cliente_id int null,
	proyecto_id int null,
	descripcion varchar(255) null,
	horas decimal(5,2) null,
	fecha datetime null
);

create index liquidacion_mensual_clientes_id_fk
	on liquidacion_mensual (cliente_id);

create table proyecto
(
	proyecto_id int auto_increment
		primary key,
	descripcion varchar(255) null,
	cliente_id int null,
	estado char default 'A' null,
	horas_asignadas_totales decimal(5,2) null,
	constraint proyecto_cliente_id_fk
		foreign key (cliente_id) references cliente (id)
);

create table roles
(
	id int auto_increment
		primary key,
	descripcion_rol varchar(255) null
);

create table roles_empleados
(
	id_rol int null,
	legajo_empleado int null,
	constraint roles_empleados_pk
		unique (id_rol, legajo_empleado),
	constraint roles_empleados_empleado_legajo_fk
		foreign key (legajo_empleado) references empleado (legajo),
	constraint roles_empleados_roles_id_fk
		foreign key (id_rol) references roles (id)
);

create table tareas
(
	id int auto_increment
		primary key,
	descripcion varchar(255) null,
	legajo_id int null,
	estado char default 'A' null,
	proyecto_id int null,
	fini date null,
	ffin datetime null,
	constraint tareas_empleado_legajo_fk
		foreign key (legajo_id) references empleado (legajo),
	constraint tareas_proyecto_proyecto_id_fk
		foreign key (proyecto_id) references proyecto (proyecto_id)
);

create table rendicion
(
	id int auto_increment
		primary key,
	horas decimal(5,2) null,
	tipo_rendicion char null,
	tarea_id int null,
	fecharendicion datetime null,
	constraint rendicion_tareas_id_fk
		foreign key (tarea_id) references tareas (id)
);

create table tarea_rendicion
(
	id_tarea int null,
	id_rendicion int null,
	constraint tarea_rendicion_rendicion_id_fk
		foreign key (id_rendicion) references rendicion (id),
	constraint tarea_rendicion_tareas_id_fk
		foreign key (id_tarea) references tareas (id)
);

create index tarea_rendicion_id_tarea_id_rendicion_index
	on tarea_rendicion (id_tarea, id_rendicion);

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

create definer = root@localhost procedure liquidacion_mensual(IN in_cliente_id int, IN in_proyecto_id int, IN in_descripcion varchar(255))
begin
    INSERT INTO liquidacion_mensual
        (cliente_id, proyecto_id, descripcion, horas, fecha)
        values (in_cliente_id,in_proyecto_id,'Liquidacion Mensual '+ NOW() + in_descripcion);
end;

create definer = root@localhost procedure rendicion_horas_diaria(IN in_horas decimal(5,2), IN v_in_tarea_id int)
begin
    SET @v_estado := (select estado from tareas where id=v_in_tarea_id);
    IF (@v_estado = 'A') then
      INSERT INTO rendicion(horas,tipo_rendicion, tarea_id)
      values (in_horas,'D',v_in_tarea_id);
      SELECT LAST_INSERT_ID() INTO @rendicion_id;
      INSERT INTO tarea_rendicion(id_tarea, id_rendicion)
       values (v_in_tarea_id,@rendicion_id);    
    end if;
    
end;

