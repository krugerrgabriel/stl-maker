#!/usr/bin/env bash
# bambu.sh — gera os arquivos Bambu a partir de um STL validado:
#   <peca>.3mf        projeto com configurações embutidas (abre pronto no Bambu Studio)
#   <peca>.gcode.3mf  fatiado, pronto para mandar para a impressora
# Perfis (impressora/processo/filamento) vêm de config/bambu.json.
# Uso: scripts/bambu.sh pecas/minha-peca/peca.stl
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="$DIR/.venv/bin/python"
STL="${1:?uso: bambu.sh <peca.stl>}"
STL="$(realpath "$STL")"
PASTA="$(dirname "$STL")"
NOME="$(basename "${STL%.stl}")"
CONFIG="$DIR/config/bambu.json"

BAMBU="$DIR/bin/bambu-studio"
RES="$DIR/bin/bambustudio-appimage"
[ -x "$BAMBU" ] || { echo "Bambu Studio não instalado — rode ./install.sh" >&2; exit 3; }
[ -f "$CONFIG" ] || { echo "config/bambu.json não encontrado" >&2; exit 3; }

leconf() { "$PY" -c "import json;print(json.load(open('$CONFIG'))['$1'])"; }

acha_perfil() { # acha_perfil <subpasta> <nome do perfil>
  local f
  f="$(find "$RES" -path "*/profiles/BBL/$1/$2.json" 2>/dev/null | head -1)"
  [ -n "$f" ] || { echo "perfil não encontrado: BBL/$1/$2.json (confira config/bambu.json)" >&2; exit 4; }
  echo "$f"
}

MAQUINA="$(acha_perfil machine "$(leconf machine)")"
PROCESSO="$(acha_perfil process "$(leconf process)")"
FILAMENTO="$(acha_perfil filament "$(leconf filament)")"

# o CLI espalha centenas de MB de temporários no diretório corrente:
# roda isolado e limpa no fim
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

echo "» Gerando 3MF de projeto (configurações embutidas)..."
"$BAMBU" --load-settings "$MAQUINA;$PROCESSO" --load-filaments "$FILAMENTO" \
  --arrange 1 --export-3mf "$PASTA/$NOME.3mf" "$STL" >log_projeto.txt 2>&1 \
  || { echo "falha no 3MF de projeto:"; tail -5 log_projeto.txt; exit 5; }

echo "» Fatiando (.gcode.3mf, pronto para a impressora)..."
"$BAMBU" --load-settings "$MAQUINA;$PROCESSO" --load-filaments "$FILAMENTO" \
  --arrange 1 --slice 0 --export-3mf "$PASTA/$NOME.gcode.3mf" "$STL" >log_fatiar.txt 2>&1 \
  || { echo "falha ao fatiar:"; tail -5 log_fatiar.txt; exit 5; }

# resumo do fatiamento (tempo estimado e filamento) direto do slice_info
"$PY" - "$PASTA/$NOME.gcode.3mf" <<'EOF' || true
import re, sys, zipfile
try:
    info = zipfile.ZipFile(sys.argv[1]).read("Metadata/slice_info.config").decode()
    tempo = re.search(r'key="prediction" value="(\d+)"', info)
    gramas = [float(g) for g in re.findall(r'used_g="([\d.]+)"', info)]
    metros = [float(m) for m in re.findall(r'used_m="([\d.]+)"', info)]
    if tempo:
        s = int(tempo.group(1))
        print(f"Tempo estimado.: {s//3600}h{(s%3600)//60:02d}min")
    if sum(gramas) > 0:
        print(f"Filamento......: {sum(gramas):.1f} g")
    elif metros:
        # o CLI zera used_g; estima por used_m (PLA 1.75 mm ≈ 2.98 g/m)
        print(f"Filamento......: {sum(metros):.1f} m (~{sum(metros) * 2.98:.0f} g de PLA)")
except Exception:
    pass
EOF

echo
echo "Projeto 3MF..: $PASTA/$NOME.3mf"
echo "Fatiado......: $PASTA/$NOME.gcode.3mf (cartão SD, Bambu Handy ou LAN)"
