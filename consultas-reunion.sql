-- 1: Obtener todos los libros que han sido prestados en 2022
select distinct l.*
from libros l join prestamos p on l.cod_libro = p.libro
where p.fecha_prestamo > '2021-12-31'
  and p.fecha_prestamo < '2023-01-01'


-- 2: Obtener el nombre del usuario que más libros ha tomado prestados
select s.cod_socio, s.nombre, s.apellido1, s.apellido2,
       count (s.cod_socio) as num
from socios s join prestamos p
     on s.cod_socio = p.socio
group by s.cod_socio, s.nombre, s.apellido1, s.apellido2 
having count(s.cod_socio) = (select count(s2.cod_socio) as num
                             from socios s2 join prestamos p2
                                  on s2.cod_socio = p2.socio
                             group by s2.cod_socio
                             order by num desc
                             limit 1)


-- 3: Obtener el autor con más libros escritos
with autores_libros as (
    select * from autores a join escribir e on (
        a.nombre = e.autor_nombre
        and a.apellido1 = e.autor_apellido1
        and a.apellido2 = e.autor_apellido2
    )
)
select nombre, apellido1, apellido2, count(libro) num_libros
from autores_libros
group by nombre, apellido1, apellido2
having count(libro) = (select count(libro) num
                       from autores_libros
                       group by nombre, apellido1, apellido2
                       order by num desc
                       limit 1)


-- 4: Obtener la valoración media de cada autor según los libros que ha escrito
select a.nombre, a.apellido1, a.apellido2,
       round(avg(v.valoracion), 1) valoracion_autor,
       count(v.valoracion) num_valoraciones
from escribir e join valoraciones v on l.cod_libro = v.libro
group by a.nombre, a.apellido1, a.apellido2 
order by valoracion_autor desc, num_valoraciones desc


-- 5: Obtener el nombre de los autores que tienen 5 libros o más en la "ETSE"
select a.nombre, a.apellido1, a.apellido2
from escribir e join libros l on e.libro = l.cod_libro
where l.biblioteca = 'ETSE'
group by a.nombre, a.apellido1, a.apellido2
having count(a.nombre) >= 5


-- 6: Obtener todos los libros que ha tomado prestado el usuario que más tiempo lleva matriculado en la universidad
select distinct l.*
from libros l
    join prestamos p on p.libro = l.cod_libro
    join socios s on p.socio = s.cod_socio
where s.fecha_egresado = (select min(s2.fecha_egresado)
                          from socios s2)


-- 7: Obtener el usuario que más libros ha valorado.
select s.nombre, s.cod_socio, count(*)
from socios s, valoraciones v
where s.cod_socio = v.socio
group by s.nombre, s.cod_socio 
having count(*) >= all(select count(*)
                       from valoraciones v2
                       group by v2.socio)


-- 8: Los 30 mejores valorados libros disponibles de matemáticas
select l.cod_libro, l.titulo, round(avg(v.valoracion), 1) valoracion_media
from libros l
     join valoraciones v on l.cod_libro = v.libro
     join prestamos p on l.cod_libro = p.libro
where p.fecha_devolucion is not null
  and l.biblioteca = 'Matemáticas'
group by l.cod_libro, l.titulo
order by valoracion_media desc
limit 30

-- Alternativa más sencilla: usando vistas
select l.cod_libro, l.titulo, round(vm.valoracion_media, 1) valoracion_media
from libros l join valoracion_media vm
        on l.cod_libro = vm.cod_libro
where l.cod_libro in (select cod_libro
                      from libros_disponibles)
order by valoracion_media desc
limit 30
