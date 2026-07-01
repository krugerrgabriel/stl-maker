<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong>Sua oficina de peças 3D dentro do <a href="https://claude.com/claude-code">Claude Code</a>.</strong><br>
  Fotos + medidas viram <code>.stl</code> validado, pronto para fatiar e imprimir.
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <strong>🇧🇷 Português</strong> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
  <a href="README.ja.md">🇯🇵 日本語</a> ·
  <a href="README.zh-CN.md">🇨🇳 简体中文</a> ·
  <a href="README.ko.md">🇰🇷 한국어</a> ·
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="OpenSCAD" src="https://img.shields.io/badge/OpenSCAD-2021.01-F9D72C?logo=openscad&logoColor=black">
  <img alt="build123d" src="https://img.shields.io/badge/build123d-CAD%20em%20Python-0066cc">
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-apt%20%2B%20sudo-E95420?logo=ubuntu&logoColor=white">
  <img alt="STL estanque" src="https://img.shields.io/badge/STL-sempre%20estanque-success">
</p>

---

## 💡 Por que usar

Precisou de um suporte, gancho, adaptador ou peça de reposição? O caminho tradicional é abrir um CAD, aprender a ferramenta, modelar, exportar, descobrir que a malha está furada… 😩

Aqui o fluxo é conversa:

1. 📸 Tire fotos da peça (ou do lugar onde ela encaixa)
2. 📏 Meça com o paquímetro e mande tudo em milímetros
3. 💬 Descreva o que precisa no Claude Code
4. 🎉 Receba o `.stl` validado, com dimensões conferidas e orientação de impressão sugerida

O Claude modela, **olha os previews renderizados**, corrige a geometria sozinho e só entrega STL que passou na validação de estanqueidade.

> **Descrever custa minutos. Aprender CAD custa semanas.**

---

## ✨ O que tem dentro

| | |
|---|---|
| 🗣️ **Skill `/peca-3d`** | Roteiro guiado: requisitos → modelagem → iteração visual → entrega |
| ⚙️ **Duas engines de CAD** | OpenSCAD para peças prismáticas, build123d para curvas, filetes e roscas |
| 🔬 **Validação automática** | Toda peça passa por checagem de estanqueidade — malha furada não chega no slicer |
| 🖼️ **Previews em 6 vistas** | Renderizador ortográfico próprio (topo, frente, trás, laterais e iso) para o Claude conferir a geometria |
| 📐 **Convenções de oficina** | Folgas de encaixe (0.2/0.4 mm), parede mínima 1.2 mm, furos com folga de parafuso — já embutidas |
| 📦 **Instalador portátil** | Um `install.sh` idempotente |
| 🧾 **Tudo paramétrico** | Cada peça é código com medidas nomeadas — ajustar 2 mm é editar uma variável |

---

## 📦 Instalação

### 1️⃣ Clone o repositório

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ Rode o instalador

```bash
sudo ./install.sh
```

O instalador cuida de tudo — instala o OpenSCAD via `apt`, cria o venv Python (`.venv`) com build123d + trimesh **pertencendo ao seu usuário** (não ao root) e termina rodando um teste real de geração de STL. Idempotente: pode rodar de novo à vontade.

### 3️⃣ Confira a instalação

```bash
./install.sh --check
```

Pronto. 🎉

> 💡 **Pré-requisito único:** um Linux com `apt` (Ubuntu, Debian, Mint, Pop!_OS…), `sudo` e Python 3.10+.

---

## 🚀 Como usar

```bash
cd stl-maker && claude
```

Aí é só conversar — ou chamar a skill direto:

```
/peca-3d suporte de parede para o roteador, 3 furos de 4 mm, vão de 120 mm entre os parafusos
```

Cole as fotos na conversa, passe as medidas em mm e o Claude cuida do resto. A peça sai em `pecas/<nome>/`:

```
pecas/suporte-roteador/
├── suporte-roteador.scad   # o fonte paramétrico
├── suporte-roteador.stl    # pronto para o slicer
└── previews/               # 6 vistas renderizadas
```

---

## 🧰 As duas engines (ambas grátis)

| Opção | Ferramenta | Quando usar |
|---|---|---|
| 🟨 Simples | OpenSCAD (`.scad`) | Suportes, ganchos, espaçadores, caixas, adaptadores |
| 🐍 Complexa | build123d (`.py`) | Filetes, chanfros, curvas, roscas, exportar STEP |

O `scripts/gerar.sh` aceita os dois e resolve sozinho qual compilador chamar.

---

## 🏗️ Como funciona por baixo

```
descrição + fotos + medidas
        │
        ▼
 .scad ou .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   (estanqueidade + dimensões)
                         └── preview_stl.py   (6 vistas PNG que o Claude lê)
```

### Layout do repositório

```
├── CLAUDE.md               # regras e convenções que o Claude segue
├── install.sh              # instalador idempotente (requer sudo)
├── scripts/
│   ├── gerar.sh            # compila, valida e gera previews
│   ├── validar_stl.py      # nunca entrega STL não-estanque
│   └── preview_stl.py      # renderizador ortográfico headless
├── .claude/skills/peca-3d/ # a skill que guia a criação de peças
└── pecas/                  # suas peças (criadas localmente, fora do git)
```

---

## 🐛 Solução de problemas

<details>
<summary><strong>"Reparo automático falhou" na validação</strong></summary>

A malha saiu não-estanque e o reparo do trimesh não deu conta. Não imprima esse STL — peça para o Claude revisar o modelo (geralmente é booleano com faces coincidentes; estender o cortador ~1 mm além da superfície resolve).

</details>

<details>
<summary><strong>"A instalação requer sudo"</strong></summary>

Por decisão de projeto, o instalador só roda com sudo: `sudo ./install.sh`. Apenas o `./install.sh --check` funciona sem.

</details>

<details>
<summary><strong>Levar para outro Ubuntu</strong></summary>

Clone o repositório (ou copie a pasta sem `.venv/` e `bin/`, que são recriados) e rode `sudo ./install.sh` na máquina nova.

</details>

---

## 🗿 Formas orgânicas (estatuetas, bonecos, esculturas)

Isso não é CAD — use um gerador de foto→3D:

- [Tripo](https://www.tripo3d.ai) ou [Meshy](https://www.meshy.ai) — têm plano grátis
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — open source, roda local (precisa de GPU)

O STL gerado pode ser validado e reparado aqui com `scripts/validar_stl.py`. 😉

---

<p align="center">
  Feito com 🧡 e <a href="https://claude.com/claude-code">Claude Code</a> — descreva a peça, imprima a solução.
</p>
