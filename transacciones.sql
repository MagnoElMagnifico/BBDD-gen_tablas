-- 1: Añadir nuevo socio junto con sus teléfonos.
begin transaction;
    -- Como se ha definido el tipo de dato como serial,
    -- se puede dejar en blanco y el gestor proporcionara un valor
	insert into socios (nombre, apellido1, apellido2, email, direccion, grado, fecha_egresado) values
	    ('Juan', 'Garcia', 'Rodriguez', 'juan.garcia@rai.usc.es',
	     'Avenida Mahia, 77, La Coruña', 'Informática', '2022-06-23');
	    
    -- Con la siguiente sentencia se insertan dos números de teléfono
    -- al último socio insertado.
    insert into telefonos_socios (socio, telefono)
    select currval('socios_cod_socio_seq'), '981981981'
    union
    select currval('socios_cod_socio_seq'), '610711942';
end;


-- 2: Añadir un libro con sus autores.
begin transaction;
    insert into autores (nombre, apellido1, apellido2, pais, fecha_nacimiento) values
      ('Abraham', 'Silberschatch', '', 'Estados Unidos', '1947-05-01'), -- https://es.wikipedia.org/wiki/Abraham_Silberschatz
      ('Henry Francis', 'Korth', '', 'Estados Unidos', null),           -- https://en.wikipedia.org/wiki/Henry_F._Korth
      ('S.', 'Sudarshan', '', 'India', null)                            -- https://www.cse.iitb.ac.in/~sudarsha/
    on conflict do nothing;

    insert into libros (titulo, idioma, editorial, edicion, fecha_pub, paginas, biblioteca)
      ('Fundamentos de bases de datos', 'Inglés', 'McGraw-Hill', 6, '2014-01-01', 673, 'ETSE');

    insert into escribir (autor_nombre, autor_apellido1, autor_apellido2, libro)
    select 'Abraham', 'Silberschatch', '', currval('libros_cod_libro_seq')
    union
    select 'Henry Francis', 'Korth', '', currval('libros_cod_libro_seq')
    union
    select 'S.', 'Sudarshan', '', currval('libros_cod_libro_seq');
end;


-- Realizar el prestamo
-- insert into prestamos (socio, libro, bibliotecario, fecha_prestamo, fecha_devolucion)
-- select currval('socios_cod_socio_seq'), currval('libros_cod_libro_seq'),
--        max(b.dni), now(), null
-- from bibliotecarios b join libros l on b.biblioteca = l.biblioteca -- obtener 1 bibliotecario de la biblioteca en donde está el libro
-- where l.cod_libro = currval('libros_cod_libro_seq')

-- -- Ver cual es el codigo del libro y socio para la siguiente transaccion
-- select currval('socios_cod_socio_seq') as cod_socio,
--        currval('libros_cod_libro_seq') as cod_libro;


-- 3: Devolver un libro prestado y dar una valoración.
begin transaction;
    update prestamos
    set fecha_devolucion = now()
    where socio = 301
      and libro = 901
      and fecha_devolucion is null;
    insert into valoraciones (socio, libro, valoracion) values
      (301, 901, 4.2);
end;


-- select *
-- from bibliotecarios
-- where dni = '44715894F' -- Ines Soto,    8:30-20:15, Ciencias da Comunicación
--    or dni = '78649875H' -- Cruz Ramirez, 8:30-21:30, Enfermaría

   
-- 4: Cambio de turno de bibliotecarios
begin transaction;
    -- El primer update sobreescribirá los valores, entonces
    -- en el segundo update no se podrán usar. Por eso se
    -- almacenan temporalmente en una nueva tabla.
    create temporary table temporal on commit drop as
    select biblioteca, hora_entrada, hora_salida
    from bibliotecarios
    where dni = '44715894F';

    -- Cambiar: 44715894F, Ciencias da Comunicacion <===> 78649875H, Enfermaría
    update bibliotecarios 
    set biblioteca = nueva.biblioteca,
        hora_entrada = nueva.hora_entrada,
        hora_salida = nueva.hora_salida
    from (
        select biblioteca, hora_entrada, hora_salida
        from bibliotecarios
        where dni = '78649875H'
    ) nueva
    where dni = '44715894F';
   
   update bibliotecarios 
    set biblioteca = temporal.biblioteca,
        hora_entrada = temporal.hora_entrada,
        hora_salida = temporal.hora_salida
    from temporal
    where dni = '78649875H';
end;

-- Se han intercambiado el turno
-- select *
-- from bibliotecarios
-- where dni = '44715894F' -- Ines Soto,    8:30-20:15, Ciencias da Comunicación
--    or dni = '78649875H' -- Cruz Ramirez, 8:30-21:30, Enfermaría
