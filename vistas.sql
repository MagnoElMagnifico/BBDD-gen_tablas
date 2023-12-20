-- 1: Prestamos pendientes
-- Son los libros que todavía no han sido devueltos. Incluir información
-- sobre el socio que lo tiene y el número de días que lleva prestado.
create view prestamos_pendientes (
    cod_socio, nombre, apellido1, apellido2, email,
    cod_libro, titulo, biblioteca,
    tiempo_restante
)
as select 
     cod_socio, nombre, apellido1, apellido2, email,
     cod_libro, titulo, biblioteca,
     now() - fecha_prestamo as tiempo_prestado
from socios
     join prestamos on socio = cod_socio
     join libros on libro = cod_libro
where fecha_devolucion is null;


-- 2: Vista de devoluciones tardías
-- Son aquellos libros que no han sido devueltos en el plazo de 1 mes.
-- Además mostrar el socio que lo posee y su información de contacto.
create view devoluciones_tarde (
    cod_libro, titulo,
    cod_socio, nombre, apellido1, apellido2, email, telefono,
    tiempo_retrasado
)
as select
     s.cod_libro, s.titulo,
     cod_socio, nombre, apellido1, apellido2, email, tu.telefono,
     now() - fecha_prestamo - interval '30 days' as tiempo_retrasado
from socios s
     join prestamos p on p.socio = s.cod_socio
     join libros l on p.libro = l.cod_libro
     join (select cod_socio, max(telefono) as telefono -- PostgreSQL 16 incluye any_value, pero la 13 no
           from telefonos_socios join socios on cod_socio = socio
           group by cod_socio) tu using (cod_socio)
where now() - fecha_prestamo > interval '30 days'
  and fecha_devolucion is null;


-- 3: Libros disponibles en la biblioteca de Matemáticas
create view libros_disponibles (cod_libro, titulo) as
select distinct l.cod_libro, l.titulo 
from libros l join prestamos p on l.cod_libro = p.libro
where p.fecha_devolucion is not null
  and biblioteca = 'Matemáticas';


-- 4: Valoración media de cada libro, junto con su número de reseñas
create view valoracion_media (cod_libro, titulo, valoracion_media, num_valoraciones) as
select libro, titulo, avg("valoracion"), count("valoracion")
from libros join valoraciones on libro = cod_libro
group by libro, titulo;
