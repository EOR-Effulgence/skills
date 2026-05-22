# Issue tracker: Local Markdown

このリポジトリの issue と PRD は `.scratch/` 配下の markdown ファイルとして存在する。

## 規約

- 機能ごとに 1 ディレクトリ: `.scratch/<feature-slug>/`
- PRD は `.scratch/<feature-slug>/PRD.md`
- 実装 issue は `.scratch/<feature-slug>/issues/<NN>-<slug>.md`、`01` から番号付け
- triage 状態は各 issue ファイル先頭付近の `Status:` 行に記録する（役割文字列は `triage-labels.md` 参照）
- コメントと会話履歴は `## Comments` 見出しの下、ファイル末尾に追記する

## スキルが「issue tracker に publish せよ」と言ったら

`.scratch/<feature-slug>/` 配下に新ファイルを作る（必要ならディレクトリも作る）。

## スキルが「関連チケットを fetch せよ」と言ったら

参照されているパスのファイルを読む。ユーザーは通常パスか issue 番号を直接渡してくる。
