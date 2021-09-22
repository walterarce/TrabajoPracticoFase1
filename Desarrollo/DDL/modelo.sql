create table tp.centro_costos
(
	id_CC int auto_increment
		primary key,
	CC_Descripcion varchar(255) null
);

create table tp.centro_facturacion
(
	id_CF int auto_increment
		primary key,
	CF_Descripcion varchar(255) null
);

create table tp.cliente
(
	id int auto_increment
		primary key,
	nombre varchar(255) null,
	apellido varchar(255) null,
	id_cc int null,
	id_cf int null,
	constraint cliente_centro_costos_id_CC_fk
		foreign key (id_cc) references tp.centro_costos (id_CC),
	constraint cliente_centro_facturacion_id_CF_fk
		foreign key (id_cf) references tp.centro_facturacion (id_CF)
);

create table tp.empleado
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
	on tp.empleado (id, legajo);

alter table tp.empleado modify id int auto_increment;

create table tp.feriados
(
	id int auto_increment
		primary key,
	fechaferiado date null,
	descripcion varchar(255) null
);

create table tp.liquidacion_mensual
(
	id int auto_increment
		primary key,
	cliente_id int null,
	proyecto_id int null,
	descripcion varchar(255) null,
	horas decimal(5,2) null,
	fecha datetime null,
	ajuste char default 'O' null
);

create index liquidacion_mensual_clientes_id_fk
	on tp.liquidacion_mensual (cliente_id);

create table tp.proyecto
(
	proyecto_id int auto_increment
		primary key,
	descripcion varchar(255) null,
	cliente_id int null,
	estado char default 'A' null,
	horas_asignadas_totales decimal(5,2) null,
	constraint proyecto_cliente_id_fk
		foreign key (cliente_id) references tp.cliente (id)
);

create table tp.roles
(
	id int auto_increment
		primary key,
	descripcion_rol varchar(255) null
);

create table tp.roles_empleados
(
	id_rol int null,
	legajo_empleado int null,
	constraint roles_empleados_pk
		unique (id_rol, legajo_empleado),
	constraint roles_empleados_empleado_legajo_fk
		foreign key (legajo_empleado) references tp.empleado (legajo),
	constraint roles_empleados_roles_id_fk
		foreign key (id_rol) references tp.roles (id)
);

create table tp.tareas
(
	id int auto_increment
		primary key,
	descripcion varchar(255) not null,
	legajo_id int not null,
	estado char default 'A' null,
	proyecto_id int not null,
	fini date null,
	ffin datetime null,
	constraint tareas_empleado_legajo_fk
		foreign key (legajo_id) references tp.empleado (legajo),
	constraint tareas_proyecto_proyecto_id_fk
		foreign key (proyecto_id) references tp.proyecto (proyecto_id)
);

create table tp.rendicion
(
	id int auto_increment
		primary key,
	horas decimal(5,2) null,
	tipo_rendicion char null,
	tarea_id int null,
	fecharendicion date null,
	constraint rendicion_tareas_id_fk
		foreign key (tarea_id) references tp.tareas (id)
);

create table tp.tarea_rendicion
(
	id_tarea int null,
	id_rendicion int null,
	constraint tarea_rendicion_rendicion_id_fk
		foreign key (id_rendicion) references tp.rendicion (id),
	constraint tarea_rendicion_tareas_id_fk
		foreign key (id_tarea) references tp.tareas (id)
);

create index tarea_rendicion_id_tarea_id_rendicion_index
	on tp.tarea_rendicion (id_tarea, id_rendicion);

