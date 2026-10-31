# Issue tracker: GitHub

このリポジトリの issue と spec は GitHub issue として存在する。すべての操作に `gh` CLI を使う。

## 規約

- **issue を作る**: `gh issue create --title "..." --body "..."`。複数行の body は heredoc を使う。
- **issue を読む**: `gh issue view <number> --json number,title,body,labels,comments`。
- **issue を親の sub-issue にする**: `gh issue create --parent <parent> ...`、または作成後に `gh issue edit <parent> --add-sub-issue <child>`（`gh` 2.94+）。古い `gh` では `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>`（下の **Blocking** と同じく database id）。sub-issue が無い場合は、child の body の先頭に `Part of #<parent>` を置く。
- **Blocking**: GitHub の **native issue dependencies**（canonical で UI 上でも見える表現）。`gh issue create --blocked-by <n>,<n> ...` または `gh issue edit <child> --add-blocked-by <blocker>`（`gh` 2.94+）でエッジを追加する。古い `gh` では `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`。ここで `<blocker-db-id>` は blocker の数値の **database id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`。`#number` でも `node_id` でもない）。dependencies が使えない場合は、child の body の先頭の `Blocked by: #<n>, #<n>` 行にフォールバックする。すべての blocker が close されればチケットは unblock される。
- **open な blocker を数える**: `gh api repos/<owner>/<repo>/issues/<n> --jq .issue_dependencies_summary.blocked_by`（open な blocker のみ。0 なら着手できる）。`gh issue view <n> --json blockedBy` は close 済みの blocker も列挙するので、`--jq '[.blockedBy.nodes[] | select(.state == "OPEN")] | length'` で絞り込む。
- **issue 一覧**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`。適宜 `--label` と `--state` フィルタを付ける。
- **issue にコメント**: `gh issue comment <number> --body "..."`
- **ラベル付与 / 解除**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **クローズ**: 説明を `gh issue comment <number> --body "..."` で投稿し、その後 `gh issue close <number>`。すでに close された issue に対しては、`gh issue close --comment` はコメントを捨てたうえで exit 0 を返す。

リポジトリは `git remote -v` から推測する。clone の中で実行すれば `gh` が自動でこれをやる。

issue はユーザー自身の repo にだけ起票しろ。ユーザーが所有者でない限り、`mattpocock/skills`（これらの skill の出どころの repo）には決して起票するな。fork の中では `gh` が upstream の親 repo を既定にすることがあるので、セッションで最初に `gh issue create` を実行する前に `gh repo view --json nameWithOwner` で対象を確かめ、ユーザーの repo でなければユーザーに確認しろ。

## Pull request を triage の surface として

**PRs as a request surface: no.** _(このリポジトリが外部 PR を機能要望として扱うなら `yes` にする。`/triage` がこのフラグを読む。)_

`yes` に設定した場合、PR は issue と同じラベルと状態を通り、`gh pr` の同等物を使う:

- **PR を読む**: `gh pr view <number>`、次に `gh pr view <number> --comments`（TTY でないとき、`--comments` は body を出さずコメントだけを出力する）、差分は `gh pr diff <number>`。
- **triage 対象の外部 PR を一覧する**: `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`。
- **コメント / ラベル / クローズ**: `gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub は issue と PR で番号空間を 1 つ共有するので、素の `#42` はどちらの可能性もある。`gh pr view 42` で解決し、`gh issue view 42` にフォールバックする。

## skill が「issue tracker に publish せよ」と言ったら

GitHub issue を作る。

## skill が「関連チケットを fetch せよ」と言ったら

上の **issue を読む** と同じ方法で読む。

## Wayfinding 操作

`/wayfinder` が使う。**map** は 1 つの issue で、**child** issue をチケットとして持つ。

- **Map**: `wayfinder:map` ラベルを付けた 1 つの issue。Notes / Decisions-so-far / Fog の body を保持する。`gh issue create --label wayfinder:map`。
- **Child ticket**: GitHub の sub-issue として map にリンクされた issue（**issue を親の sub-issue にする** を参照）。sub-issue が有効でない場合は、map の body のタスクリストに child を追加し、child の body の先頭に `Part of #<map>` を置く。ラベルは `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。claim されると、チケットは駆動している dev にアサインされる。
- **Blocking**: 規約の **Blocking** を参照。
- **Frontier query**: map の open な child を一覧し（`gh issue list --state open`、map の sub-issues / タスクリストにスコープする）、open な blocker（**open な blocker を数える** を参照、または `Blocked by` 行の open な issue）を持つものや assignee のあるものを落とす。map の順序で最初のものが勝つ。
- **Claim**: `gh issue edit <n> --add-assignee @me`。セッション最初の書き込み。
- **Resolve**: `gh issue comment <n> --body "<answer>"`、次に `gh issue close <n>`、次に map の Decisions-so-far に context ポインタ（gist + リンク）を追記する。
