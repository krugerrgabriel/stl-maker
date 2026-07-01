<h1 align="center">🖨️ STL Maker</h1>

<p align="center">
  <strong><a href="https://claude.com/claude-code">Claude Code</a> 안의 3D 부품 작업실.</strong><br>
  사진 + 치수가 검증된 <code>.stl</code> 파일이 되어, 바로 슬라이스하고 출력할 수 있습니다.
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> ·
  <a href="README.pt-BR.md">🇧🇷 Português</a> ·
  <a href="README.es.md">🇪🇸 Español</a> ·
  <a href="README.ja.md">🇯🇵 日本語</a> ·
  <a href="README.zh-CN.md">🇨🇳 简体中文</a> ·
  <strong>🇰🇷 한국어</strong> ·
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

## 💡 왜 사용할까요

브래킷, 후크, 어댑터나 교체 부품이 필요하신가요? 전통적인 방법은 CAD 툴을 열고, 배우고, 모델링하고, 내보낸 다음, 메시에 구멍이 있다는 걸 발견하는 것이죠… 😩

여기서는 워크플로가 대화입니다:

1. 📸 부품(또는 부품이 끼워질 자리)의 사진을 찍습니다
2. 📏 캘리퍼스로 측정하고 모든 치수를 밀리미터 단위로 보냅니다
3. 💬 Claude Code에서 필요한 것을 설명합니다
4. 🎉 치수가 확인되고 권장 출력 방향이 포함된, 검증된 `.stl` 파일을 받습니다

Claude가 부품을 모델링하고, **렌더링된 프리뷰를 직접 확인하며**, 스스로 지오메트리를 수정하고, 수밀성(watertightness) 검사를 통과한 STL만 전달합니다.

> **설명하는 데는 몇 분이면 됩니다. CAD를 배우려면 몇 주가 걸립니다.**

---

## ✨ 구성 요소

| | |
|---|---|
| 🗣️ **`/peca-3d` 스킬** | 가이드 워크플로: 요구사항 → 모델링 → 시각적 반복 → 전달 |
| ⚙️ **두 가지 CAD 엔진** | 각기둥형 부품은 OpenSCAD, 곡선·필렛·나사산은 build123d |
| 🔬 **자동 검증** | 모든 부품이 수밀성 검사를 거칩니다 — 깨진 메시는 절대 슬라이서에 도달하지 않습니다 |
| 🖼️ **6개 뷰 프리뷰** | Claude가 지오메트리를 확인할 수 있도록 커스텀 직교 투영 렌더러(윗면, 정면, 뒷면, 측면, 아이소메트릭) 제공 |
| 📐 **작업실 컨벤션** | 끼워맞춤 공차(0.2/0.4 mm), 최소 벽 두께 1.2 mm, 나사 구멍 공차 — 기본 내장 |
| 📦 **이식 가능한 설치 스크립트** | 멱등성 있는 `install.sh` 하나면 충분 |
| 🧾 **모든 것이 파라메트릭** | 각 부품은 이름 붙은 치수를 가진 코드입니다 — 2 mm 조정은 변수 하나만 수정하면 됩니다 |

---

## 📦 설치

### 1️⃣ 저장소 클론

```bash
git clone https://github.com/krugerrgabriel/stl-maker.git
cd stl-maker
```

### 2️⃣ 설치 스크립트 실행

```bash
sudo ./install.sh
```

설치 스크립트가 모든 것을 처리합니다 — `apt`로 OpenSCAD를 설치하고, build123d + trimesh가 포함된 Python venv(`.venv`)를 **root가 아닌 사용자 소유로** 생성하며, 마지막에 실제 STL 생성 테스트를 실행합니다. 멱등성이 있으므로 언제든 다시 실행해도 됩니다.

### 3️⃣ 설치 확인

```bash
./install.sh --check
```

완료. 🎉

> 💡 **유일한 사전 요구사항:** `apt`를 사용하는 아무 Linux(Ubuntu, Debian, Mint, Pop!_OS…), `sudo`, 그리고 Python 3.10+.

---

## 🚀 사용 방법

```bash
cd stl-maker && claude
```

그다음 그냥 대화하세요 — 또는 스킬을 직접 호출하세요:

```
/peca-3d 라우터용 벽면 브래킷, 4 mm 구멍 3개, 나사 간격 120 mm
```

대화에 사진을 붙여넣고 치수를 mm 단위로 보내면 나머지는 Claude가 처리합니다. 부품은 `pecas/<name>/`에 생성됩니다:

```
pecas/router-bracket/
├── router-bracket.scad     # 파라메트릭 소스
├── router-bracket.stl      # 슬라이서에 바로 사용 가능
└── previews/               # 렌더링된 6개의 뷰
```

---

## 🧰 두 가지 엔진 (둘 다 무료)

| 옵션 | 도구 | 사용 시점 |
|---|---|---|
| 🟨 간단 | OpenSCAD (`.scad`) | 브래킷, 후크, 스페이서, 상자, 어댑터 |
| 🐍 복잡 | build123d (`.py`) | 필렛, 챔퍼, 곡선, 나사산, STEP 내보내기 |

`scripts/gerar.sh`는 둘 다 받아서 알아서 올바른 컴파일러를 선택합니다.

---

## 🏗️ 내부 동작 방식

```
설명 + 사진 + 치수
        │
        ▼
 .scad 또는 .py  ──►  scripts/gerar.sh  ──►  STL
                         │
                         ├── validar_stl.py   (수밀성 + 치수 검사)
                         └── preview_stl.py   (Claude가 읽는 6개의 PNG 뷰)
```

### 저장소 구조

```
├── CLAUDE.md               # Claude가 따르는 규칙과 컨벤션
├── install.sh              # 멱등성 설치 스크립트 (sudo 필요)
├── scripts/
│   ├── gerar.sh            # 컴파일, 검증, 프리뷰 렌더링
│   ├── validar_stl.py      # 수밀하지 않은 STL은 절대 내보내지 않음
│   └── preview_stl.py      # 헤드리스 직교 투영 렌더러
├── .claude/skills/peca-3d/ # 부품 생성을 안내하는 스킬
└── pecas/                  # 사용자의 부품 (로컬에 생성, git 외부)
```

---

## 🐛 문제 해결

<details>
<summary><strong>검증 중 "Automatic repair failed" 발생</strong></summary>

메시가 수밀하지 않게 생성되었고 trimesh가 복구하지 못했습니다. 그 STL은 출력하지 마세요 — Claude에게 모델 검토를 요청하세요 (대부분 면이 겹치는 불리언 연산이 원인이며, 커터를 표면보다 ~1 mm 더 연장하면 해결됩니다).

</details>

<details>
<summary><strong>"Installation requires sudo" 오류</strong></summary>

설계상 설치 스크립트는 sudo로만 실행됩니다: `sudo ./install.sh`. `./install.sh --check`만 sudo 없이 실행할 수 있습니다.

</details>

<details>
<summary><strong>다른 Ubuntu 머신으로 이전하기</strong></summary>

저장소를 클론하거나 (다시 생성되는 `.venv/`와 `bin/`을 제외하고 폴더를 복사한 뒤) 새 머신에서 `sudo ./install.sh`를 실행하세요.

</details>

---

## 🗿 유기적 형상 (피규어, 조각품)

그건 CAD가 아닙니다 — 사진→3D 생성기를 사용하세요:

- [Tripo](https://www.tripo3d.ai) 또는 [Meshy](https://www.meshy.ai) — 둘 다 무료 플랜 제공
- [Hunyuan3D](https://github.com/Tencent/Hunyuan3D-2) — 오픈 소스, 로컬 실행 (GPU 필요)

생성된 STL은 여기서 `scripts/validar_stl.py`로 검증하고 복구할 수 있습니다. 😉

---

<p align="center">
  🧡와 <a href="https://claude.com/claude-code">Claude Code</a>로 만들었습니다 — 부품을 설명하면, 해결책이 출력됩니다.
</p>
