#!/bin/bash
set -e

# ============================================================
# CONFIGURACIÓN
# ============================================================
REMOTE="origin"

# ============================================================
# FUNCIONES GENERALES Y GIT
# ============================================================
show_header() {
    echo -e "\n🚀 Preparando cambios para enviar al repositorio...\n"
}

get_current_branch() {
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ -z "$CURRENT_BRANCH" ]]; then
        echo "❌ No se pudo determinar la rama actual."
        exit 1
    fi
}

fetch_remote() {
    echo "📶 Actualizando información remota..."
    if ! git fetch "$REMOTE" "$CURRENT_BRANCH" 2>/dev/null; then
        echo "⚠️  No se pudo actualizar el remoto (quizás aún no exista la rama en origin)."
        REMOTE_BRANCH=""
    else
        REMOTE_BRANCH="$REMOTE/$CURRENT_BRANCH"
    fi
}

get_history_state() {
    if [[ -z "$REMOTE_BRANCH" ]]; then
        LOCAL_COMMITS=$(git rev-list --count HEAD)
        REMOTE_COMMITS=0
    else
        read -r LOCAL_COMMITS REMOTE_COMMITS <<< \
            "$(git rev-list --left-right --count HEAD..."$REMOTE_BRANCH")"
    fi
}

show_history_state() {
    echo -e "\n🔎 Estado del historial:"
    echo "Local:  $LOCAL_COMMITS commits"
    echo "Remote: $REMOTE_COMMITS commits\n"
}

# ============================================================
# RESOLUCIÓN DE DIVERGENCIA
# ============================================================
resolve_divergence() {
    echo -e "\n⚠️ HISTORIAL DIVERGENTE"
    echo -e "Local:  $LOCAL_COMMITS commits | Remote: $REMOTE_COMMITS commits\n"
    
    echo "1. 🚧 Rebase (Recomendado para mantener historial limpio)"
    echo "2. 🔀 Merge"
    echo "3. ♿️ Salir"
    read -r -p "Selecciona una opción: " res_option

    case "$res_option" in
        1)
            echo -e "\n🚧 Ejecutando Rebase..."
            if git rebase "$REMOTE_BRANCH"; then
                echo "✅ Rebase completado."
                return 0
            else
                echo -e "\n🚨 REBASE DETENIDO por conflictos. Resuélvelos manualmente y usa 'git rebase --continue'."
                exit 1
            fi
            ;;
        2)
            echo -e "\n🔀 Ejecutando Merge..."
            if git merge "$REMOTE_BRANCH"; then
                echo "✅ Merge completado."
                return 0
            else
                echo -e "\n🚨 MERGE DETENIDO por conflictos. Resuélvelos manualmente y haz commit."
                exit 1
            fi
            ;;
        *)
            echo "🛑 Operación cancelada."; exit 0 ;;
    esac
}

analyze_history() {
    fetch_remote
    get_history_state
    show_history_state

    if [[ "$LOCAL_COMMITS" -gt 0 && "$REMOTE_COMMITS" -gt 0 ]]; then
        resolve_divergence
        fetch_remote
        get_history_state
    elif [[ "$LOCAL_COMMITS" -eq 0 && "$REMOTE_COMMITS" -gt 0 ]]; then
        echo "⬇️ El remoto contiene commits nuevos. Ejecuta ./pull.sh primero."
        exit 1
    fi
}

show_working_tree() {
    echo -e "\n📋 Estado del working tree:"
    if [[ -z "$(git status --porcelain)" ]]; then
        echo "   limpio."
        return 1
    fi
    git status --short
    return 0
}

# ============================================================
# ENTORNO DE ESTUDIO Y UV (PYTHON)
# ============================================================
verify_uv() {
    if ! command -v uv &> /dev/null; then
        echo "❌ 'uv' no está instalado. Instálalo con: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
}

verify_virtual_environment() {
    echo -e "\n🐍 Verificando entorno virtual con UV..."
    if [[ ! -d "venv" ]]; then
        echo "📦 Creando venv hiper-rápido con uv..."
        uv venv venv > /dev/null
        echo "✅ venv creado."
    fi
    PYTHON_VERSION=$(uv run python --version)
    echo "✅ Runtime: $PYTHON_VERSION"
}

verify_requirements() {
    echo -e "\n📦 Verificando dependencias para estudio..."
    if [[ ! -f "requirements.txt" ]]; then
        echo "⚠️ No existe requirements.txt. Creando uno vacío..."
        touch requirements.txt
    fi
    if [[ ! -f "requirements-dev.txt" ]]; then
        echo "⚠️ No existe requirements-dev.txt. Añadiendo flake8 y pytest..."
        echo -e "flake8\npytest" > requirements-dev.txt
    fi
}

install_dependencies() {
    echo "📦 Sincronizando dependencias..."
    uv pip install -r requirements.txt -r requirements-dev.txt > /dev/null
    echo "✅ Dependencias listas."
}

run_lint_and_tests() {
    echo -e "\n🔎 Validando código (Flake8)..."
    if uv run flake8 --exclude="venv,downloads,data,*.nosync" . > /dev/null; then
            echo "✅ Flake8: 0 errores críticos."
    else
             echo "⚠️ Flake8 encontró advertencias de formato, pero el push continuará."
    fi

    echo -e "\n🧪 Ejecutando tests (Pytest)..."
    if [[ -d "tests" ]]; then
        if ! uv run pytest tests/ -v; then
            echo "❌ Los tests fallaron. Push bloqueado."
            exit 1
        fi
        echo "✅ Tests pasaron correctamente."
    else
        echo "⏩ Carpeta 'tests/' no encontrada. Saltando pruebas."
    fi
}

# ============================================================
# COMMIT Y PUSH
# ============================================================
create_commit() {
    echo -e "\n🟢 Preparando commit..."
    echo "1) feat (✨ Nueva característica) | 2) fix (🐛 Bugfix) | 3) chore (⚙️ Config) | 4) refactor (♻️) | 5) docs (📚) | 6) study (🎓 Laboratorio/Apuntes)"
    read -r -p "Elige una opción (1-6): " option

    case "$option" in
        1) type="feat" ;; 2) type="fix" ;; 3) type="chore" ;;
        4) type="refactor" ;; 5) type="docs" ;; 6) type="study" ;;
        *) type="chore" ;;
    esac

    read -r -p "✍️ Mensaje del commit: " commit_msg
    if [[ -z "$commit_msg" ]]; then
        echo "❌ El mensaje no puede estar vacío."; exit 1
    fi

    git add .
    git commit -m "$type: $commit_msg"
}

push_changes() {
    echo -e "\n🌐 Subiendo a GitHub ($CURRENT_BRANCH)..."
    if git push "$REMOTE" "$CURRENT_BRANCH"; then
        echo "✨ ¡Push exitoso!"
    else
        echo "❌ Error en el push. Verifica tu conexión o permisos."
        exit 1
    fi
}

# ============================================================
# MAIN
# ============================================================
main() {
    show_header
    verify_uv
    get_current_branch
    analyze_history

    if ! show_working_tree; then
        if [[ "$LOCAL_COMMITS" -gt 0 ]]; then
            push_changes
        else
            echo "✅ Nada que enviar."
        fi
        exit 0
    fi

    verify_virtual_environment
    verify_requirements
    install_dependencies
    run_lint_and_tests
    create_commit
    
    fetch_remote
    get_history_state
    if [[ "$REMOTE_COMMITS" -gt 0 ]]; then
        echo "⛔ El remoto cambió mientras validabas. Resolviendo..."
        resolve_divergence
    fi

    push_changes
}

main "$@"