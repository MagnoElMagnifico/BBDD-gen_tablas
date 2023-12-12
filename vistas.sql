-- 1: Prestamos pendientes
create view prestamos_pendientes (
    cod_socio, nombre, apellido1, apellido2, email,
    cod_libro, titulo, biblioteca,
    tiempo_restante
)
as select 
     cod_socio, nombre, apellido1, apellido2, email,
     cod_libro, titulo, biblioteca,
     now() - fecha_prestamo as tiempo_restante
from socios
     join prestamos on socio = cod_socio
     join libros on libro = cod_libro
where fecha_devolucion is null 

-- 2: Vista de devoluciones tardías
create view devoluciones_tarde (
    cod_libro, titulo,
    cod_socio, nombre, apellido1, apellido2, email, telefono,
    tiempo_retrasado
)
as select
     cod_libro, titulo,
     cod_socio, nombre, apellido1, apellido2, email, tu.telefono,
     now() - fecha_prestamo - interval '30 days' as tiempo_retrasado
from socios s
     join prestamos p on p.socio = s.cod_socio
     join libros l on p.libro = l.cod_libro
     join (select cod_socio, max(telefono) as telefono -- PostgreSQL 16 incluye any_value, pero la 13 no
           from telefonos_socios join socios on cod_socio = socio
           group by cod_socio) tu using(cod_socio)
where now() - fecha_prestamo > interval '30 days'
  and fecha_devolucion is null
order by fecha_prestamo asc

-- 3: Libros disponibles en la biblioteca de Matemáticas
create view libros_disponibles (cod_libro, titulo) as
select cod_libro, titulo
from libros l join bibliotecas b on l.biblioteca = b.nombre
where biblioteca = 'Matemáticas'
except
select cod_libro, titulo
from libros l2
     join bibliotecas b2 on l2.biblioteca = b2.nombre
     join prestamos p on l2.cod_libro = p.libro
where fecha_devolucion is null

-- 4: Valoración media de cada libro, junto con su número de reseñas
create view valoracion_media (cod_libro, titulo, valoracion_media, num_valoraciones) as
select libro, titulo, avg("valoracion"), count("valoracion")
from libros join valoraciones on libro = cod_libro
group by libro, titulo
order by avg("valoracion") desc
