---
name: matt-write-a-skill
description: 適切な構造・段階的開示（progressive disclosure）・同梱リソースを備えた新しいエージェントスキルを作成する。新しいスキルを作成・記述・構築したいときに使用。Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

# Writing Skills

## Process

1. **要件を集める** — ユーザーに以下を確認:
   - スキルが対象とするタスク／ドメインは何か？
   - 具体的にどのユースケースを扱うべきか？
   - 実行可能スクリプトが必要か、指示だけで十分か？
   - 含めるべき参考資料はあるか？

2. **スキルを起案** — 以下を作成:
   - 簡潔な指示を入れた SKILL.md
   - 内容が 500 行を超えるなら追加の参考ファイル
   - 決定論的な操作が必要ならユーティリティスクリプト

3. **ユーザーとレビュー** — ドラフトを提示し以下を確認:
   - ユースケースを網羅しているか？
   - 不足や不明瞭な点はないか？
   - もっと詳しく／もっと簡潔にすべきセクションはあるか？

## Skill Structure

```
skill-name/
├── SKILL.md           # 主指示（必須）
├── REFERENCE.md       # 詳細ドキュメント（必要時）
├── EXAMPLES.md        # 使用例（必要時）
└── scripts/           # ユーティリティスクリプト（必要時）
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: 能力の簡潔な説明。Use when [具体的なトリガー]。
---

# Skill Name

## Quick start

[最小の動作例]

## Workflows

[複雑なタスク用のチェックリスト付きステップバイステップ手順]

## Advanced features

[別ファイルへのリンク: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

description は、どのスキルをロードするかを決めるときに **エージェントが見る唯一の情報**。システムプロンプト上で他のインストール済みスキルと並列に提示される。エージェントはこれら description を読み、ユーザーのリクエストに応じて適切なスキルを選ぶ。

**目標**: エージェントが以下を判別できる最小情報を与える:

1. このスキルが何の能力を提供するか
2. いつ／なぜ起動すべきか（具体的なキーワード、コンテキスト、ファイルタイプ）

**Format**:

- 最大 1024 文字
- 三人称で書く
- 第 1 文: 何をするか
- 第 2 文: "Use when [具体的なトリガー]"

**良い例**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**悪い例**:

```
Helps with documents.
```

悪い例ではエージェントはこのスキルを他のドキュメント系スキルと区別する手がかりがない。

## When to Add Scripts

ユーティリティスクリプトを追加するのは:

- 操作が決定論的（バリデーション、フォーマット）
- 同じコードが繰り返し生成されるはずのケース
- エラー処理を明示的にやる必要があるケース

スクリプトは生成コードに対して、トークンを節約し信頼性を上げる。

## When to Split Files

ファイルを分割するのは:

- SKILL.md が 100 行を超える
- 内容が別ドメイン（finance schemas vs sales schemas）に分かれる
- Advanced features がめったに必要にならない

## Review Checklist

ドラフト後の確認:

- [ ] description にトリガーが入っている（"Use when..."）
- [ ] SKILL.md が 100 行以内
- [ ] 時限的情報（time-sensitive）が入っていない
- [ ] 用語が一貫している
- [ ] 具体例が含まれている
- [ ] 参照は 1 階層まで
