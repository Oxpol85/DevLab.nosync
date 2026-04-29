import mss
from PIL import Image
import requests
import base64
from io import BytesIO
from pynput import keyboard
import os
import threading
import subprocess
import re
from datetime import datetime
import os
from dotenv import load_dotenv

# --- CONFIGURACIÓN ---
# Carga las variables del archivo .env
load_dotenv()

# Ahora la API Key se toma del sistema, no está escrita en el código
api_key = os.getenv("GCP_API_KEY")  # Reemplaza con tu API Key de Gemini 3
NOMBRE_MODELO = "models/gemini-3-flash-preview"
URL = f"https://generativelanguage.googleapis.com/v1beta/{NOMBRE_MODELO}:generateContent?key={api_key}"

# Configuración de carpetas
OUTPUT = "OutputCiber"  # Carpeta para guardar evidencias y texto de repaso para repaso posterior."
if not os.path.exists(OUTPUT):
    os.makedirs(OUTPUT)


def guardar_en_historial(respuesta_ia, imagen_pil):
    """Guarda la evidencia en la carpeta OutputCiber"  # Carpeta para guardar evidencias y texto de repaso para repaso posterior. para repaso posterior."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nombre_img = f"captura_{timestamp}.jpg"
    ruta_img = os.path.join(OUTPUT, nombre_img)
    ruta_txt = os.path.join(OUTPUT, "historial_repaso.txt")

    # Guardar imagen
    imagen_pil.save(ruta_img, "JPEG", quality=80)

    # Guardar texto
    with open(ruta_txt, "a", encoding="utf-8") as f:
        f.write(f"\n{'='*50}\n")
        f.write(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"IMAGEN: {nombre_img}\n")
        f.write(f"RETROALIMENTACIÓN:\n{respuesta_ia}\n")

    return nombre_img


def mostrar_resultado_final(texto):
    """Fuerza la ventana de diálogo en macOS."""
    texto_seguro = re.sub(r"[^a-zA-Z0-9\s.,!?áéíóúÁÉÍÓÚñÑ]", "", texto)
    script = f"""
    tell application "System Events"
        activate
        display dialog "{texto_seguro}" with title "RESPUESTA GEMINI 3" buttons {{"CERRAR"}} default button "CERRAR" with icon note
    end tell
    """
    try:
        subprocess.run(["osascript", "-e", script])
    except Exception as e:
        print(f"Error visual: {e}")


def resolver():
    try:
        print(
            f"\n📸 [{datetime.now().strftime('%H:%M:%S')}] Procesando pantalla completa..."
        )
        with mss.mss() as sct:
            img_sct = sct.grab(sct.monitors[1])
            img = Image.frombytes("RGB", img_sct.size, img_sct.bgra, "raw", "BGRX")

            buffered = BytesIO()
            img.save(buffered, format="JPEG", quality=75)
            img_base64 = base64.b64encode(buffered.getvalue()).decode("utf-8")

        print("📡 Consultando IA y filtrando publicidad...")
        prompt = """
        Analiza esta imagen de examen. 
        1. Identifica la pregunta y las opciones (ignora anuncios y basura web).
        2. Dame la respuesta correcta.
        3. Da una breve explicación de 'por qué' es esa la respuesta para mi repaso posterior.
        """

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt},
                        {
                            "inline_data": {
                                "mime_type": "image/jpeg",
                                "data": img_base64,
                            }
                        },
                    ]
                }
            ]
        }

        response = requests.post(URL, json=payload, timeout=20)

        if response.status_code == 200:
            res_json = response.json()
            respuesta = res_json["candidates"][0]["content"]["parts"][0]["text"].strip()

            if respuesta:
                # Guardamos en el repo para retroalimentación
                archivo_guardado = guardar_en_historial(respuesta, img)
                print(f"✅ Historial guardado en: {OUTPUT}/{archivo_guardado}")

                # Mostramos en pantalla
                mostrar_resultado_final(respuesta)
        else:
            print(f"❌ Error API {response.status_code}")

    except Exception as e:
        print(f"⚠️ Error: {e}")


def al_presionar(key):
    if key == keyboard.Key.f9:
        threading.Thread(target=resolver, daemon=True).start()


if __name__ == "__main__":
    print(f"🚀 SISTEMA DE ESTUDIO ACTIVO (Gemini 3)")
    print(f"📂 Repaso: Las respuestas se guardarán en la carpeta '{OUTPUT}'")
    print("--------------------------------------------------")
    print("Presiona F9 para resolver y guardar evidencia.")
    with keyboard.Listener(on_press=al_presionar) as listener:
        listener.join()
