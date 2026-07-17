# Out-of-Scope Knowledge Base

リポジトリ内の `.out-of-scope/` ディレクトリは、却下された機能リクエストの永続的な記録を保存する。目的は 2 つ:

1. **組織的記憶（institutional memory）** — なぜその機能が却下されたか。Issue が close されても理由が失われないようにする
2. **重複排除（deduplication）** — 過去の却下に一致する新しい Issue が来たとき、スキルは再議論せずに以前の決定を表に出せる

## Directory structure

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

**概念（concept）** ごとに 1 ファイルであって、Issue ごとではない。同じものを要求する複数の Issue は 1 ファイルにまとめる。

## File format

ファイルはくだけた読みやすいスタイルで書く — データベースのエントリというより短い設計ドキュメントに近い。段落・コードサンプル・例を使い、初めて目にする人にも理由が明快で有用になるようにする。

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

```ts
// The current ThemeConfig interface is not designed for runtime switching:
interface ThemeConfig {
  colors: ColorPalette; // single palette, resolved at build time
  fonts: FontStack;
}
```

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
```

### Naming the file

概念には短く説明的な kebab-case 名を使う: `dark-mode.md`、`plugin-system.md`、`graphql-api.md`。ディレクトリを眺める人がファイルを開かずとも何が却下されたか分かる程度に識別しやすい名前にする。

### Writing the reason

理由は実質的でなければならない — 「これは要らない」ではなく、なぜかを書く。良い理由が参照するもの:

- プロジェクトのスコープや哲学（"This project focuses on X; theming is a downstream concern"）
- 技術的制約（"Supporting this would require Y, which conflicts with our Z architecture"）
- 戦略的判断（"We chose to use A instead of B because..."）

理由は長持ちするものであるべきだ。一時的な状況（"we're too busy right now"）への言及は避ける — それは本当の却下ではなく、先送りだ。

## When to check `.out-of-scope/`

トリアージ中（Step 1: Gather context）、`.out-of-scope/` の全ファイルを読む。新しい Issue を評価するとき:

- リクエストが既存の out-of-scope 概念に一致するか確認する
- 一致はキーワードではなく概念の類似で判断する — "night theme" は `dark-mode.md` に一致する
- 一致があればメンテナに表に出す: "This is similar to `.out-of-scope/dark-mode.md` — we rejected this before because [reason]. Do you still feel the same way?"

メンテナは次のいずれかを選べる:

- **Confirm** — 新しい Issue が既存ファイルの "Prior requests" リストに追加され、close される
- **Reconsider** — out-of-scope ファイルが削除または更新され、Issue は通常のトリアージへ進む
- **Disagree** — Issue 同士は関連するが別物であり、通常のトリアージへ進む

## When to write to `.out-of-scope/`

**enhancement**（bug ではない）が `wontfix` として *却下* されたときだけだ。これは enhancement PR にも Issue とまったく同様に適用される — 却下された PR はここに記録され、同じリクエストが新しいコードとして戻ってこないようにする。

**実装済み（already implemented）** を理由に `wontfix` として close する場合は、ここに**書かない**。それは作られた機能であって却下されたものではない; 記録すれば dedup チェックが偽の却下で汚染される。代わりに、close コメントでその機能が既にどこにあるかを示す。

流れ:

1. メンテナが機能リクエストを out of scope と決める
2. 一致する `.out-of-scope/` ファイルが既に存在するか確認する
3. あれば: 新しい Issue を "Prior requests" リストに追記する
4. なければ: 概念名・決定・理由・最初の prior request を含む新しいファイルを作る
5. Issue にコメントを投稿し、決定を説明して `.out-of-scope/` ファイルに言及する
6. `wontfix` label で Issue を close する

## Updating or removing out-of-scope files

メンテナが過去に却下した概念について考えを変えた場合:

- `.out-of-scope/` ファイルを削除する
- スキルは古い Issue を再オープンする必要はない — それらは歴史的記録だ
- 再考のきっかけとなった新しい Issue は通常のトリアージへ進む
