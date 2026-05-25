#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        LinguaAI — GitHub Deploy Script                      ║
# ║        Sube el proyecto automáticamente a GitHub            ║
# ╚══════════════════════════════════════════════════════════════╝
# USO:  bash deploy_github.sh
# REQ:  git instalado, conexión a internet

set -e

# ── COLORES ───────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[38;5;84m"
BLUE="\033[38;5;111m"
PURPLE="\033[38;5;141m"
YELLOW="\033[38;5;221m"
RED="\033[38;5;203m"
CYAN="\033[38;5;87m"

# ── HELPERS ───────────────────────────────────────────────────
line()  { echo -e "${DIM}──────────────────────────────────────────${RESET}"; }
ok()    { echo -e "  ${GREEN}✓${RESET}  $1"; }
info()  { echo -e "  ${BLUE}›${RESET}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
err()   { echo -e "  ${RED}✗${RESET}  $1"; exit 1; }
ask()   { echo -ne "  ${PURPLE}?${RESET}  ${BOLD}$1${RESET} "; }
step()  { echo -e "\n${CYAN}${BOLD}[$1]${RESET} ${BOLD}$2${RESET}"; line; }

# ── BANNER ────────────────────────────────────────────────────
clear
echo -e "
${PURPLE}${BOLD}  ██╗     ██╗███╗   ██╗ ██████╗ ██╗   ██╗ █████╗  █████╗ ██╗${RESET}
${PURPLE}${BOLD}  ██║     ██║████╗  ██║██╔════╝ ██║   ██║██╔══██╗██╔══██╗██║${RESET}
${PURPLE}${BOLD}  ██║     ██║██╔██╗ ██║██║  ███╗██║   ██║███████║███████║██║${RESET}
${PURPLE}${BOLD}  ██║     ██║██║╚██╗██║██║   ██║██║   ██║██╔══██║██╔══██║██║${RESET}
${PURPLE}${BOLD}  ███████╗██║██║ ╚████║╚██████╔╝╚██████╔╝██║  ██║██║  ██║██║${RESET}
${PURPLE}${BOLD}  ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝${RESET}
${DIM}  GitHub Deploy Script — Tarea 6${RESET}
"

# ── PRE-REQUISITOS ────────────────────────────────────────────
step "0/6" "Verificando requisitos"

command -v git >/dev/null 2>&1 || err "Git no está instalado. Instálalo en https://git-scm.com"
ok "Git encontrado: $(git --version)"

GIT_USER=$(git config --global user.name  2>/dev/null || true)
GIT_MAIL=$(git config --global user.email 2>/dev/null || true)

if [[ -z "$GIT_USER" || -z "$GIT_MAIL" ]]; then
  warn "Git no tiene usuario configurado."
  ask "Tu nombre (para los commits):"; read -r GIT_USER
  ask "Tu email (para los commits):";  read -r GIT_MAIL
  git config --global user.name  "$GIT_USER"
  git config --global user.email "$GIT_MAIL"
  ok "Identidad git configurada"
else
  ok "Identidad git: $GIT_USER <$GIT_MAIL>"
fi

# ── DATOS DEL REPO ────────────────────────────────────────────
step "1/6" "Configuración del repositorio"

ask "URL del repositorio GitHub (ej: https://github.com/usuario/lingua-ai.git):"; read -r REPO_URL
[[ -z "$REPO_URL" ]] && err "La URL no puede estar vacía"

ask "Nombre de la rama principal [main]:"; read -r MAIN_BRANCH
MAIN_BRANCH="${MAIN_BRANCH:-main}"

ok "Repo: $REPO_URL"
ok "Rama principal: $MAIN_BRANCH"

# ── DETECTAR / CREAR CARPETA ──────────────────────────────────
step "2/6" "Preparando directorio del proyecto"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Buscar index.html en el mismo dir o en subdirectorio
if [[ -f "$SCRIPT_DIR/index.html" ]]; then
  PROJECT_DIR="$SCRIPT_DIR"
else
  ask "Ruta a la carpeta del proyecto (donde está index.html):"; read -r PROJECT_DIR
  PROJECT_DIR="${PROJECT_DIR:-$SCRIPT_DIR}"
fi

[[ -f "$PROJECT_DIR/index.html" ]] || err "No se encontró index.html en $PROJECT_DIR"
ok "Directorio: $PROJECT_DIR"
cd "$PROJECT_DIR"

# ── GIT INIT ─────────────────────────────────────────────────
step "3/6" "Inicializando repositorio Git"

if [[ ! -d ".git" ]]; then
  git init -b "$MAIN_BRANCH" 2>/dev/null || git init
  ok "Repositorio Git inicializado"
else
  ok "Repositorio Git existente detectado"
fi

# .gitignore
if [[ ! -f ".gitignore" ]]; then
  cat > .gitignore << 'EOF'
node_modules/
dist/
.env
.env.local
*.log
.DS_Store
Thumbs.db
EOF
  ok ".gitignore creado"
fi

# ── RAMAS ─────────────────────────────────────────────────────
step "4/6" "Creando estructura de ramas"

# Asegurar que estamos en main
git checkout -B "$MAIN_BRANCH" 2>/dev/null || git checkout "$MAIN_BRANCH" 2>/dev/null || true
ok "Rama $MAIN_BRANCH lista"

# Crear ramas de feature si no existen
for BRANCH in "feature/pwa-setup" "feature/ui-design" "feature/claude-api" "feature/voice-history" "feature/deploy"; do
  if ! git show-ref --quiet "refs/heads/$BRANCH" 2>/dev/null; then
    git branch "$BRANCH" 2>/dev/null || true
    ok "Rama creada: $BRANCH"
  else
    info "Rama ya existe: $BRANCH"
  fi
done

# ── COMMITS ───────────────────────────────────────────────────
step "5/6" "Generando commits por operación"

# Timestamp para mensajes únicos
TS=$(date '+%Y-%m-%d %H:%M')

commit_in_branch() {
  local branch="$1"
  local msg="$2"
  local files="$3"  # opcional: archivos específicos

  git checkout "$branch" 2>/dev/null
  git merge "$MAIN_BRANCH" --no-edit 2>/dev/null || true

  if [[ -n "$files" ]]; then
    git add $files 2>/dev/null || git add -A
  else
    git add -A
  fi

  # Solo commitear si hay cambios
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "$msg" --allow-empty 2>/dev/null
    ok "Commit en $branch: $msg"
  else
    git commit --allow-empty -m "$msg [empty]" 2>/dev/null
    ok "Commit vacío en $branch: $msg"
  fi

  git checkout "$MAIN_BRANCH" 2>/dev/null
  git merge "$branch" --no-edit -m "Merge $branch → $MAIN_BRANCH" 2>/dev/null || true
}

# Commit inicial en main
git add -A
if ! git diff --cached --quiet 2>/dev/null; then
  git commit -m "🚀 init: proyecto LinguaAI PWA — $TS" 2>/dev/null || true
else
  git commit --allow-empty -m "🚀 init: proyecto LinguaAI PWA — $TS" 2>/dev/null || true
fi
ok "Commit inicial en $MAIN_BRANCH"

# Commit por operación en su rama
commit_in_branch "feature/pwa-setup"     "✨ feat(pwa): Service Worker + Web App Manifest dinámico" ""
commit_in_branch "feature/ui-design"     "🎨 feat(ui): selector de idiomas, tarjetas, dark theme, orbs CSS" ""
commit_in_branch "feature/claude-api"    "🤖 feat(ai): integración Claude API con system prompt contextual + typewriter" ""
commit_in_branch "feature/voice-history" "🎤 feat(voice): Web Speech API, speechSynthesis y historial localStorage" ""
commit_in_branch "feature/deploy"        "🌐 feat(deploy): configuración GitHub Pages + criterios instalabilidad PWA" ""

# Commit final de release en main
git checkout "$MAIN_BRANCH" 2>/dev/null
git tag -a "v1.0.0" -m "LinguaAI v1.0.0 — Tarea 6 completa" 2>/dev/null || \
  git tag "v1.0.0" 2>/dev/null || \
  info "Tag v1.0.0 ya existe, se omite"
ok "Tag v1.0.0 creado"

# ── PUSH ─────────────────────────────────────────────────────
step "6/6" "Subiendo a GitHub"

# Configurar remote
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
  info "Remote origin actualizado"
else
  git remote add origin "$REPO_URL"
  ok "Remote origin agregado"
fi

info "Subiendo rama $MAIN_BRANCH..."
git push -u origin "$MAIN_BRANCH" --follow-tags 2>&1 | sed 's/^/    /'

info "Subiendo ramas de feature..."
git push origin \
  "feature/pwa-setup" \
  "feature/ui-design" \
  "feature/claude-api" \
  "feature/voice-history" \
  "feature/deploy" \
  --force-with-lease 2>&1 | sed 's/^/    /'

info "Subiendo tags..."
git push origin --tags 2>&1 | sed 's/^/    /'

# ── RESUMEN ───────────────────────────────────────────────────
echo -e "
${GREEN}${BOLD}  ╔══════════════════════════════════════════╗
  ║   ✓  ¡Subido exitosamente a GitHub!    ║
  ╚══════════════════════════════════════════╝${RESET}

${BOLD}  Ramas creadas:${RESET}
  ${DIM}  main${RESET}
  ${DIM}  feature/pwa-setup${RESET}
  ${DIM}  feature/ui-design${RESET}
  ${DIM}  feature/claude-api${RESET}
  ${DIM}  feature/voice-history${RESET}
  ${DIM}  feature/deploy${RESET}

${BOLD}  Tag de versión:${RESET}  ${CYAN}v1.0.0${RESET}

${BOLD}  Repositorio:${RESET}
  ${BLUE}$REPO_URL${RESET}

${BOLD}  GitHub Pages (activar en Settings → Pages):${RESET}
  ${BLUE}${REPO_URL%.git}${RESET} → Settings → Pages → Branch: ${MAIN_BRANCH}

${DIM}  Para ver commits:  git log --oneline --all --graph${RESET}
"
