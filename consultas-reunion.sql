-- 1: Obtener el nombre de todos los libros que han sido prestados en 2022
select l.titulo
from libros l, prestamos p
where l.cod_libro = p.libro
  and (p.fecha_prestamo > '2021-12-31' and p.fecha_prestamo < '2023-01-01')

-- Alternativa: usando joins
select l.titulo
from libros l join prestamos p on l.cod_libro = p.libro
where p.fecha_prestamo > '2021-12-31'
  and p.fecha_prestamo < '2023-01-01'


-- 2: Obtener el nombre del usuario que más libros ha tomado prestados
-- TODO: Actualizar esto
select numlibros.nombre
from (select s.nombre , count(socio) as num
      from prestamos p, socios s
      where p.socio = s.cod_socio
      group by s.cod_socio) as numlibros
where numlibros.num in (select max(num)
                        from (select socio, count(socio) as num
                              from prestamos p
                              group by socio) as numlibros)

-- Otra solución más sencilla
select s.nombre, count (s.cod_socio) as num
from socios s, prestamos p
where s.cod_socio = p.socio
group by s.cod_socio
having count(s.cod_socio) = (select count(s2.cod_socio) as num
                             from socios s2, prestamos p2
                             where s2.cod_socio = p2.socio
                             group by s2.cod_socio
                             order by num desc
                             limit 1)


-- 3: Obtener el autor con más libros escritos
-- TODO: autores con mismo numero de libros escritos
select a.nombre, a.apellido1, a.apellido2, count(l.cod_libro) libros_escritos
from autores a
    join escribir e on (a.nombre = e.autor_nombre and a.apellido1 = e.autor_apellido1 and a.apellido2 = e.autor_apellido2)
    join libros l on e.libro = l.cod_libro
group by a.nombre, a.apellido1, a.apellido2
order by count(l.cod_libro) desc
limit 1


-- 4: Obtener la valoración media de cada autor según los libros que ha escrito
select a.nombre, a.apellido1, a.apellido2, avg(v."valoracion") valoracion_autor, count(v."valoracion") num_valoraciones
from autores a
     join escribir e on (a.nombre = e.autor_nombre and a.apellido1 = e.autor_apellido1 and a.apellido2 = e.autor_apellido2)
     join libros l on (e.libro = l.cod_libro)
     join valoraciones v on (l.cod_libro = v.libro)
group by a.nombre, a.apellido1, a.apellido2 
order by valoracion_autor desc

-- TODO: alternativa usando la vista

-- 5: Obtener el nombre de los autores que tienen 5 libros o más en la "ETSE"
select a.nombre, a.apellido1, a.apellido2
from autores a, libros l, escribir e  
where e.autor_nombre = a.nombre
  and e.autor_apellido1 = a.apellido1
  and e.autor_apellido2 = a.apellido2
  and e.libro = l.cod_libro
  and l.biblioteca = 'ETSE'
group by a.nombre, a.apellido1, a.apellido2
having count(a.nombre) >= 5

-- Alternativa: usando joins
select a.nombre, a.apellido1, a.apellido2
from autores a
    join escribir e on (
        a.nombre = e.autor_nombre
        and a.apellido1 = e.autor_apellido1
        and a.apellido2 = e.autor_apellido2)
    join libros l on e.libro = l.cod_libro
where l.biblioteca = 'ETSE'
group by a.nombre, a.apellido1, a.apellido2
having count(a.nombre) >= 5


-- 6: Obtener todos los libros que ha tomado prestado el usuario que más tiempo lleva matriculado en la universidad
select l.*
from libros l, socios s, prestamos p
where p.libro = l.cod_libro
  and p.socio = s.cod_socio
  and s.fecha_egresado = (select min(s2.fecha_egresado) from socios s2)

-- Alternativa: usando joins
select l.*
from libros l
    join prestamos p on p.libro = l.cod_libro
    join socios s on p.socio = s.cod_socio
where s.fecha_egresado = (select min(s2.fecha_egresado) from socios s2)


-- 7: Obtener el usuario que más libros ha valorado.
select s.nombre, s.cod_socio, count(*)
from socios s , valoraciones v
where s.cod_socio = v.socio
group by s.nombre, s.cod_socio 
having count(*) >= all(select count(*)
                       from valoraciones v2
                       group by v2.socio)

-- 8: Los 30 mejores valorados libros disponibles de matemáticas
select l.*, v.valoracion
from libros l join valoraciones v on l.cod_libro = v.libro 
where l.cod_libro in (select ld.cod_libro from libros_disponibles ld)
order by v.valoracion desc
limit 30

-- TODO?: mostrar ejemplo sin la vista