import sqlite3
import csv
import datetime
import shutil
import os

# Archivos
csv_filename = "establecimientos-cultura.csv"
db_filename = "establecimientos-cultura.sqlite"
log_filename = "last-migration.txt"
destination_folder = "../assets/data/"

# Crear la carpeta destino si no existe
os.makedirs(destination_folder, exist_ok=True)

# Conectar a la base de datos
conn = sqlite3.connect(db_filename)
cursor = conn.cursor()

# Leer el archivo CSV correctamente
with open(csv_filename, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    headers = [col.strip().replace(" ", "_") for col in reader.fieldnames if col]  # Limpiar nombres de columnas

    # Verificar encabezados
    if not headers:
        print("Error: El archivo CSV está vacío o no contiene encabezados.")
        conn.close()
        exit()

    # Crear la tabla si no existe
    create_table_query = f"CREATE TABLE IF NOT EXISTS datos ({', '.join(f'"{col}" TEXT' for col in headers)})"
    cursor.execute(create_table_query)

    # Obtener los datos sin filas vacías
    valid_rows = []
    for row in reader:
        cleaned_row = {col: row[col].strip() for col in headers if row[col].strip()}
        if len(cleaned_row) == len(headers):  # Verificar que la fila tenga todos los campos completos
            valid_rows.append(tuple(cleaned_row.values()))

    # Verificar si los datos están correctamente leídos
    print("Primeros datos extraídos:")
    for row in valid_rows[:5]:  # Muestra las primeras 5 filas para depuración
        print(row)

    # Insertar los datos en la tabla si hay registros válidos
    if valid_rows:
        insert_query = f"INSERT INTO datos VALUES ({', '.join('?' for _ in headers)})"
        cursor.executemany(insert_query, valid_rows)
    else:
        print("Advertencia: No se encontraron filas válidas para insertar en la base de datos.")

# Guardar los cambios y cerrar conexión
conn.commit()
conn.close()

# Registrar fecha y hora de migración
with open(log_filename, "w", encoding="utf-8") as log_file:
    log_file.write(f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# Copiar archivos a la carpeta destino
shutil.copy(db_filename, destination_folder)
shutil.copy(log_filename, destination_folder)

print(f"Migración completada exitosamente. Registro guardado en '{log_filename}'.")
print(f"Archivos copiados a {destination_folder}")