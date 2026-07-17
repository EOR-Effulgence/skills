# Issue tracker: GitLab

このリポジトリの issue と PRD は GitLab issue として存在する。すべての操作に [`glab`](https://gitlab.com/gitlab-org/cli) CLI を使う。

## 規約

- **issue を作る**: `glab issue create --title "..." --description "..."`。複数行の description は heredoc を使う。`--description -` でエディタを開ける。
- **issue を読む**: `glab issue view <number> --comments`。機械可読出力には `-F json`。
- **issue 一覧**: `glab issue list -F json`。適宜 `--label` フィルタ。
- **issue にコメント**: `glab issue note <number> --message "..."`。GitLab はコメントを "note" と呼ぶ。
- **ラベル付与 / 解除**: `glab issue update <number> --label "..."` / `--unlabel "..."`。複数ラベルはカンマ区切り、またはフラグを繰り返す。
- **クローズ**: `glab issue close <number>`。`glab issue close` は終了コメントを受け付けないので、`glab issue note <number> --message "..."` で説明を先に投稿してからクローズする。
- **Merge request**: GitLab は PR を "merge request" と呼ぶ。`glab mr create`、`glab mr view`、`glab mr note` などを使う — `gh pr ...` と同じ形で、`pr` の位置に `mr`、`comment`/`--body` の位置に `note`/`--message` を置く。

リポジトリは `git remote -v` から推測する — clone の中で実行すれば `glab` が自動でこれをやる。

## Merge request を triage の surface として

**MRs as a request surface: no.** _(このリポジトリが外部の merge request を機能要望として扱うなら `yes` にする。`/triage` がこのフラグを読む。)_

`yes` に設定した場合、MR は issue と同じラベルと状態を通り、`glab mr` の同等物を使う:

- **MR を読む**: `glab mr view <number> --comments`、差分は `glab mr diff <number>`。
- **triage 対象の外部 MR を一覧する**: `glab mr list -F json` の後、author がプロジェクトの member/owner でない MR だけ残す（maintainer の作業中のものではなく、contributor の MR）。
- **コメント / ラベル / クローズ**: `glab mr note`、`glab mr update --label`/`--unlabel`、`glab mr close`。

GitHub と違い、GitLab は issue と MR を別々に番号付けするので、どちらの surface を maintainer が指しているか分かれば `#42` は一意だ。

## スキルが「issue tracker に publish せよ」と言ったら

GitLab issue を作る。

## スキルが「関連チケットを fetch せよ」と言ったら

`glab issue view <number> --comments` を実行する。

## Wayfinding 操作

`/wayfinder` が使う。**map** は 1 つの issue で、**child** issue をチケットとして持つ。

- **Map**: `wayfinder:map` ラベルを付けた 1 つの issue。Notes / Decisions-so-far / Fog の body を保持する。`glab issue create --label wayfinder:map`。（native epic を持つ GitLab のティアでは、代わりに epic が map を保持してもよい。ラベル付き issue はどこでも動く。）
- **Child ticket**: description の先頭に `Part of #<map>` を持ち、`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）ラベルを持つ issue。claim されると、チケットは駆動している dev にアサインされる。
- **Blocking**: GitLab の **native blocking link** — canonical で UI 上でも見える表現。`/blocked_by #<n>` クイックアクションを note として投稿して追加する（`glab issue note <child> --message "/blocked_by #<blocker>"`）。native blocking link は Premium/Ultimate の機能だ。free ティア（または利用不可の場合）は、description の先頭の `Blocked by: #<n>, #<n>` 行にフォールバックする。すべての blocker が close されればチケットは unblock される。
- **Frontier query**: `glab issue list -F json` を map の child にスコープし、open な blocker を持つもの — open な issue への native な `blocked_by` link（`glab api projects/:id/issues/:iid/links`）、または `Blocked by` 行の open な issue — や assignee のあるものを落とす。map の順序で最初のものが勝つ。
- **Claim**: `glab issue update <n> --assignee @me` — セッション最初の書き込み。
- **Resolve**: `glab issue note <n> --message "<answer>"`、次に `glab issue close <n>`、次に map の Decisions-so-far に context ポインタ（gist + リンク）を追記する。
