# Matt Pocock Skills — 日本語版

[mattpocock/skills](https://github.com/mattpocock/skills) のフォーク版に、**日本語化された skill セット** を追加したもの。

## このフォークについて

- **オリジナル**: `skills/` ディレクトリ配下に原文をそのまま保持（upstream 追従用）
- **日本語版**: `skills-ja/` ディレクトリ配下に配置
- **skill 名**: 原文と同名（プラグイン namespace で自動的に衝突回避）
- **trigger**: frontmatter の `description` は **日本語専用**（英語トリガーは原文 plugin 側で発火）
- **訳語**: `translate-tech-docs` skill の GLOSSARY Tier 1 ルールに準拠（Module / Seam / regression test 等は原語維持）

## クイックスタート

### Marketplace 経由で本家 + JA 両方を install

このフォークは **marketplace** として機能し、本家と JA 版の両方を一括登録できる:

```bash
# Claude Code 内で
/plugin marketplace add EOR-Effulgence/skills

# 英語版（本家）を install
/plugin install mattpocock-skills@eor-skills

# 日本語版を install
/plugin install matt-pocock-skills-ja@eor-skills
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

## 収録 skill 一覧（23 件）

本家 `mattpocock/skills` の promoted skill (engineering 17 + productivity 5) を全て日本語化し、`caveman`（本家削除済み・fork 固有）を維持している。

### engineering (17)

| skill | 用途 |
|---|---|
| `ask-matt` | どの skill / flow を使うか案内する router |
| `diagnosing-bugs` | 難バグ・performance regression の規律ある診断ループ |
| `grill-with-docs` | 既存ドメインモデルに照らした計画の壁打ち（`/domain-modeling` + `/grilling`） |
| `triage` | issue を state machine ラベルで分類 |
| `improve-codebase-architecture` | deepening 機会の探索（Module ベースのリファクタ） |
| `setup-matt-pocock-skills` | プロジェクト固有設定（issue tracker / triage ラベル / ドキュメント置き場）の初期化 |
| `tdd` | 垂直スライス TDD（red-green-refactor）。水平スライス禁止 |
| `to-spec` | 会話を spec 化して issue tracker に投稿 |
| `to-tickets` | 計画 / spec を tracer bullet の独立 ticket に分割 |
| `wayfinder` | decision ticket を subagent で潰していく探索 |
| `implement` | spec / ticket を TDD + code-review で実装 |
| `prototype` | 使い捨てプロトタイプ（CLI logic または UI バリエーション） |
| `research` | background agent で調査し Markdown にまとめる |
| `domain-modeling` | ドメインモデリング + CONTEXT.md / ADR 整備 |
| `codebase-design` | Ousterhout 流 deep module 設計（design it twice / deepening） |
| `code-review` | 変更を dimension 別にレビュー |
| `resolving-merge-conflicts` | merge / rebase conflict を意図を汲んで解消 |

### productivity (6)

| skill | 用途 |
|---|---|
| `grill-me` | 計画 / 設計を容赦なく詰める interview（`/grilling`） |
| `grilling` | grill 系スキルが使う共通 primitive（壁打ちセッション） |
| `handoff` | 会話を引き継ぎドキュメントに圧縮 |
| `teach` | 学習ミッション設計（fluency / storage strength） |
| `writing-great-skills` | 優れた skill を設計・記述（progressive disclosure 等） |
| `caveman` | 超圧縮通信モード（トークン使用量 ~75% 削減、fork 固有） |

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
