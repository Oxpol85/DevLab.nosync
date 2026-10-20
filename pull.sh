#!/bin/bash
set -e

# ============================================================
# CONFIGURACIÓN
# ============================================================
REMOTE="origin"

show_header() {
    echo -e "\n📥 Preparando para actualizar el entorno local...\n"
}

get_current_branch() {
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ -z "$CURRENT_BRANCH" ]]; then
        echo "❌ No se pudo determinar la rama actual."
        exit 1
    fi
    echo "🌐 Rama activa: $CURRENT_BRANCH"
}

fetch_and_pull() {
    echo "📶 Conectando con GitHub ($REMOTE)..."
    git fetch "$REMOTE" "$CURRENT_BRANCH" 2>/dev/null || true

    LOCAL_SHA=$(git rev-parse HEAD 2>/dev/null || echo "")
    REMOTE_SHA=$(git rev-parse "$REMOTE"/"$CURRENT_BRANCH" 2>/dev/null || echo "")

    if [[ -z "$REMOTE_SHA" ]]; then
        echo "⚠️  La rama $CURRENT_BRANCH no existe en el remoto todavía."
        echo "✅ Entorno listo."
        return 0
    fi

    if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
        echo "✅ Tu entorno local ya está 100% sincronizado con GitHub."
    else
        echo "⬇️ Descargando e integrando nuevos cambios..."
        # Usamos rebase para mantener el historial del entorno de estudio perfectamente lineal
        if git pull --rebase "$REMOTE" "$CURRENT_BRANCH"; then
            echo "✨ ¡Actualización exitosa!"
        else
            echo "❌ Hubo un conflicto al actualizar. El script se detendrá para que lo resuelvas manualmente."
            # Abortamos el rebase en caso de fallo para no dejar el repo atascado
            git rebase --abort 2>/dev/null || true
            exit 1
        fi
    fi
}

sync_environment() {
    if [[ -f "AssesRequirements.txt" ]] || [[ -f "requirements-dev.txt" ]]; then
        echo -e "\n📦 Verificando dependencias de UV..."
        if command -v uv &> /dev/null; then
            uv pip install -r AssesRequirements.txt -r requirements-dev.txt > /dev/null 2>&1 || true
            echo "✅ Dependencias de Python/herramientas sincronizadas."
        else
            echo "⚠️ 'uv' no encontrado, omitiendo actualización de dependencias."
        fi
    fi
}

main() {
    show_header
    get_current_branch
    fetch_and_pull
    sync_environment
    echo -e "\n🚀 Entorno listo para continuar simulaciones en Oracle SQL 26ai."
}

main "$@"
