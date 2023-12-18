-- 1: Añadir un libro con sus autores.
begin transaction;
    insert into autores (nombre, apellido1, apellido2, pais, fecha_nacimiento) values
    ('Abraham', 'Silberschatch', '', 'Estados Unidos', '1947-05-01'), -- https://es.wikipedia.org/wiki/Abraham_Silberschatz
    ('Henry Francis', 'Korth', '', 'Estados Unidos', null), -- https://en.wikipedia.org/wiki/Henry_F._Korth
    ('S.', 'Sudarshan', '', 'India', null); -- https://www.cse.iitb.ac.in/~sudarsha/

    insert into libros (cod_libro, titulo, idioma, editorial, edicion, fecha_pub, paginas, biblioteca) values
    (901, 'Fundamentos de bases de datos', 'Inglés', 'McGraw-Hill', 6, '2014-01-01', 673, 'ETSE');

    insert into escribir (autor_nombre, autor_apellido1, autor_apellido2, libro) values
    ('Abraham', 'Silberschatch', '', 901),
    ('Henry Francis', 'Korth', '', 901),
    ('S.', 'Sudarshan', '', 901);
end;


-- 2: Devolver un libro prestado y dar una valoración.
begin transaction;
    update prestamos set fecha_devolucion = now()
    where socio = 137
      and libro = 777
      and fecha_devolucion is null;
    insert into valoraciones (socio, libro, valoracion) values
      (137, 777, 4.2);
end;