---
name: peca-3d
description: Cria uma peça 3D imprimível (.stl) a partir de descrição, fotos e medidas. Use quando o usuário pedir uma peça, suporte, gancho, adaptador, caixa, encaixe, peça de reposição ou qualquer objeto para imprimir na impressora 3D.
---

# Gerar peça 3D imprimível

Siga as convenções do CLAUDE.md do projeto. Roteiro:

1. **Requisitos** — Liste o que entendeu: função da peça, medidas em mm, onde ela encaixa/apoia. Leia as fotos da conversa (ou de `pecas/<nome>/ref/`). Se faltar medida crítica, pergunte antes de modelar; não invente dimensão de encaixe.
2. **Pasta** — Crie `pecas/<slug>/` (kebab-case).
3. **Modele** — `.scad` (OpenSCAD) para peças simples e prismáticas; `.py` (build123d) para filetes, curvas, roscas ou quando pedirem STEP. Parametrize tudo com variáveis nomeadas no topo.
4. **Itere** — Rode `scripts/gerar.sh pecas/<slug>/<arquivo>` e LEIA os 6 previews PNG gerados. Compare com as fotos de referência e as medidas. Corrija e regenere até a geometria estar correta — no mínimo uma rodada de correção após o primeiro render.
5. **Valide** — O `gerar.sh` já valida estanqueidade e dimensões; só entregue STL estanque.
6. **Arquivos Bambu** — Quando a geometria estiver aprovada, rode UMA vez `scripts/gerar.sh --bambu pecas/<slug>/<arquivo>` para gerar `<peca>.3mf` (projeto) e `<peca>.gcode.3mf` (fatiado). Não fatie a cada iteração — só na final.
7. **Entregue** — Informe: caminhos do `.stl`, do `.3mf` e do `.gcode.3mf`, dimensões finais, folgas aplicadas, orientação de impressão, tempo/filamento estimados e se precisa de suporte no slicer.
