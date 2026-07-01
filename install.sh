#!/usr/bin/env bash
# install.sh — Oficina 3D: instala tudo que o Claude Code precisa para gerar STLs.
#
# Uso:
#   ./install.sh           instala (usa sudo/apt se possível; senão instala sem sudo)
#   ./install.sh --check   apenas verifica a instalação
#
# Testado em Ubuntu 24.04. Idempotente: pode rodar quantas vezes quiser.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$DIR/.venv"
BIN="$DIR/bin"
APPIMAGE_URL="https://files.openscad.org/OpenSCAD-2021.01-x86_64.AppImage"
PACOTES_PY=(build123d trimesh numpy matplotlib manifold3d fast-simplification shapely networkx)

verde()    { printf '\033[32m✔ %s\033[0m\n' "$*"; }
vermelho() { printf '\033[31m✘ %s\033[0m\n' "$*"; }
info()     { printf '\033[36m» %s\033[0m\n' "$*"; }

acha_openscad() {
  if command -v openscad >/dev/null 2>&1; then command -v openscad; return 0; fi
  # o binário local só conta se realmente executar (autocorrige instalação quebrada)
  if [ -x "$BIN/openscad" ] && "$BIN/openscad" --version 2>&1 | grep -q "OpenSCAD version"; then
    echo "$BIN/openscad"; return 0
  fi
  return 1
}

instala_openscad() {
  if OS="$(acha_openscad)"; then verde "OpenSCAD já instalado: $OS"; return 0; fi

  # 1) caminho preferido: apt (precisa de sudo)
  if command -v apt-get >/dev/null 2>&1; then
    if [ "$(id -u)" = 0 ]; then
      apt-get update -qq && apt-get install -y openscad && return 0
    elif sudo -n true 2>/dev/null; then
      info "Instalando OpenSCAD via apt..."
      sudo apt-get update -qq && sudo apt-get install -y openscad && return 0
    elif [ -t 0 ]; then
      info "Instalando OpenSCAD via apt (vai pedir sua senha do sudo; Ctrl+C para usar o modo sem sudo)..."
      if sudo apt-get update -qq && sudo apt-get install -y openscad; then return 0; fi
    fi
  fi

  # 2) fallback sem sudo: AppImage extraído dentro do projeto
  info "Instalando OpenSCAD sem sudo (AppImage) em $BIN ..."
  mkdir -p "$BIN"
  if [ ! -f "$BIN/openscad.AppImage" ]; then
    curl -fL --progress-bar -o "$BIN/openscad.AppImage.part" "$APPIMAGE_URL" \
      && mv "$BIN/openscad.AppImage.part" "$BIN/openscad.AppImage" \
      || { vermelho "Falha ao baixar o AppImage do OpenSCAD"; return 1; }
  fi
  chmod +x "$BIN/openscad.AppImage"
  if [ ! -x "$BIN/openscad-appimage/AppRun" ]; then
    (cd "$BIN" && rm -rf squashfs-root openscad-appimage \
      && ./openscad.AppImage --appimage-extract >/dev/null \
      && mv squashfs-root openscad-appimage) \
      || { vermelho "Falha ao extrair o AppImage"; return 1; }
  fi
  # wrapper em vez de symlink: o AppRun resolve caminhos internos a partir de $0,
  # então precisa ser invocado pelo caminho real dentro de openscad-appimage/
  printf '#!/usr/bin/env bash\nexec "%s/openscad-appimage/AppRun" "$@"\n' "$BIN" > "$BIN/openscad"
  chmod +x "$BIN/openscad"
  "$BIN/openscad" --version 2>&1 | grep -q "OpenSCAD version" \
    || { vermelho "OpenSCAD extraído mas não executa"; return 1; }
  verde "OpenSCAD instalado em $BIN/openscad"
}

instala_python() {
  local PYMINOR
  PYMINOR="$(python3 -c 'import sys; print(sys.version_info.minor)')" || { vermelho "python3 não encontrado"; return 1; }
  if [ "$PYMINOR" -lt 10 ]; then vermelho "Python 3.10+ é necessário (encontrado 3.$PYMINOR)"; return 1; fi

  if [ ! -x "$VENV/bin/python" ]; then
    info "Criando venv em $VENV ..."
    python3 -m venv "$VENV" || {
      vermelho "Falha ao criar venv. Em Ubuntu: sudo apt install python3-venv e rode de novo."
      return 1
    }
  fi
  info "Instalando pacotes Python (build123d é grande, pode demorar alguns minutos)..."
  "$VENV/bin/pip" install --quiet --upgrade pip \
    && "$VENV/bin/pip" install --quiet "${PACOTES_PY[@]}" \
    || { vermelho "Falha no pip install"; return 1; }
  verde "Venv Python pronto: $VENV"
}

verifica() {
  local FALHAS=0

  local VERSAO
  if OS="$(acha_openscad)" && VERSAO="$("$OS" --version 2>&1 | grep -o 'OpenSCAD version.*' | head -1)" && [ -n "$VERSAO" ]; then
    verde "OpenSCAD: $VERSAO ($OS)"
  else
    vermelho "OpenSCAD não encontrado ou não executa (opção 'simples' indisponível)"; FALHAS=$((FALHAS+1))
  fi

  if [ -x "$VENV/bin/python" ]; then
    if "$VENV/bin/python" - <<'EOF'
import os, tempfile
from build123d import Box, export_stl
import trimesh
p = os.path.join(tempfile.gettempdir(), "oficina3d_smoke.stl")
export_stl(Box(10, 10, 10), p)
m = trimesh.load(p, force="mesh")
assert m.is_watertight, "cubo de teste não ficou estanque"
os.remove(p)
import build123d
print(f"build123d {build123d.__version__} + trimesh {trimesh.__version__}: cubo de teste gerado e validado")
EOF
    then verde "Python/build123d: teste de geração de STL passou"
    else vermelho "Venv existe mas o teste de geração falhou"; FALHAS=$((FALHAS+1)); fi
  else
    vermelho "Venv Python não encontrado (opção 'complexa' indisponível)"; FALHAS=$((FALHAS+1))
  fi

  echo
  if [ "$FALHAS" -eq 0 ]; then
    verde "Tudo pronto. Abra o Claude Code nesta pasta e peça uma peça (/peca-3d)."
  else
    vermelho "$FALHAS componente(s) com problema — rode ./install.sh para instalar."
  fi
  return "$FALHAS"
}

if [ "${1:-}" = "--check" ]; then
  verifica; exit $?
fi

info "Oficina 3D — instalação em $DIR"
instala_openscad || vermelho "OpenSCAD não pôde ser instalado (a opção build123d segue funcionando)"
instala_python
echo
verifica
