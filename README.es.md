<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong>Tu taller de piezas 3D dentro de <a href="https://claude.com/claude-code">Claude Code</a>.</strong><br>
  Fotos + medidas se convierten en <code>.stl</code> validado, listo para laminar e imprimir.
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <strong>🇪🇸 Español</strong> ·
  <a href="README.ja.md">🇯🇵 日本語</a> ·
  <a href="README.zh-CN.md">🇨🇳 简体中文</a> ·
  <a href="README.ko.md">🇰🇷 한국어</a> ·
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="OpenSCAD" src="https://img.shields.io/badge/OpenSCAD-2021.01-F9D72C?logo=openscad&logoColor=black">
  <img alt="build123d" src="https://img.shields.io/badge/build123d-CAD%20in%20Python-0066cc">
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-apt%20%2B%20sudo-E95420?logo=ubuntu&logoColor=white">
  <img alt="Watertight STL" src="https://img.shields.io/badge/STL-always%20watertight-success">
</p>

---

## 💡 Por qué usarlo

¿Necesitas un soporte, gancho, adaptador o pieza de repuesto? El camino tradicional es abrir un CAD, aprender la herramienta, modelar, exportar y descubrir que la malla tiene agujeros… 😩

Aquí el flujo es una conversación:

1. 📸 Saca fotos de la pieza (o del lugar donde encaja)
2. 📏 Mide con el calibre y envía todo en milímetros
3. 💬 Describe lo que necesitas en Claude Code
4. 🎉 Recibe el `.stl` validado, con dimensiones verificadas y orientación de impresión sugerida

Claude modela, **mira las vistas previas renderizadas**, corrige la geometría por sí solo y solo entrega STL que pasaron la validación de estanqueidad.

> **Describir cuesta minutos. Aprender CAD cuesta semanas.**

---

## ✨ Qué hay dentro

| | |
|---|---|
| 🗣️ **Skill `/peca-3d`** | Guion guiado: requisitos → modelado → iteración visual → entrega |
| ⚙️ **Dos motores de CAD** | OpenSCAD para piezas prismáticas, build123d para curvas, redondeos y roscas |
| 🔬 **Validación automática** | Cada pieza pasa por una comprobación de estanqueidad — una malla rota nunca llega al laminador |
| 🖼️ **Vistas previas en 6 ángulos** | Renderizador ortográfico propio (superior, frontal, trasera, laterales e iso) para que Claude verifique la geometría |
| 📐 **Convenciones de taller** | Holguras de ajuste (0.2/0.4 mm), pared mínima de 1.2 mm, tolerancias para tornillos — ya integradas |
| 📦 **Instalador portátil** | Un `install.sh` idempotente |
| 🧾 **Todo paramétrico** | Cada pieza es código con medidas nombradas — ajustar 2 mm es editar una variable |

---

## 📦 Instalación

### 1️⃣ Clona el repositorio

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ Ejecuta el instalador

```bash
sudo ./install.sh
```

El instalador se encarga de todo — instala OpenSCAD vía `apt`, crea el venv de Python (`.venv`) con build123d + trimesh **perteneciente a tu usuario** (no a root) y termina ejecutando una prueba real de generación de STL. Idempotente: puedes ejecutarlo de nuevo cuando quieras.

### 3️⃣ Verifica la instalación

```bash
./install.sh --check
```

Listo. 🎉

> 💡 **Único prerrequisito:** cualquier Linux con `apt` (Ubuntu, Debian, Mint, Pop!_OS…), `sudo` y Python 3.10+.

---

## 🚀 Cómo usarlo

```bash
cd stl-maker && claude
```

Después solo conversa — o llama a la skill directamente:

```
/peca-3d soporte de pared para el router, 3 agujeros de 4 mm, 120 mm entre tornillos
```

Pega las fotos en la conversación, envía las medidas en mm y Claude se encarga del resto. La pieza sale en `pecas/<nombre>/`:

```
pecas/soporte-router/
├── soporte-router.scad     # el código fuente paramétrico
├── soporte-router.stl      # listo para el laminador
└── previews/               # 6 vistas renderizadas
```

---

## 🧰 Los dos motores (ambos gratis)

| Opción | Herramienta | Cuándo usarla |
|---|---|---|
| 🟨 Simple | OpenSCAD (`.scad`) | Soportes, ganchos, espaciadores, cajas, adaptadores |
| 🐍 Compleja | build123d (`.py`) | Redondeos, chaflanes, curvas, roscas, exportar STEP |

`scripts/gerar.sh` acepta ambos y decide solo qué compilador llamar.

---

## 🏗️ Cómo funciona por dentro

```
descripción + fotos + medidas
        │
        ▼
 .scad o .py  ──►  scripts/gerar.sh  ──►  STL
                        │
                        ├── validar_stl.py   (estanqueidad + dimensiones)
                        └── preview_stl.py   (6 vistas PNG que Claude lee)
```

### Estructura del repositorio

```
├── CLAUDE.md               # reglas y convenciones que Claude sigue
├── install.sh              # instalador idempotente (requiere sudo)
├── scripts/
│   ├── gerar.sh            # compila, valida y genera vistas previas
│   ├── validar_stl.py      # nunca entrega un STL no estanco
│   └── preview_stl.py      # renderizador ortográfico headless
├── .claude/skills/peca-3d/ # la skill que guía la creación de piezas
└── pecas/                  # tus piezas (creadas localmente, fuera de git)
```

---

## 🐛 Solución de problemas

<details>
<summary><strong>"La reparación automática falló" en la validación</strong></summary>

La malla salió no estanca y trimesh no pudo repararla. No imprimas ese STL — pide a Claude que revise el modelo (suele ser un booleano con caras coincidentes; extender el cortador ~1 mm más allá de la superficie lo resuelve).

</details>

<details>
<summary><strong>"La instalación requiere sudo"</strong></summary>

Por diseño, el instalador solo se ejecuta con sudo: `sudo ./install.sh`. Solo `./install.sh --check` funciona sin él.

</details>

<details>
<summary><strong>Mover a otra máquina Ubuntu</strong></summary>

Clona el repositorio (o copia la carpeta sin `.venv/` ni `bin/`, que se recrean) y ejecuta `sudo ./install.sh` en la máquina nueva.

</details>

---

## 🗿 Formas orgánicas (figuras, esculturas)

Eso no es CAD — usa un generador de foto→3D:

- [Tripo](https://www.tripo3d.ai) o [Meshy](https://www.meshy.ai) — ambos tienen plan gratuito
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — open source, corre en local (necesita GPU)

El STL generado puede validarse y repararse aquí con `scripts/validar_stl.py`. 😉

---

<p align="center">
  Hecho con 🧡 y <a href="https://claude.com/claude-code">Claude Code</a> — describe la pieza, imprime la solución.
</p>
