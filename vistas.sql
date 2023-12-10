-- Vista de libros en préstamos
create view libros_prestados (cod_libro, titulo, cod_socio, nombre, apellido1, apellido2, dias_restantes)
as
select cod_libro, titulo, cod_socio, nombre, apellido1, apellido2, now() - fecha_prestamo as dias_restantes
from libros
     join prestamos on libro = cod_libro
     join socios on socio = cod_socio
where fecha_devolucion is null
  and biblioteca = 'Matemáticas'
order by dias_restantes desc

select * from libros_prestados