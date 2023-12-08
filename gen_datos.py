#!/usr/bin/python3

from generar import *
from itertools import cycle
import datetime as dt
import argparse
import random

# Constantes
BIBLIOTECAS = [
    # Nombre, Dirección, Teléfono, HoraApertura, HoraCierre
    ('ETSE',                               'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela',       '881816706', '8:30', '20:30'),
    ('Concepción Arenal',                  'Rúa dos Feáns, s/n. Campus Vida, 15782 Santiago de Compostela',     '881815210', '8:30', '20:30'),
    ('Bioloxía',                           'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela',       '881813246', '8:30', '20:00'),
    ('Ciencias da Comunicación',           'Avda de Castelao, s/n. Campus norte, 15782 Santiago de Compostela', '881816505', '8:30', '20:15'),
    ('Ciencias Económicas e Empresariais', 'Avda. do Burgo, s/n, 15782 Santiago de Compostela',                 '881811510', '8:30', '21:30'),
    ('Enfermaría',                         'Avda. Xoan XXIII, 15782 Santiago de Compostela',                    '881812066', '8:30', '21:30'),
    ('Farmacia',                           'Avenida de Vigo, s/n, 15782 Santiago de Compostela',                '881815242', '8:30', '21:00'),
    ('Filoloxía',                          'Avda. de Castelao, s/n, 15782 Santiago de Compostela',              '881811752', '8:30', '20:20'),
    ('Filosofía',                          'Praza de Mazarelos, s/n, 15782 Santiago de Compostela',             '881812500', '8:30', '20:30'),
    ('Física e Óptica e Optometría',       'Rúa Xosé María Suárez Núñez, s/n, 15782 Santiago de Compostela',    '881814071', '8:30', '21:30'),
    ('Formación do Profesorado',           'Avda. de Ramón Ferreiro, s/n, 27002 Lugo',                          '982821007', '8:30', '21:30'),
    ('Matemáticas',                        'Rúa Lope Gómez de Marzoa, s/n, 15782 Santiago de Compostela',       '881813128', '8:30', '21:00'),
    ('Medicina e Odontoloxía',             'Rúa de San Francisco, s/n , 15782 Santiago de Compostela',          '881812411', '8:30', '21:30'),
    ('Psicoloxía e Ciencias da Educación', 'Rúa Prof. Vicente Fráiz Andón, s/n, 15782 Santiago de Compostela',  '881813720', '8.30', '21.00'),
    ('Xeografía e Historia',               'Praza da Universidade, 1, 15703 Santiago de Compostela',            '881812687', '8:30', '21:30')
]

VACUNODROMO = 'datos/pacientes_vacunodromo.txt'
NOMBRES = 'datos/nombres.csv'
APELLIDOS = 'datos/apellidos.csv'
EDITORIALES = 'datos/editoriales.txt'
NOMBRES_CALLE = 'datos/direcciones.txt'
TITULOS = 'datos/libros.txt'

# Argumentos de línea de comandos
parser = argparse.ArgumentParser()
parser.add_argument('salida', help='Nombre del archivo de salida')

parser.add_argument('--vacunodromo', nargs='?', default=VACUNODROMO, help='Archivo TXT de pacientes del vacunodromo')
parser.add_argument('--nombres', nargs='?', default=NOMBRES, help='Archivo CSV de nombres')
parser.add_argument('--apellidos', nargs='?', default=APELLIDOS, help='Archivo CSV de apellidos')
parser.add_argument('--editoriales', nargs='?', default=EDITORIALES, help='Archivo TXT de editoriales')
parser.add_argument('--calles', nargs='?', default=NOMBRES_CALLE, help='Archivo TXT de nombres de calle')
parser.add_argument('--titulos', nargs='?', default=TITULOS, help='Archivo TXT de títulos de libros')

parser.add_argument('--max-datos', type=int, nargs='?', default=100)
parser.add_argument('--num-socios', type=int, nargs='?', default=300) # 300
parser.add_argument('--num-libros', type=int, nargs='?', default=900) # 900
parser.add_argument('--num-autores', type=int, nargs='?', default=75) # 75
parser.add_argument('--num-bibliotecarios', type=int, nargs='?', default=2*len(BIBLIOTECAS))
parser.add_argument('--num-prestamos', type=int, nargs='?', default=3000)
args = parser.parse_args()


def write(file, sentencia, data, i, max):
    end = False

    # Si en la iteración siguiente hay que terminar la sentencia,
    # en esta línea se añade en final de sentencia.
    #
    # Lo mismo ocurre si se terminan los datos.
    if (i+1) % args.max_datos == 0 or i == max-1:
        end = True

    if i % args.max_datos == 0:
        file.write(sentencia)

    ending = ',\n' if not end else ';\n\n'
    file.write(f'  {data}{ending}')


with open(args.salida, 'w') as out, NombresVac(args.vacunodromo) as nombres, open(args.titulos, 'r') as titulos:
    #### Bibliotecas ####
    bibliotecas_pk = [] 
    out.write('-- Bibliotecas\n')
    sentencia = 'insert into bibliotecas (nombre, localizacion, telefono, hora_apertura, hora_cierre) values\n'
    for id_socio, bib in enumerate(BIBLIOTECAS):
        bibliotecas_pk.append(bib[0])
        write(out, sentencia, bib, id_socio, len(BIBLIOTECAS))

    #### Socios ####
    out.write('\n-- Socios\n')
    sentencia = 'insert into socios (nombre, apellido1, apellido2, email, direccion, grado, fecha_egresado) values\n'

    for id_socio, socio in enumerate(nombres):
        if id_socio >= args.num_socios: break

        tupla = (
            *socio,
            gen_email(*socio),
            gen_direccion(args.calles),
            gen_grado(),
            gen_fecha(dt.date(2000, 1, 1), dt.date.today()).strftime('%Y-%m-%d')
        )

        write(out, sentencia, tupla, id_socio, args.num_socios)

    #### Libros ####
    libros_biblioteca = []
    out.write('\n-- Libros\n')
    sentencia = 'insert into libros (titulo, idioma, editorial, edicion, fecha_pub, paginas, biblioteca) values\n'

    for id_libro, titulo in enumerate(titulos):
        if id_libro >= args.num_libros: break

        tupla = (
            titulo.strip(),
            gen_idioma(),
            gen_editorial(args.editoriales),
            random.randint(1, 15),
            gen_fecha(dt.date(1960, 1, 1), dt.date.today()).strftime('%Y-%m-%d'),
            random.randint(150, 1500),
            random.choice(bibliotecas_pk)
        )

        write(out, sentencia, tupla, id_libro, args.num_libros)
        libros_biblioteca.append(tupla[-1])

    
    #### Autores ####
    autores_pk = []
    out.write('\n-- Autores\n')
    sentencia = 'insert into autores (nombre, apellido1, apellido2, pais, fecha_nacimiento) values\n'

    for id_socio, autor in enumerate(nombres):
        if id_socio >= args.num_autores: break
        autores_pk.append(autor)

        tupla = (*autor, gen_pais(), gen_fecha(dt.date(1900, 1, 1), dt.date(2000, 1, 1)).strftime('%Y-%m-%d'))
        write(out, sentencia, tupla, id_socio, args.num_autores)

    #### Bibliotecarios ####
    # El horario del bibliotecario debe ser coherente con el de la biblioteca
    bibliotecarios_pk = []
    out.write('\n-- Bibliotecarios\n')
    sentencia = 'insert into bibliotecarios (dni, nombre, apellido1, apellido2, sueldo, hora_entrada, hora_salida, fecha_contrato, biblioteca) values\n'

    for id_socio, (bibliotecario, biblioteca) in enumerate(zip(nombres, cycle(bibliotecas_pk))):
        if id_socio >= args.num_bibliotecarios: break

        dni = gen_dni()
        bibliotecarios_pk.append((dni, biblioteca))

        # TODO: mejorar el horario de los bibliotecarios repartiendo el tiempo
        # Ahora solo se toma el horario de la biblioteca

        tupla = (
            dni,
            *bibliotecario,
            10 * random.randint(130, 190),
            BIBLIOTECAS[id_socio % len(BIBLIOTECAS)][-2], BIBLIOTECAS[id_socio % len(BIBLIOTECAS)][-1],
            gen_fecha(dt.date(2000, 1, 1), dt.date.today()).strftime('%Y-%m-%d'),
            biblioteca
        )

        write(out, sentencia, tupla, id_socio, args.num_bibliotecarios)
    
    #### Escribir ####
    # No se puede repetir el mismo autor para el mismo libro
    # Hay otros coautores, pero son menos probables
    out.write('\n-- Escribir\n')
    sentencia = 'insert into escribir (autor_nombre, autor_apellido1, autor_apellido2, libro) values\n'

    # Rellenar el conjunto de datos, lo que nos
    # garantiza que no habrá elementos repetidos
    escribir_pk = set()

    for id_libro in range(args.num_libros):
        num_autores_libro = random.choices([1, 2, 3, 4], weights=[50, 30, 20, 5])[0]

        for _ in range(num_autores_libro):
            escribir_pk.add((*random.choice(autores_pk), id_libro+1))

    # Finalmente, escribir los datos
    for i, tupla in enumerate(escribir_pk):
        write(out, sentencia, tupla, i, len(escribir_pk))

    #### Prestamos ####
    # El libro está en una biblioteca y en la que hay unos determinados bibliotecarios
    # No se puede repetir la combinación (socio, libro, bibliotecario, fecha_prestamo)
    out.write('\n-- Prestamos\n')
    sentencia = 'insert into prestamos (socio, libro, bibliotecario, fecha_prestamo, fecha_devolucion) values\n'
    
    prestamos_pk = set()

    for i in range(args.num_prestamos):
        tupla = None

        while True:
            # Generar las fechas de devolución
            if random.choices([True, False], weights=[2, 10])[0]:
                # Todavía no ha sido devuelto
                fecha_prestamo = dt.date.today() - dt.timedelta(days=random.randint(0, 40))
                fecha_devolucion = 'null'

                fecha_prestamo = fecha_prestamo.strftime('%Y-%m-%d')

            else:
                # Ya ha sido devuelto
                fecha_prestamo = gen_fecha(dt.date(2000, 1, 1), dt.date.today())
                fecha_devolucion = fecha_prestamo + dt.timedelta(days=random.randint(5, 40))

                fecha_prestamo = fecha_prestamo.strftime('%Y-%m-%d')
                fecha_devolucion = fecha_devolucion.strftime('%Y-%m-%d')

            cod_libro = random.randint(1, args.num_libros)
            posibles_bibliotecarios = [bibliotecario for bibliotecario, biblioteca in bibliotecarios_pk if biblioteca == libros_biblioteca[cod_libro-1]]

            tupla = (
                random.randint(1, args.num_socios),
                cod_libro,
                random.choice(posibles_bibliotecarios),
                fecha_prestamo,
                fecha_devolucion
            )

            if tupla[:-1] not in prestamos_pk:
                prestamos_pk.add(tupla[:-1])
                break

        write(out, sentencia, tupla, i, args.num_prestamos)

    #### Valoraciones ####
    # Solo puede haber valoraciones sobre libros que han sido prestados por ese socio
    # No tiene por qué haber valoraciones de todos y cada uno de los préstamos
    out.write('\n-- Valoraciones\n')
    sentencia = 'insert into valoraciones (socio, libro, valoracion) values\n'

    num_valoraciones = 0
    valoraciones_esperadas = int((random.uniform(0.55, 0.25)) * len(prestamos_pk))

    for socio, libro, _, _ in cycle(prestamos_pk):
        if num_valoraciones >= valoraciones_esperadas: break

        if random.choices([True, False], weights=[3, 7])[0]:
            continue

        tupla = (socio, libro, random.randint(10, 50) / 10)
        write(out, sentencia, tupla, num_valoraciones, valoraciones_esperadas)
        num_valoraciones += 1

    #### TelefonosSocios ####
    out.write('\n-- TelefonosSocios\n')
    sentencia = 'insert into telefonos_socios (socio, telefono) values\n'

    telefonos_esperados = args.num_socios
    num_telefonos = 0

    for id_socio in range(args.num_socios):
        write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
        num_telefonos += 1

        # Posibilidades de tener 2 teléfonos: 1/3
        if num_telefonos < telefonos_esperados and random.randint(1, 3) == 1:
            telefonos_esperados += 1
            write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
            num_telefonos += 1

        # Posibilidades de tener 3 teléfonos: 1/3 * 1/4 = 0.167
        if num_telefonos < telefonos_esperados and random.randint(1, 4) == 1:
            telefonos_esperados += 1
            write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
            num_telefonos += 1
