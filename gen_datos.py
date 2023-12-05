#!/usr/bin/python3

from generar import *
from datetime import date
from itertools import cycle
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

# Argumentos de línea de comandos
parser = argparse.ArgumentParser()
parser.add_argument('salida', help='Nombre del archivo de salida')

parser.add_argument('--vacunodromo', nargs='?', default=VACUNODROMO, help='Archivo TXT de pacientes del vacunodromo')
parser.add_argument('--nombres', nargs='?', default=NOMBRES, help='Archivo CSV de nombres')
parser.add_argument('--apellidos', nargs='?', default=APELLIDOS, help='Archivo CSV de apellidos')
parser.add_argument('--editoriales', nargs='?', default=EDITORIALES, help='Archivo TXT de editoriales')
parser.add_argument('--calles', nargs='?', default=NOMBRES_CALLE, help='Archivo TXT de nombres de calle')

parser.add_argument('--max-datos', type=int, nargs='?', default=100)
parser.add_argument('--num-socios', type=int, nargs='?', default=500)
parser.add_argument('--num-libros', type=int, nargs='?', default=1000)
parser.add_argument('--num-autores', type=int, nargs='?', default=50)
parser.add_argument('--num-bibliotecarios', type=int, nargs='?', default=2*len(BIBLIOTECAS))
parser.add_argument('--num-prestamos', type=int, nargs='?', default=1500)
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


with open(args.salida, 'w') as out:
    # Bibliotecas
    bibliotecas_pk = [] 
    out.write('-- Bibliotecas\n')
    sentencia = 'insert into bibliotecas (nombre, localizacion, telefono, hora_apertura, hora_cierre) values\n'
    for id_socio, bib in enumerate(BIBLIOTECAS):
        bibliotecas_pk.append(bib[0])
        write(out, sentencia, bib, id_socio, len(BIBLIOTECAS))
    
    with NombresVac(args.vacunodromo) as nombres:
        # TODO?: saltar un par de nombres aleatoriamente para que empiece siempre por los mismos

        # Socios
        out.write('\n-- Socios\n')
        sentencia = 'insert into socios (nombre, apellido1, apellido2, email, direccion, grado, fecha_egresado) values\n'

        for id_socio, socio in enumerate(nombres):
            if id_socio >= args.num_socios: break

            tupla = (
                *socio,
                gen_email(*socio),
                gen_direccion(args.calles),
                gen_grado(),
                gen_fecha(date(2000, 1, 1), date.today())
            )

            write(out, sentencia, tupla, id_socio, args.num_socios)

        # TODO: Libros
        
        # Autores
        autores_pk = [] # Se almacenan para luego crear 'escribir'
        out.write('\n-- Autores\n')
        sentencia = 'insert into autores (nombre, apellido1, apellido2, pais, fecha_nacimiento) values\n'

        for id_socio, autor in enumerate(nombres):
            if id_socio >= args.num_autores: break
            autores_pk.append(autor)

            tupla = (*autor, gen_pais(), gen_fecha(date(1900, 1, 1), date(2000, 1, 1)))
            write(out, sentencia, tupla, id_socio, args.num_autores)

        # Bibliotecarios
        bibliotecarios_pk = []
        out.write('\n-- Bibliotecarios\n')
        sentencia = 'insert into bibliotecarios (dni, nombre, apellido1, apellido2, sueldo, hora_entrada, hora_salida, fecha_contrato, biblioteca) values\n'

        for id_socio, (bibliotecario, biblioteca)  in enumerate(zip(nombres, cycle(bibliotecas_pk))):
            if id_socio >= args.num_bibliotecarios: break

            dni = gen_dni()
            bibliotecarios_pk.append(dni)

            # TODO: mejorar el horario de los bibliotecarios repartiendo el tiempo
            # Ahora solo se toma el horario de la biblioteca

            tupla = (
                dni,
                *bibliotecario,
                10 * random.randint(130, 190),
                BIBLIOTECAS[id_socio % len(BIBLIOTECAS)][-2], BIBLIOTECAS[id_socio % len(BIBLIOTECAS)][-1],
                gen_fecha(date(2000, 1, 1), date.today()),
                biblioteca
            )

            write(out, sentencia, tupla, id_socio, args.num_bibliotecarios)
        
        # Valoraciones

        # Prestamos

        # Escribir

        # TelefonosSocios
        out.write('\n-- TelefonosSocios\n')
        sentencia = 'insert into telefonos_socios (socio, telefono) values\n'

        telefonos_esperados = args.num_socios
        num_telefonos = 0

        for id_socio in range(args.num_socios):
            write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
            num_telefonos += 1

            # Posibilidades de tener 2 teléfonos: 1/3
            if random.randint(1, 3) == 1:
                telefonos_esperados += 1
                write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
                num_telefonos += 1

            # Posibilidades de tener 3 teléfonos: 1/3 * 1/4 = 0.167
            if random.randint(1, 4) == 1:
                telefonos_esperados += 1
                write(out, sentencia, (id_socio+1, gen_telefono()), num_telefonos, telefonos_esperados)
                num_telefonos += 1
            

