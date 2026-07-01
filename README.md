# Oficina 3D

Transforme **fotos + medidas** em arquivos **.stl** prontos para imprimir, usando o Claude Code.

## Instalação (Ubuntu)

```
./install.sh
```

O instalador é idempotente (pode rodar de novo à vontade) e tem dois caminhos:

- **Com sudo** — instala o OpenSCAD via apt.
- **Sem sudo** — baixa o AppImage do OpenSCAD para dentro do projeto (`bin/`).

Nos dois casos ele cria o venv Python (`.venv`) com build123d + trimesh e roda um teste
de geração de STL no final. Para só conferir: `./install.sh --check`

## Como usar

1. Abra o Claude Code nesta pasta: `cd ~/impressao-3d && claude`
2. Descreva a peça (ou use `/peca-3d`), cole as fotos na conversa e passe as medidas em mm.
3. O Claude modela, olha os previews, itera e entrega `pecas/<nome>/<nome>.stl` — é só abrir no slicer.

## As duas opções de modelagem (ambas grátis)

| Opção | Ferramenta | Quando usar |
|---|---|---|
| Simples | OpenSCAD (`.scad`) | Suportes, ganchos, espaçadores, caixas, adaptadores |
| Complexa | build123d (`.py`) | Filetes, chanfros, curvas, roscas, exportar STEP |

## Levar para outro Ubuntu

Copie a pasta (pode excluir `.venv/` e `bin/`, que são recriados) e rode `./install.sh` lá.

## Formas orgânicas (estatuetas, bonecos, esculturas)

Isso não é CAD — use um gerador de foto→3D: [Tripo](https://www.tripo3d.ai) ou
[Meshy](https://www.meshy.ai) (têm plano grátis), ou [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2)
(open source, roda local mas precisa de GPU). O STL gerado pode ser validado/reparado
aqui com `scripts/validar_stl.py`.
