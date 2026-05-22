# Matt Pocock Skills — 日本語版

[mattpocock/skills](https://github.com/mattpocock/skills) のフォーク版に、**日本語化された skill セット** を追加したもの。

## このフォークについて

- **オリジナル**: `skills/` ディレクトリ配下に原文をそのまま保持（upstream 追従用）
- **日本語版**: `skills-ja/` ディレクトリ配下に配置
- **skill 名**: 原文と同名（プラグイン namespace で自動的に衝突回避）
- **trigger**: frontmatter の `description` は **日本語専用**（英語トリガーは原文 plugin 側で発火）
- **訳語**: `translate-tech-docs` skill の GLOSSARY Tier 1 ルールに準拠（Module / Seam / regression test 等は原語維持）

## クイックスタート

### 本家プラグインと併用する設計

```bash
# 英語トリガー用（Matt 本家）
/plugin install mattpocock/skills

# 日本語トリガー用（本フォーク）
/plugin install EOR-Effulgence/skills
```

ユーザーの発話言語で自然に棲み分けされる:

| 発話 | 発火する skill |
|---|---|
| `diagnose this` / `debug this` | `mattpocock-skills:diagnose` |
| `これを診断して` / `規律でデバッグ` | `matt-pocock-skills-ja:diagnose` |
| `grill me` | `mattpocock-skills:grill-me` |
| `壁打ちして` / `設計を焼いて` | `matt-pocock-skills-ja:grill-me` |

### ローカル skill として直配置（plugin 経由でない場合）

```bash
# fork を任意の場所に clone
git clone https://github.com/EOR-Effulgence/skills.git ~/work/skills-ja

# skills-ja/ の必要な skill を ~/.claude/skills/ に symlink
ln -s ~/work/skills-ja/skills-ja/engineering/tdd ~/.claude/skills/tdd-ja
```

直配置する場合は **本家との衝突回避**のため、自分で接尾辞（例: `-ja`）を付けることを推奨。

## 収録 skill 一覧（14 件）

### engineering (10)

| skill | 用途 |
|---|---|
| `grill-with-docs` | 既存ドメインモデルに照らした計画の壁打ち + CONTEXT.md / ADR 即時更新 |
| `tdd` | 垂直スライス TDD（red-green-refactor）。水平スライス禁止 |
| `diagnose` | 難バグ・performance regression の規律ある診断ループ |
| `improve-codebase-architecture` | Deep Module ベースのリファクタ機会探索 |
| `to-prd` | 会話を PRD 化して issue に投稿 |
| `to-issues` | 計画 / spec / PRD を独立 issue に分割 |
| `triage` | issue を state machine ラベルで分類 |
| `zoom-out` | コードのより広い文脈・高次視点を提示 |
| `prototype` | 使い捨てプロトタイプ（CLI または UI バリエーション） |
| `setup` | プロジェクト固有設定（issue tracker / triage ラベル / ドキュメント置き場）の初期化 |

### productivity (4)

| skill | 用途 |
|---|---|
| `grill-me` | 計画 / 設計について容赦なく質問されるセッション |
| `handoff` | 会話を引き継ぎドキュメントに圧縮 |
| `caveman` | 超圧縮通信モード（トークン使用量 ~75% 削減） |
| `write-a-skill` | 新規 skill を構造化して作成 |

## 訳語ルール

`~/.claude/skills/translate-tech-docs/` で管理する 3 ファイル（GLOSSARY.md / PRINCIPLES.md / STYLE.md）に従って訳出している:

- **Tier 1**: 原語維持（GoF / DDD / Ousterhout / Feathers / 固有プロセス概念 / 略号）
- **Tier 2**: 必ず訳す（regression / hypothesis / falsifiable 等）
- **Tier 3**: 文脈依存（domain / component / boundary 等）

## upstream 同期手順

```bash
git remote add upstream https://github.com/mattpocock/skills.git
git fetch upstream
git merge upstream/main  # skills/ 配下にしか変更が来ないので衝突しにくい
```

`skills/` には一切手を入れていないため、upstream merge はクリーンに通る想定。

## ライセンス

オリジナルに準拠（MIT）。
