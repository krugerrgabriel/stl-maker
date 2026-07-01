<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong><a href="https://claude.com/claude-code">Claude Code</a> の中にある、あなたの 3D パーツ工房。</strong><br>
  写真 + 寸法が、スライスして印刷できる検証済みの <code>.stl</code> ファイルになります。
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
  <strong>🇯🇵 日本語</strong> ·
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

## 💡 なぜ使うのか

ブラケット、フック、アダプター、交換部品が必要ですか？従来のやり方は、CAD ツールを開き、使い方を学び、モデリングし、エクスポートして、そしてメッシュに穴があることに気づく…というものでした 😩

ここでは、ワークフローは会話です。

1. 📸 部品（またはそれを取り付ける場所）の写真を撮る
2. 📏 ノギスで採寸し、すべてミリメートル単位で送る
3. 💬 Claude Code で必要なものを説明する
4. 🎉 寸法チェック済みで印刷向きの提案付きの、検証済み `.stl` を受け取る

Claude が部品をモデリングし、**レンダリングされたプレビューを自分で確認し**、ジオメトリを自ら修正して、水密性チェックに合格した STL だけを納品します。

> **説明するのは数分。CAD を学ぶのは数週間。**

---

## ✨ 中身

| | |
|---|---|
| 🗣️ **`/peca-3d` スキル** | ガイド付きワークフロー：要件 → モデリング → 視覚的な反復 → 納品 |
| ⚙️ **2 つの CAD エンジン** | 角柱状の部品には OpenSCAD、曲線・フィレット・ねじには build123d |
| 🔬 **自動検証** | すべての部品が水密性チェックを通過 — 壊れたメッシュがスライサーに届くことはありません |
| 🖼️ **6 ビューのプレビュー** | カスタム正投影レンダラー（上面、正面、背面、側面、アイソメ）により Claude がジオメトリを検証できます |
| 📐 **工房の規約** | はめ合いのクリアランス（0.2/0.4 mm）、最小壁厚 1.2 mm、ネジ穴の公差 — 標準装備 |
| 📦 **ポータブルなインストーラー** | 冪等な `install.sh` が 1 つだけ |
| 🧾 **すべてパラメトリック** | 各部品は名前付き寸法を持つコード — 2 mm の調整は変数 1 つを編集するだけ |

---

## 📦 インストール

### 1️⃣ リポジトリをクローンする

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ インストーラーを実行する

```bash
sudo ./install.sh
```

インストーラーがすべて面倒を見ます — `apt` で OpenSCAD をインストールし、build123d + trimesh 入りの Python venv（`.venv`）を **root ではなくあなたのユーザーの所有で**作成し、最後に実際の STL 生成テストを実行します。冪等なので、いつでも再実行できます。

### 3️⃣ インストールを確認する

```bash
./install.sh --check
```

完了です。🎉

> 💡 **唯一の前提条件:** `apt` が使える任意の Linux（Ubuntu、Debian、Mint、Pop!_OS…）、`sudo`、そして Python 3.10+。

---

## 🚀 使い方

```bash
cd stl-maker && claude
```

あとは話しかけるだけ — スキルを直接呼び出すこともできます。

```
/peca-3d ルーター用の壁掛けブラケット、4 mm の穴 3 つ、ネジ間の間隔 120 mm
```

会話に写真を貼り付け、寸法を mm で送れば、残りは Claude が引き受けます。部品は `pecas/<name>/` に生成されます。

```
pecas/router-bracket/
├── router-bracket.scad     # パラメトリックなソース
├── router-bracket.stl      # スライサーに渡せる状態
└── previews/               # レンダリングされた 6 ビュー
```

---

## 🧰 2 つのエンジン（どちらも無料）

| オプション | ツール | 使いどころ |
|---|---|---|
| 🟨 シンプル | OpenSCAD (`.scad`) | ブラケット、フック、スペーサー、ボックス、アダプター |
| 🐍 複雑 | build123d (`.py`) | フィレット、面取り、曲線、ねじ、STEP エクスポート |

`scripts/gerar.sh` はどちらも受け付け、適切なコンパイラを自動で選択します。

---

## 🏗️ 内部の仕組み

```
説明 + 写真 + 寸法
        │
        ▼
 .scad または .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   (水密性 + 寸法)
                         └── preview_stl.py   (Claude が読む 6 つの PNG ビュー)
```

### リポジトリ構成

```
├── CLAUDE.md               # Claude が従うルールと規約
├── install.sh              # 冪等なインストーラー（sudo が必要）
├── scripts/
│   ├── gerar.sh            # コンパイル、検証、プレビューのレンダリング
│   ├── validar_stl.py      # 水密でない STL は決して出荷しない
│   └── preview_stl.py      # ヘッドレスの正投影レンダラー
├── .claude/skills/peca-3d/ # 部品作成をガイドするスキル
└── pecas/                  # あなたの部品（ローカルに作成、git の管理外）
```

---

## 🐛 トラブルシューティング

<details>
<summary><strong>検証中に「Automatic repair failed」と表示される</strong></summary>

メッシュが水密でない状態で生成され、trimesh でも修復できませんでした。その STL は印刷しないでください — Claude にモデルの見直しを依頼してください（原因はたいてい面が一致したブーリアン演算で、カッターを表面から約 1 mm 延長すると解決します）。

</details>

<details>
<summary><strong>「Installation requires sudo」と表示される</strong></summary>

設計上、インストーラーは sudo でのみ実行されます: `sudo ./install.sh`。sudo なしで実行できるのは `./install.sh --check` だけです。

</details>

<details>
<summary><strong>別の Ubuntu マシンへ移行する</strong></summary>

リポジトリをクローンし（または `.venv/` と `bin/` を除いてフォルダをコピーし — これらは再作成されます）、新しいマシンで `sudo ./install.sh` を実行してください。

</details>

---

## 🗿 有機的な形状（フィギュア、彫刻）

それは CAD ではありません — 写真→3D ジェネレーターを使ってください。

- [Tripo](https://www.tripo3d.ai) または [Meshy](https://www.meshy.ai) — どちらも無料プランあり
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — オープンソース、ローカルで動作（GPU が必要）

生成された STL は、ここで `scripts/validar_stl.py` を使って検証・修復できます。😉

---

<p align="center">
  🧡 と <a href="https://claude.com/claude-code">Claude Code</a> で作りました — 部品を説明すれば、解決策が印刷されます。
</p>
