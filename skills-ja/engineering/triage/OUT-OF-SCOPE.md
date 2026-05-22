# Out-of-Scope ナレッジベース

リポジトリの `.out-of-scope/` ディレクトリは、却下された機能要望の永続的な記録を保管する。役割は 2 つ:

1. **組織記憶** — Issue がクローズされたあとも、なぜ却下したかの理由が失われないようにする
2. **重複排除** — 過去の却下と一致する新規 Issue が来たら、再度議論し直す代わりに過去の判断を表面化する

## ディレクトリ構造

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

ファイルは Issue 単位ではなく**概念単位**で 1 つ。同じものを要望する複数の Issue は 1 ファイルにまとめる。

## ファイル形式

ファイルは緩く、読みやすい文体で書く — データベースのエントリよりも、短い設計ドキュメントに近い。段落、コードサンプル、例を使い、初見の読者にも理由が伝わるようにする。

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

### ファイル命名

概念を表す短い kebab-case を使う: `dark-mode.md`、`plugin-system.md`、`graphql-api.md`。ディレクトリを眺めただけで、ファイルを開かずに「何が却下されたか」が分かる粒度にする。

### 理由を書く

理由は中身のあるものでなければならない — 「やりたくない」ではなく**なぜ**を書く。良い理由は次のいずれかに言及する:

- プロジェクトのスコープや思想（「このプロジェクトは X に集中する。テーマ化は下流の関心事」）
- 技術的制約（「これに対応するには Y が必要だが、Z アーキテクチャと衝突する」）
- 戦略的判断（「B ではなく A を選んだ。理由は…」）

理由は耐久的でなければならない。一時的な事情（「今は忙しい」）は書かない — それは却下ではなく**延期**だ。

## いつ `.out-of-scope/` を見るか

トリアージ中（Step 1: コンテキスト収集）に `.out-of-scope/` のすべてのファイルを読む。新規 Issue を評価するときは:

- 既存の out-of-scope 概念と一致するかチェック
- マッチングはキーワードではなく**概念類似度**で行う — 「night theme」は `dark-mode.md` にマッチする
- マッチしたらメンテナに表面化する: 「これは `.out-of-scope/dark-mode.md` と似ています — 過去に [理由] で却下されました。今もそう感じますか？」

メンテナは次のいずれかを取れる:

- **確認** — 新規 Issue は既存ファイルの "Prior requests" リストに追加され、クローズされる
- **再考** — out-of-scope ファイルを削除または更新し、Issue は通常のトリアージへ進む
- **不一致** — 関連はするが別物なので、通常のトリアージへ進む

## いつ `.out-of-scope/` に書くか

**enhancement**（bug ではない）が `wontfix` として却下されたときだけ。流れ:

1. メンテナが機能要望をスコープ外と判断する
2. 既存の `.out-of-scope/` ファイルにマッチがあるか確認
3. ある: 新規 Issue を "Prior requests" リストに追記
4. ない: 概念名・判断・理由・最初の prior request を含む新規ファイルを作成
5. Issue にコメントを投稿し、判断の説明と `.out-of-scope/` ファイルへの言及を含める
6. `wontfix` ラベルで Issue をクローズ

## out-of-scope ファイルの更新・削除

メンテナが過去に却下した概念について気を変えた場合:

- `.out-of-scope/` のファイルを削除
- 過去の Issue を再オープンする必要はない — それらは歴史的記録
- 再考のきっかけとなった新規 Issue は通常のトリアージへ進む
