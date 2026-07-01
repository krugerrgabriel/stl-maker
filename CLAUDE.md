# Oficina 3D — geração de peças para impressão 3D

Projeto do Gabriel para transformar fotos + medidas em arquivos STL prontos para fatiar e imprimir.

## Fluxo de trabalho (obrigatório)

1. **Entender a peça**: fotos vêm coladas na conversa ou em `pecas/<nome>/ref/`. Medidas sempre em mm. Se faltar medida crítica (diâmetro de furo, distância entre furos, espessura do encaixe), perguntar ANTES de modelar.
2. **Criar a pasta** `pecas/<nome>/` (slug kebab-case) com o fonte da peça.
3. **Escolher a ferramenta**:
   - `.scad` (OpenSCAD) — peças prismáticas/simples: suportes, ganchos, espaçadores, caixas, adaptadores.
   - `.py` (build123d, venv `.venv`) — geometria complexa: filetes, chanfros, lofts, roscas, curvas, ou quando precisar exportar STEP.
4. **Gerar e VER**: `scripts/gerar.sh pecas/<nome>/<peca>.scad` (ou `.py`) → compila o STL, valida e gera 6 previews em `pecas/<nome>/previews/`. SEMPRE ler os PNGs (tool Read) e corrigir o modelo até a geometria estar certa. Iterar quantas vezes for preciso.
5. **Entregar**: caminho do STL + dimensões finais + folgas usadas + orientação de impressão sugerida + o que conferir antes de imprimir.

## Convenções de modelagem

- Unidade: **milímetros**. Sempre parametrizar (variáveis nomeadas no topo do arquivo).
- Scripts build123d recebem o caminho do STL de saída em `sys.argv[1]` e chamam `export_stl(peca, sys.argv[1])`.
- Em OpenSCAD, usar `$fn = 64` (ou mais) em cilindros/furos visíveis.
- Folgas para encaixe: **0.2 mm por lado** (justo) / **0.4 mm** (deslizante). Furo para parafuso: diâmetro nominal + 0.4 mm.
- Parede mínima: **1.2 mm**. Evitar balanços >45°; se inevitável, avisar que a peça precisa de suporte no slicer.
- Modelar com uma face plana apoiada em Z=0, já pensando na orientação de impressão.

## Ferramentas

- OpenSCAD: `openscad` no PATH ou `bin/openscad` (AppImage extraído pelo install.sh) — o `gerar.sh` resolve sozinho.
- Python: `.venv/bin/python` (build123d, trimesh, matplotlib).
- Validação: `scripts/validar_stl.py`. **Nunca entregar STL não-estanque.**
- Instalação/diagnóstico: `./install.sh` e `./install.sh --check`.

## Fora de escopo deste pipeline

Formas orgânicas a partir de foto (estatuetas, esculturas) não são CAD — indicar geradores foto→3D (Tripo, Meshy, Hunyuan3D) e, se o usuário trouxer o STL gerado, validar/reparar aqui com `validar_stl.py`.
