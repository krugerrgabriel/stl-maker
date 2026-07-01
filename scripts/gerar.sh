#!/usr/bin/env bash
# gerar.sh — compila uma peça (.scad ou .py) para STL, valida e gera previews.
# Uso: scripts/gerar.sh pecas/minha-peca/peca.scad
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="$DIR/.venv/bin/python"
FONTE="${1:?uso: gerar.sh <peca.scad|peca.py>}"
FONTE="$(realpath "$FONTE")"
PASTA="$(dirname "$FONTE")"
NOME="$(basename "${FONTE%.*}")"
STL="$PASTA/$NOME.stl"

if command -v openscad >/dev/null 2>&1; then
  OPENSCAD="$(command -v openscad)"
else
  OPENSCAD="$DIR/bin/openscad"
fi

case "$FONTE" in
  *.scad) "$OPENSCAD" -o "$STL" "$FONTE" ;;
  *.py)   "$PY" "$FONTE" "$STL" ;;
  *) echo "formato não suportado: $FONTE (use .scad ou .py)" >&2; exit 2 ;;
esac

"$PY" "$DIR/scripts/validar_stl.py" "$STL"
mkdir -p "$PASTA/previews"
"$PY" "$DIR/scripts/preview_stl.py" "$STL" "$PASTA/previews"

echo
echo "STL......: $STL"
echo "Previews.: $PASTA/previews/"
