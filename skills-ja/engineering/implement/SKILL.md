---
name: implement
description: "spec や ticket 群にもとづいて作業を実装する。Implement a piece of work based on a spec or set of tickets. 日本語トリガー例 / \"これを実装して\" \"spec から実装\" \"ticket を実装\" / English / \"implement this\" \"build from tickets\""
disable-model-invocation: true
---

ユーザーが spec または ticket 群で説明した作業を実装する。

合意済みの seam では、可能な限り /tdd を使う。

typecheck をこまめに実行し、単一の test ファイルもこまめに実行し、full test suite は最後に一度だけ実行する。

完了したら、/code-review を使って作業をレビューする。

作業を current branch に commit する。
