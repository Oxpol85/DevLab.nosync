🎵 MusicSpotify Auth & Data Pipeline
Este proyecto es un Pipeline de Automatización de Datos Musicales diseñado para extraer, organizar y sincronizar bibliotecas de Spotify de forma local. Está optimizado para analistas de datos que buscan gestionar grandes volúmenes de registros (400+ canciones) sin las restricciones de cuentas Premium.

🚀 Características Principales
Sincronización Incremental: Uso de archivos archive.txt para descargar solo las nuevas adiciones, evitando duplicados.

Discriminación por Géneros: Organización automática en subcarpetas parametrizadas.

Enriquecimiento de Metadatos: Inserción automática de etiquetas ID3 (artista, álbum, carátula) en archivos offline.

Gestión de Repositorio Eficiente: Configuración de .gitignore para separar el código de los archivos de datos pesados.

🛠️ Stack Tecnológico
Lenguaje: Python 3.13+

Librerías: spotipy, spotdl, python-dotenv

Motor de Procesamiento: FFmpeg (Multimedia Framework)

Automatización: Bash Scripting (macOS)

📁 Estructura del Proyecto
Plaintext
.
├── main.py # Script original de conexión API (OAuth2)
├── sync_music.sh # Script de automatización y commit automático
├── .env # Credenciales secretas (ignorado por Git)
├── .gitignore # Filtro de archivos para el repositorio
├── venv/ # Entorno virtual de Python
└── downloads/ # ALMACÉN DE DATOS (No sincronizado al repo)
├── Me_Gusta/ # Biblioteca principal y archive.txt
└── [Genero]/ # Carpetas de géneros específicos
⚙️ Configuración e Instalación

1. Entorno Virtual y Dependencias
   Bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
2. Motor de Audio (FFmpeg)
   Esencial para la conversión y el etiquetado de metadatos:

Bash
spotdl --download-ffmpeg 3. Variables de Entorno
Crea un archivo .env con tus credenciales de Spotify Developer:

Plaintext
SPOTIPY_CLIENT_ID='tu_id'
SPOTIPY_CLIENT_SECRET='tu_secret'
SPOTIPY_REDIRECT_URI='http://127.0.0.1:8080'
📈 Flujo de Trabajo (Workflow)
Para procesar una nueva biblioteca, se utiliza el script de automatización:

Se edita sync_music.sh con el nombre del género y la URL.

Se ejecuta ./sync_music.sh.

El script sincroniza la música, actualiza el log de archivos y realiza un commit automático al repositorio con la fecha del proceso.

🧠 Desafíos y Soluciones (Log de Portafolio)
Bloqueo 403 (Premium): Se migró de la API directa de Spotify a un motor de extracción basado en spotdl para permitir la descarga de "Me Gusta" en cuentas gratuitas.

Rate Limiting: Implementación de estrategias de espera y optimización de peticiones para evitar bloqueos por parte de los servidores de Spotify.

Integridad de Datos: Uso de archivos .nosync y .gitignore para prevenir corrupción de archivos en entornos sincronizados con iCloud/OneDrive.

🔮 Mejoras Futuras
[ ] Integración con Pandas para análisis estadístico de BPM y popularidad.

[ ] Dashboard en Streamlit para visualizar hábitos de consumo musical.

[ ] Implementación de un sistema de recomendación basado en la metadata extraída.

Instrucciones para VS Code:
Crea un archivo llamado README.md en tu carpeta raíz.

Pega el contenido anterior.

Presiona Cmd + Shift + V en tu Mac para ver una previsualización elegante de cómo quedará.
