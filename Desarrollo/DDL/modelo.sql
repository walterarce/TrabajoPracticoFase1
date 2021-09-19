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
