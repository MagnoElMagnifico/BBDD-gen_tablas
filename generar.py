import random 
import csv

IDIOMAS = {
    'valores': ['Español', 'Inglés', 'Francés', 'Italiano', 'Alemán'],
    'probabilidad': [30, 15, 2, 1, 1]
}
PAISES = [
    'España',
    'Reino Unido',
    'Estados Unidos',
    'México',
    'Argentina',
    'Venezuela',
    'Alemania',
    'Noruega',
    'Francia',
    'Italia'
]
GRADOS = [
    'Administración y Dirección de Empresas',
    'Biología',
    'Biotecnología',
    'Ciencias Ambientales',
    'Ciencias de la Actividad Física y del Deporte',
    'Ciencias Políticas y de la Administración',
    'Comunicación Audiovisual',
    'Derecho',
    'Economía',
    'Educación Infantil',
    'Educación Primaria',
    'Enfermería',
    'Farmacia',
    'Física',
    'Geografía y Ordenación del Territorio',
    'Historia',
    'Informática',
    'Ingeniería Agrícola',
    'Ingeniería Civil',
    'Ingeniería de la Energía',
    'Ingeniería de Sistemas de Telecomunicación',
    'Ingeniería Electrónica Industrial y Automática',
    'Lengua Española y Literaturas Hispánicas',
    'Matemáticas',
    'Medicina',
    'Nutrición Humana y Dietética',
    'Odontología',
    'Pedagogía',
    'Psicología',
    'Química',
    'Relaciones Laborales y Recursos Humanos',
    'Trabajo Social',
    'Turismo'
]
DOMINIOS = {
    'valores': ['@usc.es', '@rai.usc.es', '@gmail.com', '@hotmail.com', '@yahoo.com'],
    'probabilidad': [10, 50, 40, 5, 5]
}
PROVINCIAS = {
    'valores': [
        'La Coruña',
        'Pontevedra',
        'Lugo',
        'Ourense',
        # -- Menos probables ------
        'Asturias',
        'Badajoz',
        'Baleares',
        'Barcelona',
        'Castellón',
        'Granada',
        'León',
        'Madrid',
        'Las Palmas',
        'Pontevedra',
        'Sevilla',
        'Tenerife',
        'Toledo',
        'Vizcaya',
        'Zaragoza'
    ],
    'probabilidad': [15, 10, 8, 8] + [1]*15
}
PREFIJOS_CALLE = ['Avenida', 'Rúa', 'Calle', 'Lugar', 'Plaza', 'Paseo']

# https://stackoverflow.com/questions/3540288/how-do-i-read-a-random-line-from-one-file
def read_random_line(afile):
    # Bastante ineficiente, pero funciona
    line = next(afile)
    for num, aline in enumerate(afile, 2):
        if random.randrange(num):
            continue
        line = aline
    return line.strip()

def gen_idioma():
    return random.choices(IDIOMAS['valores'], weights=IDIOMAS['probabilidad'])[0]

def gen_email(nombre, apellido1, apellido2):
    nombre = nombre.lower()
    apellido1 = apellido1.lower()
    apellido2 = apellido2.lower()

    sep = random.choice(['', '.'])
    dominio = random.choices(DOMINIOS['valores'], weights=DOMINIOS['probabilidad'])[0]

    match random.randrange(0, 3):
        case 0:
            return f'{nombre}{sep}{random.randrange(1,99)}{dominio}'
        case 1:
            return f'{apellido1}{sep}{nombre}{dominio}'
        case 2:
            return f'{nombre}{sep}{apellido1}{sep}{apellido2}{dominio}'
        case 3:
            return f'{apellido1}{sep}{random.randrange(1,99)}{dominio}'
 
def gen_telefono():
    return str(random.randint(600_000_000, 999_999_999))

def gen_dni():
    num = random.randrange(10_00_00_00, 99_99_99_99)
    return str(num) + 'TRWAGMYFPDXBNJZSQVHLCKE'[num % 23]

def gen_direccion(calles):
    prefijo = random.choice(PREFIJOS_CALLE)
    numero = random.randint(100, 500)
    provincia = random.choices(PROVINCIAS['valores'], weights=PROVINCIAS['probabilidad'])[0]

    with open(calles, 'r') as f:
        nombre = read_random_line(f)
        return f'{prefijo} {nombre}, {numero}, {provincia}'

def gen_fecha(inicio, fin):
    año = random.randint(inicio.year, fin.year)
    mes = random.randint(inicio.month, fin.month)
    dia = random.randint(inicio.day, fin.day)
    return f'{año}-{mes}-{dia}'

def gen_grado():
    return random.choice(GRADOS)

def gen_pais():
    return random.choice(PAISES)

# Son 10_000 nombres diferentes
class NombresVac:
    def __init__(self, path):
        self.archivo = open(path, 'r')
        self.in_with = False

    def __next__(self):
        if not self.in_with:
            self.__exit__()
            raise RuntimeError('Must use in `with` clause')

        nombre_cmpt = next(self.archivo).split('-')[0].strip().split(' ')
        return (' '.join(nombre_cmpt[:-2]).title(), nombre_cmpt[-1].title(), nombre_cmpt[-2].title())

    def __iter__(self):
        return self

    # Para usar en el en with
    def __enter__(self):
        self.in_with = True
        return self
    
    def __exit__(self, exc_type, exc_value, traceback):
        self.in_with = False
        self.archivo.close()

# Genera 12_924 nombres diferentes
class NombresCSV:
    def __init__(self, path_nombres, path_apellidos):
        self.nombres = open(path_nombres, 'r')
        self.apellidos = open(path_apellidos, 'r')

        self.csv_nombres = csv.reader(self.nombres, delimiter=',')
        self.csv_apellidos = csv.reader(self.apellidos, delimiter=',')

        self.in_with = False

    def __next__(self):
        if not self.in_with:
            self.__exit__()
            raise RuntimeError('Must use in `with` clause')

        nombre = next(csv_nombres)
        apellido1 = next(csv_apellidos)
        apellido2 = next(csv_apellidos)
        return (nombre[0].title(), apellido1[0].title(), apellido2[0].title())

    def __iter__(self):
        return self

    # Para usar en el en with
    def __enter__(self):
        self.in_with = True
        return self
    
    def __exit__(self, exc_type, exc_value, traceback):
        self.in_with = False
        self.nombres.close()
        self.apellidos.close()