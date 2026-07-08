<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong>Your 3D parts workshop inside <a href="https://claude.com/claude-code">Claude Code</a>.</strong><br>
  Photos + measurements become validated <code>.stl</code> files, ready to slice and print.
</p>

<p align="center">
  <strong>🇺🇸 English</strong> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
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

## 💡 Why use it

Need a bracket, hook, adapter or replacement part? The traditional path is opening a CAD tool, learning it, modeling, exporting, and then discovering your mesh has holes… 😩

Here the workflow is a conversation:

1. 📸 Take photos of the part (or of the spot where it fits)
2. 📏 Measure with calipers and send everything in millimeters
3. 💬 Describe what you need in Claude Code
4. 🎉 Get a validated `.stl`, with checked dimensions and a suggested print orientation

Claude models the part, **looks at the rendered previews**, fixes the geometry by itself and only delivers STLs that passed the watertightness check.

> **Describing takes minutes. Learning CAD takes weeks.**

---

## ✨ What's inside

| | |
|---|---|
| 🗣️ **`/peca-3d` skill** | Guided workflow: requirements → modeling → visual iteration → delivery |
| ⚙️ **Two CAD engines** | OpenSCAD for prismatic parts, build123d for curves, fillets and threads |
| 🔬 **Automatic validation** | Every part goes through a watertightness check — broken meshes never reach the slicer |
| 🖼️ **Previews in 6 views** | Custom orthographic renderer (top, front, back, sides and iso) so Claude can verify the geometry |
| 📐 **Workshop conventions** | Fit clearances (0.2/0.4 mm), 1.2 mm minimum walls, screw hole tolerances — built in |
| 📦 **Portable installer** | One idempotent `install.sh` |
| 🧾 **Everything parametric** | Each part is code with named measurements — adjusting 2 mm is editing one variable |

---

## 📦 Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ Run the installer

```bash
sudo ./install.sh
```

The installer takes care of everything — it installs OpenSCAD via `apt`, creates the Python venv (`.venv`) with build123d + trimesh **owned by your user** (not root), and finishes by running a real STL generation test. Idempotent: run it again anytime.

### 3️⃣ Verify the installation

```bash
./install.sh --check
```

Done. 🎉

> 💡 **Single prerequisite:** any Linux with `apt` (Ubuntu, Debian, Mint, Pop!_OS…), `sudo` and Python 3.10+.

---

## 🚀 How to use

```bash
cd stl-maker && claude
```

Then just talk — or call the skill directly:

```
/peca-3d wall bracket for the router, 3 holes of 4 mm, 120 mm span between screws
```

Paste photos into the conversation, send the measurements in mm and Claude handles the rest. The part lands in `pecas/<name>/`:

```
pecas/router-bracket/
├── router-bracket.scad     # the parametric source
├── router-bracket.stl      # ready for the slicer
└── previews/               # 6 rendered views
```

---

## 🧰 The two engines (both free)

| Option | Tool | When to use |
|---|---|---|
| 🟨 Simple | OpenSCAD (`.scad`) | Brackets, hooks, spacers, boxes, adapters |
| 🐍 Complex | build123d (`.py`) | Fillets, chamfers, curves, threads, STEP export |

`scripts/gerar.sh` accepts both and picks the right compiler by itself.

---

## 🎋 Bambu Lab: ready-to-print 3MF

With `--bambu`, the pipeline also produces two extra files using the official Bambu Studio CLI (installed by `install.sh` as an AppImage in `bin/`):

```
scripts/gerar.sh --bambu pecas/my-part/part.scad
```

| File | What it is |
|---|---|
| `part.3mf` | Project with printer/filament/process settings embedded — opens ready in Bambu Studio |
| `part.gcode.3mf` | Sliced — send straight to the printer (SD card, Bambu Handy or LAN) |

Printer, filament and process profiles live in `config/bambu.json` (defaults: A1, 0.4 nozzle, Bambu PLA Basic, 0.20mm Standard — edit to match your setup; names must match the official profile JSONs under `bin/bambustudio-appimage/resources/profiles/BBL/`). Multi-color (AMS) painting still happens in Bambu Studio — open the project `.3mf` there.

---

## 🏗️ How it works under the hood

```
description + photos + measurements
        │
        ▼
 .scad or .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   (watertightness + dimensions)
                         └── preview_stl.py   (6 PNG views that Claude reads)
```

### Repository layout

```
├── CLAUDE.md               # rules and conventions Claude follows
├── install.sh              # idempotent installer (requires sudo)
├── scripts/
│   ├── gerar.sh            # compiles, validates and renders previews
│   ├── validar_stl.py      # never ships a non-watertight STL
│   └── preview_stl.py      # headless orthographic renderer
├── .claude/skills/peca-3d/ # the skill that guides part creation
└── pecas/                  # your parts (created locally, outside git)
```

---

## 🐛 Troubleshooting

<details>
<summary><strong>"Automatic repair failed" during validation</strong></summary>

The mesh came out non-watertight and trimesh couldn't repair it. Don't print that STL — ask Claude to review the model (usually a boolean with coincident faces; extending the cutter ~1 mm past the surface fixes it).

</details>

<details>
<summary><strong>"Installation requires sudo"</strong></summary>

By design, the installer only runs with sudo: `sudo ./install.sh`. Only `./install.sh --check` runs without it.

</details>

<details>
<summary><strong>Moving to another Ubuntu machine</strong></summary>

Clone the repo (or copy the folder without `.venv/` and `bin/`, which get recreated) and run `sudo ./install.sh` on the new machine.

</details>

---

## 🗿 Organic shapes (figurines, sculptures)

That's not CAD — use a photo→3D generator:

- [Tripo](https://www.tripo3d.ai) or [Meshy](https://www.meshy.ai) — both have free plans
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — open source, runs locally (needs a GPU)

The generated STL can be validated and repaired here with `scripts/validar_stl.py`. 😉

---

<p align="center">
  Made with 🧡 and <a href="https://claude.com/claude-code">Claude Code</a> — describe the part, print the solution.
</p>
