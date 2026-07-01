<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong>你在 <a href="https://claude.com/claude-code">Claude Code</a> 中的 3D 零件工坊。</strong><br>
  照片 + 测量数据变成经过验证的 <code>.stl</code> 文件，随时可切片打印。
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
  <a href="README.ja.md">🇯🇵 日本語</a> ·
  <strong>🇨🇳 简体中文</strong> ·
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

## 💡 为什么使用它

需要一个支架、挂钩、适配器或替换零件？传统的做法是打开 CAD 软件、学习它、建模、导出，然后发现你的网格上有破洞…… 😩

在这里，工作流程就是一场对话：

1. 📸 拍下零件的照片（或它要安装位置的照片）
2. 📏 用卡尺测量，并以毫米为单位发送所有数据
3. 💬 在 Claude Code 中描述你需要什么
4. 🎉 获得经过验证的 `.stl` 文件，尺寸已核对，并附带建议的打印方向

Claude 会为零件建模，**查看渲染出的预览图**，自行修正几何形状，并且只交付通过了水密性检查的 STL 文件。

> **描述只需几分钟，学习 CAD 却要数周。**

---

## ✨ 包含什么

| | |
|---|---|
| 🗣️ **`/peca-3d` 技能** | 引导式工作流：需求 → 建模 → 视觉迭代 → 交付 |
| ⚙️ **两个 CAD 引擎** | OpenSCAD 处理棱柱类零件，build123d 处理曲线、圆角和螺纹 |
| 🔬 **自动验证** | 每个零件都要经过水密性检查——破损的网格绝不会进入切片软件 |
| 🖼️ **6 个视图的预览** | 自定义正交渲染器（顶视、前视、后视、侧视和等轴测），让 Claude 能核对几何形状 |
| 📐 **工坊约定** | 配合间隙（0.2/0.4 mm）、1.2 mm 最小壁厚、螺丝孔公差——全部内置 |
| 📦 **可移植的安装器** | 一个幂等的 `install.sh` |
| 🧾 **一切皆参数化** | 每个零件都是带命名尺寸的代码——调整 2 mm 只是修改一个变量 |

---

## 📦 安装

### 1️⃣ 克隆仓库

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ 运行安装器

```bash
sudo ./install.sh
```

安装器会处理好一切——它通过 `apt` 安装 OpenSCAD，创建包含 build123d + trimesh 的 Python 虚拟环境（`.venv`），**归属于你的用户**（而非 root），最后运行一次真实的 STL 生成测试。幂等：随时可以再次运行。

### 3️⃣ 验证安装

```bash
./install.sh --check
```

完成。🎉

> 💡 **唯一前提：** 任何带 `apt` 的 Linux（Ubuntu、Debian、Mint、Pop!_OS……）、`sudo` 和 Python 3.10+。

---

## 🚀 如何使用

```bash
cd stl-maker && claude
```

然后直接对话即可——或者直接调用技能：

```
/peca-3d 路由器的壁挂支架，3 个 4 mm 的孔，螺丝间距 120 mm
```

把照片粘贴到对话里，以 mm 为单位发送测量数据，其余交给 Claude 处理。零件会生成在 `pecas/<name>/` 中：

```
pecas/router-bracket/
├── router-bracket.scad     # 参数化源文件
├── router-bracket.stl      # 可直接用于切片软件
└── previews/               # 6 个渲染视图
```

---

## 🧰 两个引擎（都是免费的）

| 选项 | 工具 | 何时使用 |
|---|---|---|
| 🟨 简单 | OpenSCAD (`.scad`) | 支架、挂钩、垫片、盒子、适配器 |
| 🐍 复杂 | build123d (`.py`) | 圆角、倒角、曲线、螺纹、STEP 导出 |

`scripts/gerar.sh` 两者都接受，并会自行选择正确的编译器。

---

## 🏗️ 幕后工作原理

```
描述 + 照片 + 测量数据
        │
        ▼
 .scad 或 .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   （水密性 + 尺寸）
                         └── preview_stl.py   （供 Claude 读取的 6 个 PNG 视图）
```

### 仓库结构

```
├── CLAUDE.md               # Claude 遵循的规则和约定
├── install.sh              # 幂等安装器（需要 sudo）
├── scripts/
│   ├── gerar.sh            # 编译、验证并渲染预览图
│   ├── validar_stl.py      # 绝不交付非水密的 STL
│   └── preview_stl.py      # 无头正交渲染器
├── .claude/skills/peca-3d/ # 引导零件创建的技能
└── pecas/                  # 你的零件（在本地创建，不纳入 git）
```

---

## 🐛 疑难解答

<details>
<summary><strong>验证时提示 "Automatic repair failed"（自动修复失败）</strong></summary>

生成的网格不是水密的，而且 trimesh 无法修复它。不要打印那个 STL——让 Claude 检查模型（通常是布尔运算中出现了重合面；把切割体向表面外延伸约 1 mm 即可解决）。

</details>

<details>
<summary><strong>"Installation requires sudo"（安装需要 sudo）</strong></summary>

按照设计，安装器只能通过 sudo 运行：`sudo ./install.sh`。只有 `./install.sh --check` 无需 sudo。

</details>

<details>
<summary><strong>迁移到另一台 Ubuntu 机器</strong></summary>

克隆仓库（或复制文件夹，但不含会被重新创建的 `.venv/` 和 `bin/`），然后在新机器上运行 `sudo ./install.sh`。

</details>

---

## 🗿 有机形状（手办、雕塑）

那不是 CAD——请使用照片→3D 生成器：

- [Tripo](https://www.tripo3d.ai) 或 [Meshy](https://www.meshy.ai)——两者都有免费方案
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2)——开源，可本地运行（需要 GPU）

生成的 STL 可以在这里用 `scripts/validar_stl.py` 进行验证和修复。😉

---

<p align="center">
  用 🧡 和 <a href="https://claude.com/claude-code">Claude Code</a> 打造——描述零件，打印解决方案。
</p>
