---
name: implement-spec
description: "/to-spec と /to-tickets の成果をコードとして実装する。Implement the result of /to-spec and /to-tickets in code. 日本語トリガー例 / \"spec 全体を実装して\" \"ticket をまとめて実装\" / English / \"implement the whole spec\" \"implement all tickets\""
disable-model-invocation: true
---

spec が渡されている。この spec には、spec の実装方法を記した ticket が紐づいているはずだ。

issue tracker は事前に渡されているはずだ。渡されていなければ、ユーザーに `/setup-matt-pocock-skills` の実行を促せ。

目標は、spec 全体を 1 本の **integration branch** の上に実装し、すべての ticket を issue tracker が作業を閉じる方法で解決することだ。

ticket はステップのリストではない。ticket 同士に blocking 関係を持つ **task graph** だ。つまり、着手できる ticket の **frontier** が常に存在する。

subagent とのやり取りは最小限にしろ。主に **context pointer** でやり取りする: spec、ticket、research のメモ、過去の commit を指す。pointer でたどれる情報を重複させるな。

**implementer subagent** は、並行度を最大にするため、可能な限り background で走らせろ。

## ステップ

1. spec と ticket を読み、task graph を把握する。

2. （任意）**exploration subagent** を使い、ticket が必要とする探索（関係するコードベースのファイルや外部の文書）を行う。exploration subagent がファイルを保存できるようにしておけ。メモは markdown で repo の外のディレクトリに保存させ、以降のすべての subagent から読めるようにする。こうすると **implementer subagent** は探索ではなく実装に集中できる。

3. integration branch を作る。issue tracker が PR で作業を閉じる場合、またはユーザーが求めた場合は、ステップ 5 の最初の merge のあとに draft PR を開く（main より先に進んだ commit が無い branch では PR を開けない）。PR は spec と ticket を閉じるものとして記す。

4. **implementer subagent** で各 ticket を実装する。それぞれ専用の worktree と branch で動かす。各 implementer subagent は:
   - 始める前に、自分の worktree が integration branch を元にしていることを確かめ、そうでなければ integration branch に reset する
   - Skill tool を `tdd` で呼んで ticket を作る
   - 完了を報告する前に、integration branch の先端を自分の branch に merge する

5. **implementer subagent** が完了したら、**merger subagent** でその作業を integration branch に merge する。

6. それによって着手できる ticket の **frontier** が変わったら、新しい ticket に取り組む **implementer subagent** をさらに起動する。こうして並行度を最大にする。

7. すべての ticket が完了したら、integration branch に対して Skill tool を `code-review` で呼ぶ。code review が挙げた問題は、1 つの **implementer subagent** ですべて直す。

8. draft PR があれば、review 可能な状態にする。無ければ、各 ticket を issue tracker が作業を閉じる方法で解決し、integration branch を報告する。

9. すべての **implementer subagent** の worktree を片付ける。
