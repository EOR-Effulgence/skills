# Issue tracker: GitLab

このリポジトリの issue と PRD は GitLab issue として存在する。すべての操作に [`glab`](https://gitlab.com/gitlab-org/cli) CLI を使う。

## 規約

- **issue を作る**: `glab issue create --title "..." --description "..."`。複数行の description は heredoc を使う。`--description -` でエディタを開ける。
- **issue を読む**: `glab issue view <number> --comments`。機械可読出力には `-F json`。
- **issue 一覧**: `glab issue list -F json`。適宜 `--label` フィルタ。
- **issue にコメント**: `glab issue note <number> --message "..."`。GitLab はコメントを "note" と呼ぶ。
- **ラベル付与 / 解除**: `glab issue update <number> --label "..."` / `--unlabel "..."`。複数ラベルはカンマ区切り、またはフラグを繰り返す。
- **クローズ**: `glab issue close <number>`。`glab issue close` は終了コメントを受け付けないので、`glab issue note <number> --message "..."` で説明を先に投稿してからクローズする。
- **Merge request**: GitLab は PR を "merge request" と呼ぶ。`glab mr create`、`glab mr view`、`glab mr note` などを使う — `gh pr ...` と同じ形で、`pr` の位置に `mr`、`comment`/`--body` の位置に `note`/`--message`。

リポジトリは `git remote -v` から推測する — clone の中で実行すれば `glab` は自動でこれをやる。

## スキルが「issue tracker に publish せよ」と言ったら

GitLab issue を作る。

## スキルが「関連チケットを fetch せよ」と言ったら

`glab issue view <number> --comments` を実行する。
