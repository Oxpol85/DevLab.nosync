#!/bin/zsh

# --- CONFIGURACIÓN DE TEST ---
# Cambia estas dos líneas para cada nuevo género que pruebes
GENERO="Hip-Hop" # <--- PEGA EL NOMBRE DE TU GÉNERO AQUÍ    
URL_PLAYLIST="https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBMm1?si=...1" # <--- PEGA TU URL REAL AQUÍ

# Rutas automáticas
DIRECTORIO="downloads/$GENERO"
ARCHIVE="$DIRECTORIO/archive.txt"

echo "📂 Preparando carpeta: $DIRECTORIO"
mkdir -p "$DIRECTORIO"

echo "🚀 Iniciando descarga incremental..."
# Ejecutamos spotdl
spotdl download "$URL_PLAYLIST" \
    --output "$DIRECTORIO/{artist} - {title}.{output-ext}" \
    --archive "$ARCHIVE"

# --- AUTOMATIZACIÓN DE GIT ---
echo "📦 Sincronizando con el repositorio..."
git add .
# Commit con fecha y género para tu historial de analítica
git commit -m "update: sincronización de biblioteca [$GENERO] - $(date +'%Y-%m-%d %H:%M')"

echo "✅ Proceso terminado. Repositorio actualizado."

#Ahora, cada vez que quieras actualizar todo, solo tienes que escribir: ./sync_music.sh =/plisando Enter, y el script se encargará de descargar solo las nuevas canciones de la playlist, 
#actualizar el archivo de registro y preparar el commit para que puedas revisar los cambios antes de hacer push.