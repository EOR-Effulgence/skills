# Issue tracker: GitHub

このリポジトリの issue と PRD は GitHub issue として存在する。すべての操作に `gh` CLI を使う。

## 規約

- **issue を作る**: `gh issue create --title "..." --body "..."`。複数行の body は heredoc を使う。
- **issue を読む**: `gh issue view <number> --comments`。コメントは `jq` でフィルタし、ラベルも取得する。
- **issue 一覧**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`。適宜 `--label` と `--state` フィルタを付ける。
- **issue にコメント**: `gh issue comment <number> --body "..."`
- **ラベル付与 / 解除**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **クローズ**: `gh issue close <number> --comment "..."`

リポジトリは `git remote -v` から推測する — clone の中で実行すれば `gh` は自動でこれをやる。

## スキルが「issue tracker に publish せよ」と言ったら

GitHub issue を作る。

## スキルが「関連チケットを fetch せよ」と言ったら

`gh issue view <number> --comments` を実行する。
