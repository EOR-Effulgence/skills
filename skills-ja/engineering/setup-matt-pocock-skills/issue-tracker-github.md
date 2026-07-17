# Issue tracker: GitHub

このリポジトリの issue と PRD は GitHub issue として存在する。すべての操作に `gh` CLI を使う。

## 規約

- **issue を作る**: `gh issue create --title "..." --body "..."`。複数行の body は heredoc を使う。
- **issue を読む**: `gh issue view <number> --comments`。コメントは `jq` でフィルタし、ラベルも取得する。
- **issue 一覧**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`。適宜 `--label` と `--state` フィルタを付ける。
- **issue にコメント**: `gh issue comment <number> --body "..."`
- **ラベル付与 / 解除**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **クローズ**: `gh issue close <number> --comment "..."`

リポジトリは `git remote -v` から推測する — clone の中で実行すれば `gh` が自動でこれをやる。

## Pull request を triage の surface として

**PRs as a request surface: no.** _(このリポジトリが外部 PR を機能要望として扱うなら `yes` にする。`/triage` がこのフラグを読む。)_

`yes` に設定した場合、PR は issue と同じラベルと状態を通り、`gh pr` の同等物を使う:

- **PR を読む**: `gh pr view <number> --comments`、差分は `gh pr diff <number>`。
- **triage 対象の外部 PR を一覧する**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` の後、`authorAssociation` が `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR`、`NONE` のものだけ残す（`OWNER`/`MEMBER`/`COLLABORATOR` は落とす）。
- **コメント / ラベル / クローズ**: `gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub は issue と PR で番号空間を 1 つ共有するので、素の `#42` はどちらの可能性もある — `gh pr view 42` で解決し、`gh issue view 42` にフォールバックする。

## スキルが「issue tracker に publish せよ」と言ったら

GitHub issue を作る。

## スキルが「関連チケットを fetch せよ」と言ったら

`gh issue view <number> --comments` を実行する。

## Wayfinding 操作

`/wayfinder` が使う。**map** は 1 つの issue で、**child** issue をチケットとして持つ。

- **Map**: `wayfinder:map` ラベルを付けた 1 つの issue。Notes / Decisions-so-far / Fog の body を保持する。`gh issue create --label wayfinder:map`。
- **Child ticket**: GitHub の sub-issue として map にリンクされた issue（sub-issues エンドポイントへの `gh api`）。sub-issue が有効でない場合は、map の body のタスクリストに child を追加し、child の body の先頭に `Part of #<map>` を置く。ラベルは `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。claim されると、チケットは駆動している dev にアサインされる。
- **Blocking**: GitHub の **native issue dependencies** — canonical で UI 上でも見える表現。`gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` でエッジを追加する。ここで `<blocker-db-id>` は blocker の数値の **database id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`。`#number` でも `node_id` でもない）。GitHub は `issue_dependencies_summary.blocked_by`（open な blocker のみ — ライブなゲート）を報告する。dependencies が使えない場合は、child の body の先頭の `Blocked by: #<n>, #<n>` 行にフォールバックする。すべての blocker が close されればチケットは unblock される。
- **Frontier query**: map の open な child を一覧し（`gh issue list --state open`、map の sub-issues / タスクリストにスコープする）、open な blocker（`issue_dependencies_summary.blocked_by > 0`、または `Blocked by` 行の open な issue）を持つものや assignee のあるものを落とす。map の順序で最初のものが勝つ。
- **Claim**: `gh issue edit <n> --add-assignee @me` — セッション最初の書き込み。
- **Resolve**: `gh issue comment <n> --body "<answer>"`、次に `gh issue close <n>`、次に map の Decisions-so-far に context ポインタ（gist + リンク）を追記する。
