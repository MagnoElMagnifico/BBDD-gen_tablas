-- Se van a considerar telefonos fijos y
-- móviles con el prefijo español
create domain telefono as char(9);
create domain dni as char(9);

-- Definir una valoración basada en estrellas
create domain valoracion as decimal (2, 1)
       check (value between 1.0 and 5.0);

create table bibliotecas (
    nombre        varchar(50) primary key,
    localizacion  varchar(100) not null,
    telefono      telefono     not null,
    hora_apertura time,
    hora_cierre   time
);

create table socios (
    cod_socio serial primary key,
    nombre    varchar(50) not null, -- El nombre es obligatorio
    apellido1 varchar(50) not null,
    apellido2 varchar(50) not null,
    email     varchar(50),
    direccion varchar(100),
    grado     varchar(50),
    fecha_egresado date
);

create table libros (
    cod_libro serial primary key,
    titulo    varchar(100) not null, -- El titulo es obligatorio
    idioma    varchar(15) not null,
    editorial varchar(50) not null,
    edicion   smallint,
    fecha_pub date,
    paginas   int,
    biblioteca varchar(50) references bibliotecas(nombre)
                           on update cascade
                           on delete set null
);

create table autores (
    nombre           varchar(50),
    apellido1        varchar(50),
    apellido2        varchar(50),
    pais             varchar(50),
    fecha_nacimiento date,
    primary key (nombre, apellido1, apellido2)
);

create table bibliotecarios (
    dni            dni primary key,
    nombre         varchar(50) not null,
    apellido1      varchar(50) not null,
    apellido2      varchar(50) not null,
    sueldo         int not null,
    hora_entrada   time,
    hora_salida    time,
    fecha_contrato date,
    biblioteca     varchar(50) references bibliotecas(nombre) 
                                          on update cascade
                                          on delete no action -- No vamos a dejar a un bibliotecario sin biblioteca
);

create table valoraciones (
    socio int references socios(cod_socio)
                         on update cascade
                         on delete set default, -- Si un socio se va, se mantienen sus valoraciones
    libro int references libros(cod_libro)
                         on update cascade
                         on delete cascade, -- Se borra la valoración si se borra el libro
    valoracion valoracion not null, -- Hacer una valoración es obligatorio
    primary key (socio, libro)
);

create table prestamos (
    socio int references socios(cod_socio)
                         on update cascade
                         on delete set default,
    libro int references libros(cod_libro)
                         on update cascade
                         on delete set default,
    bibliotecario dni references bibliotecarios(dni)
                         on update cascade
                         on delete set default,
    fecha_prestamo   timestamp,
    fecha_devolucion timestamp,
    primary key (socio, libro, bibliotecario, fecha_prestamo)
);

create table escribir (
    autor_nombre    char(50),
    autor_apellido1 char(50),
    autor_apellido2 char(50),
    libro int references libros(cod_libro)
                         on update cascade
                         on delete cascade, -- Si se borra un libro, se borra la relación con su autor
    primary key (autor_nombre, autor_apellido1, autor_apellido2, libro),
    foreign key (autor_nombre, autor_apellido1, autor_apellido2) references autores (nombre, apellido1, apellido2)
            on update cascade
            on delete no action -- No puede quedar el libro sin autor

);

create table telefonos_socios (
    socio int references socios(cod_socio)
                         on update cascade
                         on delete cascade, -- Si se borra un socio, también sus teléfonos
    telefono telefono,
    primary key (socio, telefono)
);
