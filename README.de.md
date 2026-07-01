<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong>Deine Werkstatt für 3D-Teile in <a href="https://claude.com/claude-code">Claude Code</a>.</strong><br>
  Fotos + Maße werden zu validierten <code>.stl</code>-Dateien, bereit zum Slicen und Drucken.
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
  <a href="README.ja.md">🇯🇵 日本語</a> ·
  <a href="README.zh-CN.md">🇨🇳 简体中文</a> ·
  <a href="README.ko.md">🇰🇷 한국어</a> ·
  <strong>🇩🇪 Deutsch</strong>
</p>

<p align="center">
  <img alt="Python" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="OpenSCAD" src="https://img.shields.io/badge/OpenSCAD-2021.01-F9D72C?logo=openscad&logoColor=black">
  <img alt="build123d" src="https://img.shields.io/badge/build123d-CAD%20in%20Python-0066cc">
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-apt%20%2B%20sudo-E95420?logo=ubuntu&logoColor=white">
  <img alt="Watertight STL" src="https://img.shields.io/badge/STL-always%20watertight-success">
</p>

---

## 💡 Warum es nutzen

Du brauchst eine Halterung, einen Haken, einen Adapter oder ein Ersatzteil? Der traditionelle Weg: ein CAD-Programm öffnen, es lernen, modellieren, exportieren — und dann feststellen, dass dein Mesh Löcher hat… 😩

Hier ist der Workflow ein Gespräch:

1. 📸 Mach Fotos vom Teil (oder von der Stelle, an die es passt)
2. 📏 Miss mit dem Messschieber und schick alles in Millimetern
3. 💬 Beschreibe in Claude Code, was du brauchst
4. 🎉 Erhalte eine validierte `.stl` mit geprüften Maßen und empfohlener Druckausrichtung

Claude modelliert das Teil, **schaut sich die gerenderten Vorschauen an**, korrigiert die Geometrie selbstständig und liefert nur STLs aus, die die Wasserdichtigkeitsprüfung bestanden haben.

> **Beschreiben dauert Minuten. CAD lernen dauert Wochen.**

---

## ✨ Was drin steckt

| | |
|---|---|
| 🗣️ **`/peca-3d`-Skill** | Geführter Workflow: Anforderungen → Modellierung → visuelle Iteration → Lieferung |
| ⚙️ **Zwei CAD-Engines** | OpenSCAD für prismatische Teile, build123d für Kurven, Verrundungen und Gewinde |
| 🔬 **Automatische Validierung** | Jedes Teil durchläuft eine Wasserdichtigkeitsprüfung — kaputte Meshes erreichen nie den Slicer |
| 🖼️ **Vorschauen in 6 Ansichten** | Eigener orthografischer Renderer (oben, vorne, hinten, Seiten und Iso), damit Claude die Geometrie prüfen kann |
| 📐 **Werkstatt-Konventionen** | Passungsspiel (0,2/0,4 mm), 1,2 mm Mindestwandstärke, Toleranzen für Schraubenlöcher — eingebaut |
| 📦 **Portabler Installer** | Ein einziges idempotentes `install.sh` |
| 🧾 **Alles parametrisch** | Jedes Teil ist Code mit benannten Maßen — 2 mm anpassen heißt eine Variable ändern |

---

## 📦 Installation

### 1️⃣ Repository klonen

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ Installer ausführen

```bash
sudo ./install.sh
```

Der Installer kümmert sich um alles — er installiert OpenSCAD über `apt`, erstellt das Python-venv (`.venv`) mit build123d + trimesh, **das deinem Benutzer gehört** (nicht root), und schließt mit einem echten STL-Generierungstest ab. Idempotent: kann jederzeit erneut ausgeführt werden.

### 3️⃣ Installation überprüfen

```bash
./install.sh --check
```

Fertig. 🎉

> 💡 **Einzige Voraussetzung:** ein beliebiges Linux mit `apt` (Ubuntu, Debian, Mint, Pop!_OS…), `sudo` und Python 3.10+.

---

## 🚀 Verwendung

```bash
cd stl-maker && claude
```

Dann einfach drauflosreden — oder die Skill direkt aufrufen:

```
/peca-3d Wandhalterung für den Router, 3 Löcher mit 4 mm, 120 mm Abstand zwischen den Schrauben
```

Füge Fotos in die Unterhaltung ein, schick die Maße in mm, und Claude erledigt den Rest. Das Teil landet in `pecas/<name>/`:

```
pecas/router-bracket/
├── router-bracket.scad     # die parametrische Quelle
├── router-bracket.stl      # bereit für den Slicer
└── previews/               # 6 gerenderte Ansichten
```

---

## 🧰 Die zwei Engines (beide kostenlos)

| Option | Werkzeug | Wann verwenden |
|---|---|---|
| 🟨 Einfach | OpenSCAD (`.scad`) | Halterungen, Haken, Abstandshalter, Boxen, Adapter |
| 🐍 Komplex | build123d (`.py`) | Verrundungen, Fasen, Kurven, Gewinde, STEP-Export |

`scripts/gerar.sh` akzeptiert beide und wählt selbstständig den richtigen Compiler.

---

## 🏗️ Wie es unter der Haube funktioniert

```
Beschreibung + Fotos + Maße
        │
        ▼
 .scad oder .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   (Wasserdichtigkeit + Maße)
                         └── preview_stl.py   (6 PNG-Ansichten, die Claude liest)
```

### Repository-Struktur

```
├── CLAUDE.md               # Regeln und Konventionen, die Claude befolgt
├── install.sh              # idempotenter Installer (benötigt sudo)
├── scripts/
│   ├── gerar.sh            # kompiliert, validiert und rendert Vorschauen
│   ├── validar_stl.py      # liefert nie eine nicht-wasserdichte STL aus
│   └── preview_stl.py      # headless orthografischer Renderer
├── .claude/skills/peca-3d/ # die Skill, die die Teileerstellung anleitet
└── pecas/                  # deine Teile (lokal erstellt, außerhalb von git)
```

---

## 🐛 Fehlerbehebung

<details>
<summary><strong>„Automatische Reparatur fehlgeschlagen“ während der Validierung</strong></summary>

Das Mesh war nicht wasserdicht und trimesh konnte es nicht reparieren. Drucke diese STL nicht — bitte Claude, das Modell zu überprüfen (meist eine boolesche Operation mit deckungsgleichen Flächen; den Schneidkörper ~1 mm über die Oberfläche hinaus zu verlängern behebt das Problem).

</details>

<details>
<summary><strong>„Installation benötigt sudo“</strong></summary>

Der Installer läuft absichtlich nur mit sudo: `sudo ./install.sh`. Nur `./install.sh --check` läuft ohne.

</details>

<details>
<summary><strong>Umzug auf einen anderen Ubuntu-Rechner</strong></summary>

Klone das Repo (oder kopiere den Ordner ohne `.venv/` und `bin/`, die neu erstellt werden) und führe auf dem neuen Rechner `sudo ./install.sh` aus.

</details>

---

## 🗿 Organische Formen (Figuren, Skulpturen)

Das ist kein CAD — nutze einen Foto→3D-Generator:

- [Tripo](https://www.tripo3d.ai) oder [Meshy](https://www.meshy.ai) — beide haben kostenlose Tarife
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — Open Source, läuft lokal (benötigt eine GPU)

Die generierte STL kann hier mit `scripts/validar_stl.py` validiert und repariert werden. 😉

---

<p align="center">
  Gemacht mit 🧡 und <a href="https://claude.com/claude-code">Claude Code</a> — beschreibe das Teil, drucke die Lösung.
</p>
