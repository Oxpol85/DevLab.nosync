#!/bin/bash

set -e

# ============================================================
# CONFIGURACIÓN
# ============================================================

REMOTE="origin"

# ============================================================
# UTILIDADES
# ============================================================

error() {
    echo "❌ $1"
    exit 1
}

separator() {
    echo ""
    echo "------------------------------------------------------------"
    echo ""
}

# ============================================================
# 1. VERIFICAR REPOSITORIO Y WORKING TREE
# ============================================================

check_repository() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error "Este directorio no es un repositorio Git."
    fi
}

check_working_tree() {
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "❌ Hay cambios locales pendientes (Working tree sucio)."
        echo ""
        git status --short
        echo ""
        echo "🛑 Sincronización cancelada para proteger tus apuntes no guardados."
        echo "🌐 Ejecuta ./push.sh para commitear primero, o usa 'git stash' si quieres descartarlos temporalmente."
        exit 1
    fi
}

get_current_branch() {
    CURRENT_BRANCH=$(git branch --show-current)

    if [[ -z "$CURRENT_BRANCH" ]]; then
        error "No se pudo determinar la rama actual."
    fi

    echo "🌿 Rama actual: $CURRENT_BRANCH"
}

# ============================================================
# 2. ACTUALIZAR Y ANALIZAR HISTORIAL
# ============================================================

fetch_remote() {
    echo ""
    echo "📶 Actualizando información remota..."
    if ! git fetch "$REMOTE" "$CURRENT_BRANCH" 2>/dev/null; then
        echo "⚠️ No se encontró la rama remota o no hay conexión."
        REMOTE_COMMITS=0
        LOCAL_COMMITS=$(git rev-list --count HEAD)
        HISTORY_STATE="LOCAL_AHEAD"
        return
    fi
}

analyze_history() {
    LOCAL_COMMITS=$(git rev-list --count "origin/$CURRENT_BRANCH..HEAD")
    REMOTE_COMMITS=$(git rev-list --count "HEAD..origin/$CURRENT_BRANCH")

    echo ""
    echo "🔎 Estado del historial:"
    echo "Local:  $LOCAL_COMMITS commits pendientes de subir."
    echo "Remote: $REMOTE_COMMITS commits nuevos en la nube."
    echo ""

    if [[ "$LOCAL_COMMITS" -eq 0 && "$REMOTE_COMMITS" -eq 0 ]]; then
        HISTORY_STATE="SYNC"
    elif [[ "$LOCAL_COMMITS" -gt 0 && "$REMOTE_COMMITS" -eq 0 ]]; then
        HISTORY_STATE="LOCAL_AHEAD"
    elif [[ "$LOCAL_COMMITS" -eq 0 && "$REMOTE_COMMITS" -gt 0 ]]; then
        HISTORY_STATE="REMOTE_AHEAD"
    else
        HISTORY_STATE="DIVERGED"
    fi
}

# ============================================================
# 3. MANEJADORES DE ESTADO GIT
# ============================================================

handle_sync() {
    echo "🟢 El repositorio Git ya está 100% sincronizado."
}

handle_local_ahead() {
    echo "🆙 Tienes commits locales que todavía no están en GitHub."
    echo "💡 Ejecuta ./push.sh para publicar tus cambios cuando estés listo."
}

handle_remote_ahead() {
    echo "📥 GitHub contiene cambios nuevos."
    echo "⬇️ Actualizando mediante Fast-Forward..."

    if ! git pull --ff-only "$REMOTE" "$CURRENT_BRANCH"; then
        echo ""
        echo "❌ Git no pudo realizar Fast-Forward. Es posible que alguien haya reescrito la historia."
        echo "⚠️ Se requiere intervención manual (git pull --rebase)."
        exit 1
    fi
    echo "✅ Código descargado y actualizado correctamente."
}

show_divergence_diagnosis() {
    separator
    echo "⚠️ HISTORIAL DIVERGENTE"
    echo "Local:  $LOCAL_COMMITS commits | Remote: $REMOTE_COMMITS commits"
    echo ""
    echo "📌 Diferencias entre local y remoto:"
    git diff --stat "HEAD..origin/$CURRENT_BRANCH"
    echo ""
    echo "📌 Historial reciente:"
    git log --oneline --graph --decorate --all -15
    echo ""
}

divergence_menu() {
    while true; do
        echo ""
        echo "⚠️ HISTORIAL DIVERGENTE DETECTADO"
        echo "Tus apuntes locales y la nube han tomado caminos distintos."
        echo ""
        echo "1) 🔎 Mostrar diagnóstico"
        echo "2) 🚧 Rebase (Recomendado: aplica tus cambios sobre lo que viene de la nube)"
        echo "3) 🔀 Merge  (Crea un commit de unión explícito)"
        echo "4) 🌐 Ejecutar Push.sh (Ir a enviar cambios)"
        echo "5) ♿️ Salir"
        echo ""

        read -r -p "Selecciona una opción: " option

        case "$option" in
            1) show_divergence_diagnosis ;;
            2)
                echo -e "\n🚧 Ejecutando Rebase..."
                if git rebase "origin/$CURRENT_BRANCH"; then
                    echo "✅ Rebase completado. Entorno alineado."
                    return 0
                else
                    echo -e "\n🚨 REBASE DETENIDO. Hay conflictos en el código."
                    echo "Resuélvelos manualmente, ejecuta 'git add <archivo>' y luego 'git rebase --continue'."
                    exit 1
                fi
                ;;
            3)
                echo -e "\n🔀 Ejecutando Merge..."
                if git merge "origin/$CURRENT_BRANCH"; then
                    echo "✅ Merge completado."
                    return 0
                else
                    echo -e "\n🚨 MERGE DETENIDO por conflictos."
                    echo "Resuélvelos en tu editor, haz un commit y vuelve a ejecutar el script."
                    exit 1
                fi
                ;;
            4) echo "Cambiando a Push..."; exit 0 ;;
            5) echo "🛑 Operación cancelada."; exit 0 ;;
            *) echo "❌ Opción inválida." ;;
        esac
    done
}

# ============================================================
# 4. ECOSISTEMA PYTHON Y UV
# ============================================================

check_uv_environment() {
    echo ""
    echo "🐍 Verificando entorno virtual con UV..."

    if ! command -v uv &> /dev/null; then
        error "'uv' no está instalado. Ejecuta: curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi

    # Ajustado a "venv" en lugar de ".venv"
    if [[ ! -d "venv" ]]; then
        echo "📦 Creando venv hiper-rápido..."
        uv venv venv > /dev/null
        echo "✅ venv creado."
    fi

    PYTHON_VERSION=$(uv run python --version)
    echo "✅ Runtime: $PYTHON_VERSION"
}

install_dependencies() {
    echo ""
    echo "📦 Verificando dependencias de estudio..."

    # Autocrear archivos si no existen en este módulo/laboratorio
    if [[ ! -f "requirements.txt" ]]; then
        touch requirements.txt
    fi
    if [[ ! -f "requirements-dev.txt" ]]; then
        echo -e "flake8\npytest" > requirements-dev.txt
    fi

    echo "♻️ Instalando dependencias con UV..."
    uv pip install -r requirements.txt -r requirements-dev.txt > /dev/null
    echo "✅ Dependencias sincronizadas y actualizadas."
}

run_lint_and_tests() {
    echo ""
    
    echo "🔎 Validando código (Flake8)..."
    # Ajustado para ignorar venv y la carpeta de datos musicales
    if uv run flake8 --exclude="venv,downloads,data,*.nosync,*.ipynb,azure-cli" . > /dev/null; then
        echo "✅ Flake8: 0 errores críticos."
    else
        echo "⚠️ Flake8 encontró advertencias de formato."
        # Como es pull, no bloqueamos la descarga por mala sintaxis
    fi

    echo ""
    echo "🧪 Ejecutando tests..."
    if [[ -d "tests" ]]; then
        if ! uv run pytest tests/ -v; then
            echo "❌ Cuidado: los tests locales fallaron tras la actualización."
        else
            echo "✅ Tests: todos pasaron."
        fi
    else
        echo "⏩ Carpeta 'tests/' no encontrada. Pruebas omitidas."
    fi
}

# ============================================================
# FLUJO PRINCIPAL
# ============================================================

main() {
    echo "♻️ Sincronizando entorno local con GitHub..."
    
    check_repository
    check_working_tree
    get_current_branch
    fetch_remote
    analyze_history

    case "$HISTORY_STATE" in
        SYNC) handle_sync ;;
        LOCAL_AHEAD) handle_local_ahead ;;
        REMOTE_AHEAD) handle_remote_ahead ;;
        DIVERGED) divergence_menu ;;
        *) error "Estado de historial desconocido." ;;
    esac

    # Sincronización del entorno UV posterior al movimiento de Git
    check_uv_environment
    install_dependencies
    run_lint_and_tests

    separator

    echo "🎉 Sincronización de entorno completada."
    echo "🌿 Rama: $CURRENT_BRANCH"
    echo "📌 Commit: $(git rev-parse --short HEAD)"
    echo "🐍 Python: $(uv run python --version)"
    echo ""
}

main "$@"