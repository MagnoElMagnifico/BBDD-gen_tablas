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