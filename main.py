import os
import json
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from dotenv import load_dotenv

load_dotenv()

# Configuración de Cliente (Modo Público para evitar error 403)
auth_manager = SpotifyClientCredentials(
    client_id=os.getenv("SPOTIPY_CLIENT_ID"),
    client_secret=os.getenv("SPOTIPY_CLIENT_SECRET"),
)
sp = spotipy.Spotify(auth_manager=auth_manager)


def sincronizar_biblioteca(url_playlist, nombre_genero):
    # 1. Definir rutas dinámicas según el género
    ruta_carpeta = f"data/{nombre_genero}"
    ruta_archivo = f"{ruta_carpeta}/metadata_{nombre_genero}.json"
    os.makedirs(ruta_carpeta, exist_ok=True)

    # 2. Cargar datos existentes si el archivo ya existe
    datos_existentes = []
    ids_existentes = set()
    if os.path.exists(ruta_archivo):
        with open(ruta_archivo, "r", encoding="utf-8") as f:
            datos_existentes = json.load(f)
            # Creamos un set de IDs para búsqueda rápida (O(1))
            ids_existentes = {cancion["id_spotify"] for cancion in datos_existentes}

    # 3. Extraer ID de la Playlist
    playlist_id = url_playlist.split("/")[-1].split("?")[0]
    print(f"🚀 Sincronizando género: [{nombre_genero.upper()}]")

    nuevas_canciones = 0
    offset = 0

    while True:
        results = sp.playlist_tracks(playlist_id, offset=offset)
        items = results["items"]
        if not items:
            break

        for item in items:
            track = item["track"]
            if track and track["id"] not in ids_existentes:
                # Solo agregamos si el ID no existe en nuestro JSON previo
                nueva_track = {
                    "nombre": track["name"],
                    "artista": track["artists"][0]["name"],
                    "album": track["album"]["name"],
                    "popularidad": track["popularity"],
                    "duracion_ms": track["duration_ms"],
                    "fecha_lanzamiento": track["album"]["release_date"],
                    "id_spotify": track["id"],
                }
                datos_existentes.append(nueva_track)
                ids_existentes.add(track["id"])
                nuevas_canciones += 1

        offset += len(items)
        print(f"🔍 Escaneando... {offset} canciones revisadas.")

    # 4. Guardar la lista actualizada
    with open(ruta_archivo, "w", encoding="utf-8") as f:
        json.dump(datos_existentes, f, indent=4, ensure_ascii=False)

    print(f"\n✨ Sincronización completa para {nombre_genero}:")
    print(f"   - Canciones nuevas añadidas: {nuevas_canciones}")
    print(f"   - Total en base de datos: {len(datos_existentes)}")
    print(f"   - Archivo: {ruta_archivo}\n")


if __name__ == "__main__":
    # --- CONFIGURACIÓN ESTÁNDAR ---
    # Solo cambia estos dos valores para cada nueva biblioteca
    GENERO_ACTUAL = "Hip-Hop"  # Ejemplo: "Rock", "Pop", "Jazz", etc.
    URL_ACTUAL = "https://open.spotify.com/playlist/6uWf1aFMj9atISNW3Hwd7E?si=G8Nd9OioRRWl2FVxkTGXDA"  # URL de la playlist de Spotify que quieres sincronizar

    sincronizar_biblioteca(URL_ACTUAL, GENERO_ACTUAL)
