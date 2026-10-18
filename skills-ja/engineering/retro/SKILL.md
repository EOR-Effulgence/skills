---
name: retro
description: "coding のセッションを振り返る（retrospective）。Conduct a retrospective on a coding session. 日本語トリガー例 / \"振り返りをして\" \"このセッションの retro\" / English / \"run a retro\" \"retrospective on this session\""
disable-model-invocation: true
---

ユーザーは **retrospective** を求めている。今後の実行を良くするため、coding agent の **環境** への改善を提案する。

## ステップ

1. 文章のスタイルガイドとして、Skill tool を `writing-for-agents` で呼ぶ。

2. ユーザーが指定したセッションの一次情報を読む。このマシン上のセッションのログを探す必要があるかもしれない。ユーザーがセッションを指定しなければ、現在のセッションを対象にする。

3. 次のカテゴリで改善の候補を探す。

- **Navigation**: agent が正しいファイルを見つけるのはどれだけ楽だったか? ファイル間に隠れた依存関係は無いか? **navigation pointer** があれば楽になるか? _使う場面_: ある情報を見つけるのにセッションが長くかかったとき。
- **Automated checks**: agent が犯したエラーを捕まえられた自動チェックは無いか? lint、型、テスト、ファイルシステムの linter は? まず repo 自身のチェックのコマンド（`package.json` や build tool の `lint` / `check` スクリプト、CI の workflow）を読め。すでにあるのに配線されていない、あるいは黙って壊れているチェックこそが発見であって、作り直すことではない。**guardrail** の無い repo（lint / typecheck / test のコマンドを走らせる pre-commit hook も CI の job も無い）は、それ自体が発見だ: lint されていない repo は、中立な既定値ではなく、逃し続けている機会だ。_使う場面_: 自動チェックで捕まえられたミスを agent が犯したとき、または repo に guardrail がまったく無いとき。
- **Coding standards**: **reviewer agent** に強制させる新しいルールを与えるべきか? 既存のルールを削るか、明確にすべきか? まず違反を分類しろ: **機械的な** 違反（決まった構文のパターン、禁止された API、import の形、ファイルの置き場所のルール）には、決定的なチェックを当てる。それで終わりだ: repo 自身の linter の独自ルール、新しい pre-commit hook、新しい CI の job のうち、repo の言語と既存の guardrail で最も安く済むものを使う。ルールを書くより、チェックを作ることを既定にしろ。`CODING_STANDARDS.md` は、本当の **判断の問題**（ファイルをまたぐ一貫性、「周りのスタイルに合っている」、どんな guardrail でも代わりになれないもの）のために取っておけ。_使う場面_: reviewer agent がミスを捕まえ損ねたとき。
- **Global AGENTS.md**: coding standards（または自動チェック）へ移すべき steering の指示は無いか? _使う場面_: AGENTS.md ファイルが特に大きいとき。repo の中でも、ユーザーの global スコープでも。
- **Tool economy**: agent は、もっと効率化できる高コストな tool call をしなかったか? 特に token 効率の悪い独自のツール（CLI、MCP）は無いか? _使う場面_: agent が高コストな tool call をしたとき。
- **No-ops**: steering file の中で、agent の振る舞いを変えない指示を探す。_使う場面_: steering file が大きく扱いにくいとき。
- **Information access**: agent が情報にアクセスできる範囲を広げる機会を探す。dev server のログの tee、外部サービスへの読み取り専用のアクセスなど。_使う場面_: 決定的に重要な情報が agent から見えなかったとき。

4. これらの候補を、重大なものから順にユーザーに示す。

## リファレンス

### 実装と review

すべての作業は、実装と review の 2 段階を通ることを忘れるな。実装の agent は最も **context pressure** が大きい。探索、コードを書くこと、失敗のデバッグを担う。

review の agent は context pressure が最も小さい。diff を受け取るので探索は要らない。コードを書いたりデバッグしたりする必要もないことが多い。

つまり、coding standards を課すのは実装の agent ではなく、review の agent の役目だ。

### ファイル

repo の中のいくつかのファイルにアクセスできる:

- `CLAUDE.md` / `AGENTS.md`: この repo で作業するすべての agent の context window に送り込まれる。ごく控えめに、たいていは他のファイルへの **navigation pointer** のためだけに使え。
- `CODING_STANDARDS.md`: 実装ではなく review の間に読まれる。standards のファイルが 1,000 行を超えたら、docs フォルダへの **navigation pointer** を加える。
- Docs: docs は、他のファイルから指される参照用のファイルとして使う。新しく書く前に、既存の docs を探せ。
- Skills: skill は docs として（description が agent の context window に入るため）、またはユーザーが呼ぶコマンドとして使う。`writing-for-agents` skill の助言に従え。
