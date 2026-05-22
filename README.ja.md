# Matt Pocock Skills — 日本語版

[mattpocock/skills](https://github.com/mattpocock/skills) のフォーク版に、**日本語化された skill セット** を追加したもの。

## このフォークについて

- **オリジナル**: `skills/` ディレクトリ配下に原文をそのまま保持（upstream 追従用）
- **日本語版**: `skills-ja/` ディレクトリ配下に配置
- **skill 名**: ローカル既存 skill との衝突を避けるため `matt-` プレフィックス付き
- **trigger**: frontmatter の `description` に日英両言語のトリガーワードを併記

## クイックスタート

### Claude Code plugin として install

```bash
# .claude/settings.json または対話で plugin を追加
/plugin install EOR-Effulgence/skills
```

`/plugin install` で skills-ja/ 配下 14 件が読み込まれる。

### ローカル skill として直配置

```bash
# fork を任意の場所に clone
cd ~/your/work/dir
git clone https://github.com/EOR-Effulgence/skills.git matt-skills

# skills-ja/ の各 skill を ~/.claude/skills/ に symlink
ln -s ~/your/work/dir/matt-skills/skills-ja/engineering/matt-tdd ~/.claude/skills/matt-tdd
# 必要な skill を個別に link
```

## 収録 skill 一覧（14 件）

### engineering (10)

| skill | 用途 |
|---|---|
| `matt-grill-with-docs` | 既存ドメインモデルに照らした計画の壁打ち + CONTEXT.md / ADR 即時更新 |
| `matt-tdd` | 垂直スライス TDD（red-green-refactor）。水平スライス禁止 |
| `matt-diagnose` | 難バグ・パフォーマンス回帰の規律あるデバッグループ |
| `matt-improve-codebase-architecture` | Deep Modules ベースのリファクタ機会探索 |
| `matt-to-prd` | 会話を PRD 化して issue に投稿 |
| `matt-to-issues` | 計画 / spec / PRD を独立 issue に分割 |
| `matt-triage` | issue を状態機械ラベルで分類 |
| `matt-zoom-out` | コードのより広い文脈・高次視点を提示 |
| `matt-prototype` | 使い捨てプロトタイプ（CLI またはUI バリエーション） |
| `matt-setup` | プロジェクト固有設定（issue tracker / triage ラベル / ドキュメント置き場）の初期化 |

### productivity (4)

| skill | 用途 |
|---|---|
| `matt-grill-me` | 計画 / 設計について容赦なく質問されるセッション |
| `matt-handoff` | 会話を引き継ぎドキュメントに圧縮 |
| `matt-caveman` | 超圧縮通信モード（トークン使用量 ~75% 削減） |
| `matt-write-a-skill` | 新規 skill を構造化して作成 |

## 既存ローカル skill との関係

このユーザーは既に `handoff` / `diagnose` / `grill-me` / `grill-with-docs` / `write-a-skill` をローカル `~/.claude/skills/` に持っているため、`matt-` プレフィックスで衝突を回避している。

両方を使い分けたい場合:
- 軽量・即応性重視: 既存ローカル版
- Matt 流の厳密さ重視: `matt-*` 版

## upstream 同期手順

```bash
git remote add upstream https://github.com/mattpocock/skills.git
git fetch upstream
git merge upstream/main  # skills/ 配下にしか変更が来ないので衝突しにくい
```

`skills/` には一切手を入れていないため、upstream merge はクリーンに通る想定。

## ライセンス

オリジナルに準拠（MIT）。
