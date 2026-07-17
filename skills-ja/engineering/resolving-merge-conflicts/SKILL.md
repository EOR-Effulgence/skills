---
name: resolving-merge-conflicts
description: "進行中の git merge/rebase conflict を解決したいときに使う。Use when you need to resolve an in-progress git merge/rebase conflict. 日本語トリガー例 / \"merge conflict を解決して\" \"rebase の衝突を直して\" / English / \"resolve this merge conflict\""
---

1. **merge/rebase の現在の state を確認する。** git history と conflict しているファイルをチェックする。

2. **各 conflict の一次情報を探す。** それぞれの変更がなぜ行われたのか、元の意図は何だったのかを深く理解する。commit message を読み、PR を確認し、元の issue/ticket を確認する。

3. **各 hunk を解決する。** 可能な限り両方の意図を保つ。両立できない場合は、この merge が掲げる目的に合う方を選び、trade-off をメモする。新しい振る舞いを**でっち上げてはならない**。常に解決すること。決して `--abort` するな。

4. プロジェクトの**自動チェック**を見つけて実行する。通常は typecheck、次に tests、次に format の順。merge が壊したものはすべて修正する。

5. **merge/rebase を完了する。** すべてを stage して commit する。rebase 中なら、すべての commit が rebase され終わるまで rebase プロセスを続ける。
