-- Obtener el nombre de todos los libros en la “Biblioteca ETSE”
select titulo
from libros
where biblioteca  = 'ETSE'


-- Obtener todos los datos del libro “Física de Partículas”
select *
from libros
where titulo = 'Física de Partículas'


-- Obtener los datos de todos bibliotecarios que tengan un sueldo inferior a la media
select *
from bibliotecarios
where sueldo < (select avg(sueldo) from bibliotecarios)


-- Obtener todos los autores del país "España"
select *
from autores
where pais = 'España'


-- Obtener el libro con la fecha de publicación más reciente.
select *
from libros
where fecha_pub = (select max(fecha_pub) from libros)


-- Obtener todos los datos del bibliotecario que entra más pronto a trabajar.
select *
from bibliotecarios
where hora_entrada = (select min(hora_entrada) from bibliotecarios)


-- Obtener todos los datos de los usuarios que no tienen como correo de contacto uno con el dominio “@rai.usc.es”, “@usc.es”.
select *
from socios
where email not like '%@rai.usc.es%'
  and email not like '%@usc.es%'


-- Obtener el nombre de todos los usuarios con grado “Ingeniería Informática”
select *
from socios
where grado = 'Informática'
