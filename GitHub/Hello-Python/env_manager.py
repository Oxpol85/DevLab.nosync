import os
import subprocess
import sys


def check_dependencies():
    print("🔍 Escaneando dependencias necesarias en el proyecto...")

    # Usamos pipreqs para analizar qué librerías usas realmente en tus .py e .ipynb
    try:
        # El comando '.' indica la carpeta actual
        # '--force' sobrescribe el requirements.txt existente
        subprocess.check_call([sys.executable, "-m", "pipreqs.pipreqs", ".", "--force"])
        print("✅ requirements.txt actualizado automáticamente basado en tus imports.")
    except Exception as e:
        print(
            f"⚠️ Nota: Instala pipreqs para un escaneo más preciso (pip install pipreqs)"
        )
        # Opción B: Fallback al freeze tradicional si pipreqs falla
        with open("requirements.txt", "w") as f:
            subprocess.run([sys.executable, "-m", "pip", "freeze"], stdout=f)
        print("✅ requirements.txt generado mediante 'pip freeze'.")


def setup_virtualenv():
    if not os.path.exists("venv"):
        print("Creating virtual environment...")
        subprocess.check_call([sys.executable, "-m", "venv", "venv"])
        print("✅ Entorno 'venv' creado.")
    else:
        print("ℹ️ El entorno 'venv' ya existe.")


if __name__ == "__main__":
    setup_virtualenv()
    check_dependencies()
    print("\n🚀 Todo listo. Para activar tu entorno usa:")
    print("   source venv/bin/activate (Mac/Linux)")
    print("   .\\venv\\Scripts\\activate (Windows)")
