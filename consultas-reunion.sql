-- Obtener el nombre de todos los libros que han sido prestados en 2022
select l.titulo
from libros l, prestamos p
where l.cod_libro = p.libro
	and (p.fecha_prestamo > '2021-12-31' and p.fecha_prestamo < '2023-01-01')


-- Obtener el nombre del usuario que más libros ha tomado prestados
select numlibros.nombre
from (select s.nombre , count(socio) as num
	  from prestamos p, socios s
	  where p.socio = s.cod_socio
	  group by s.cod_socio) as numlibros
where numlibros.num in (select max(num)
                        from (select socio, count(socio) as num
                              from prestamos p
                              group by socio) as numlibros)


-- Obtener el autor con más libros escritos
select a.nombre, a.apellido1, a.apellido2, count(l.cod_libro) libros_escritos
from autores a
    join escribir e on a.nombre = e.autor_nombre and a.apellido1 = e.autor_apellido1 and a.apellido2 = e.autor_apellido2
    join libros l on e.libro = l.cod_libro
group by a.nombre, a.apellido1, a.apellido2
order by count(l.cod_libro) desc
limit 1


-- Obtener el libro o libros con una valoración mayor a 4.5
select libro,titulo, avg("valoracion") valoracion_media, count("valoracion") num_valoraciones
from libros join valoraciones on libro = cod_libro
group by libro, titulo
having avg("valoracion") > 4.5
order by valoracion_media desc
