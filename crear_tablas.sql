-- la relaciones de grado 3 1->1, tiene una clave primaria de dos atributos y dos claves cantidatas
-- AB PK CC
-- BC CC
-- AC CC

-- Se van a considerar telefonos fijos y
-- móviles con el prefijo español
create type telefono as char(9);
create type dni as char(9);

-- Definir una valoración basada en estrellas
create domain valoracion as decimal (2, 1)
       check (value between 1.0 and 5.0)

create table bibliotecas (
    nombre        varchar(50) primary key,
    localizacion  varchar(100) not null,
    telefono      telefono     not null,
    hora_apertura time,
    hora_cierre   time
);

create table socios (
    codigo    serial primary key,
    nombre    varchar(50) not null, -- El nombre es obligatorio
    apellido1 varchar(50) not null,
    apellido2 varchar(50) not null,
    email     varchar(50),
    direccion varchar(100),
    --telefono  telefono not null, -- Para que está la tabla de teléfonos sino?
    grado     varchar(50),
    fecha_egresado date
);

create table libros (
    codigo    serial primary key,
    titulo    varchar(50) not null, -- El titulo es obligatorio
    idioma    varchar(15) not null,
    editorial varchar(15) not null,
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
    socio int references socios(codigo)
                         on update cascade
                         on delete set default, -- Si un socio se va, se mantienen sus valoraciones
    libro int references libros(codigo)
                         on update cascade
                         on delete cascade, -- Se borra la valoración si se borra el libro
    valoracion valoracion not null, -- Hacer una valoración es obligatorio
    primary key (socio, libro)
);

create table prestamos (
    socio int references socios(codigo)
                         on update cascade
                         on delete set default,
    libro int references libros(codigo)
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
    libro int references libros(codigo),
    primary key (autor_nombre, autor_apellido1, autor_apellido2, libro),
    foreign key (autor_nombre, autor_apellido, autor_apellido2) references autores (nombre, apellido1, apellido2)
            on update cascade
            on delete no action -- No puede quedar el libro sin autor

);

create table telefonos_socios (
    socio int references socios(codigo)
                         on update cascade
                         on delete cascade, -- Si se borra un socio, también sus teléfonos
    telefono telefono,
    primary key (socio, telefono)
);

-- Insercion de datos

insert into bibliotecas (nombre, localizacion, telefono, hora_apertura, hora_cierre) values
    ('ETSE', 'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela', '881816706', '8:30', '20:30'),
    ('Concepción Arenal', 'Rúa dos Feáns, s/n. Campus Vida, 15782 Santiago de Compostela', '881815210', '8:30', '20:30'),
    ('Bioloxía', 'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela', '881813246', '8:30', '20:00'),
    ('Ciencias da Comunicación', 'Avda de Castelao, s/n. Campus norte, 15782 Santiago de Compostela', '881816505', '8:30', '20:15'),
    ('Ciencias Económicas e Empresariais', 'Avda. do Burgo, s/n, 15782 Santiago de Compostela', '881811510', '8:30', '21:30'),
    ('Enfermaría', 'Avda. Xoan XXIII, 15782 Santiago de Compostela', '881 812 066', '8:30', '21:30'),
    ('Farmacia', 'Avenida de Vigo, s/n, 15782 Santiago de Compostela', '881 815 242', '8:30', '21:00'),
    ('Filoloxía', 'Avda. de Castelao, s/n, 15782 Santiago de Compostela', '881 811 752', '8:30', '20:20'),
    ('Filosofía', 'Praza de Mazarelos, s/n, 15782 Santiago de Compostela', '881 812 500', '8:30', '20:30'),
    ('Física e Óptica e Optometría', 'Rúa Xosé María Suárez Núñez, s/n, 15782 Santiago de Compostela', '881 814 071', '8:30', '21:30'),
    ('Formación do Profesorado', 'Avda. de Ramón Ferreiro, s/n, 27002 Lugo', '982 821 007', '8:30', '21:30'),
    ('Matemáticas', 'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela', '881 813 128', '8:30', '21:00'),
    ('Medicina e Odontoloxía', 'Rúa de San Francisco, s/n , 15782 Santiago de Compostela', '881 812 411', '8:30', '21:30'),
    ('Psicoloxía e Ciencias da Educación', 'Rúa Prof. Vicente Fráiz Andón, s/n, 15782 Santiago de Compostela', '881 813 720', '8.30', '21.00'),
    ('Xeografía e Historia', 'Praza da Universidade, 1, 15703 Santiago de Compostela', '881 812 687', '8:30', '21:30')