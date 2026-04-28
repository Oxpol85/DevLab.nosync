import os
import nbformat as nbf
from markdownify import markdownify as md

# 1. CONFIGURACIÓN DE RUTAS (Verificadas según tus capturas)
# Asegúrate de que la carpeta esté descomprimida en Descargas
ruta_base = os.path.expanduser("~/Downloads/python-3.14-docs-html")
ruta_destino = os.path.expanduser("~/Documents/@xpol/GitHub/Hello-Python/Harvardyp")

# Definimos los "Tomos" de tu biblioteca
tomos = {
    "Tutorial": "tutorial",
    "Libreria_Estandar": "library",
    "Referencia_Lenguaje": "reference",
    "Instalacion": "using",
    "Novedades_314": "whatsnew",
}


def construir_tomo(nombre_tomo, subcarpeta):
    origen = os.path.join(ruta_base, subcarpeta)
    if not os.path.exists(origen):
        print(f"❌ Carpeta no encontrada: {origen}")
        return

    # Crear el objeto Notebook
    nb = nbf.v4.new_notebook()
    nb.cells.append(
        nbf.v4.new_markdown_cell(
            f"# 📚 {nombre_tomo.replace('_', ' ')}\n## Origen: Biblia de Guido v3.14"
        )
    )

    # Listar y ordenar archivos HTML
    archivos = sorted([f for f in os.listdir(origen) if f.endswith(".html")])

    print(f"📖 Generando {nombre_tomo}...")

    for archivo in archivos:
        try:
            with open(os.path.join(origen, archivo), "r", encoding="utf-8") as f:
                html_raw = f.read()
                # Convertir a Markdown manteniendo la estructura oficial
                contenido_md = md(html_raw, heading_style="ATX")

                # Crear celdas: Separador -> Título de Archivo -> Contenido
                nb.cells.append(
                    nbf.v4.new_markdown_cell(f"--- \n### 📄 Fuente: {archivo}")
                )
                nb.cells.append(nbf.v4.new_markdown_cell(contenido_md))
                # Insertar una celda de código vacía para tus pruebas de Harvard
                nb.cells.append(nbf.v4.new_code_cell(""))
        except Exception as e:
            print(f"⚠️ Error en {archivo}: {e}")

    # Guardar el archivo final
    nombre_final = f"Zen_{nombre_tomo}_314.ipynb"
    ruta_final = os.path.join(ruta_destino, nombre_final)

    with open(ruta_final, "w", encoding="utf-8") as f:
        nbf.write(nb, f)
    print(f"✅ ¡Éxito! Creado: {nombre_final}")


# 2. EJECUCIÓN MASIVA
print("🚀 Iniciando construcción de la Biblioteca Zen...")
for tomo, carpeta in tomos.items():
    construir_tomo(tomo, carpeta)
print("\n✨ Proceso terminado. Revisa tu carpeta 'Harvardyp'.")
