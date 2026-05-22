---
name: matt-setup
description: AGENTS.md/CLAUDE.md に `## Agent skills` ブロック、そして `docs/agents/` を立ち上げて、エンジニアリング系スキル群にこのリポジトリの issue tracker（GitHub もしくはローカル markdown）、triage ラベル語彙、ドメインドキュメントの配置を教える。`to-issues`・`to-prd`・`triage`・`diagnose`・`tdd`・`improve-codebase-architecture`・`zoom-out` を初めて使う前、あるいは issue tracker / triage labels / domain docs についてのコンテキストが欠けているように見えるときに実行。Sets up an `## Agent skills` block in AGENTS.md/CLAUDE.md and `docs/agents/` so the engineering skills know this repo's issue tracker (GitHub or local markdown), triage label vocabulary, and domain doc layout. Run before first use of `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, or `zoom-out` — or if those skills appear to be missing context about the issue tracker, triage labels, or domain docs.
disable-model-invocation: true
---

# Setup Matt Pocock's Skills

エンジニアリング系スキルが前提とする、リポジトリ単位の設定を立ち上げる:

- **Issue tracker** — issue がどこに存在するか（既定は GitHub、ローカル markdown も最初からサポート）
- **Triage labels** — 5 つの正典 triage 役割に使う文字列
- **Domain docs** — `CONTEXT.md` と ADR がどこにあるか、それらを読むときの消費側ルール

これは決定論的スクリプトではなくプロンプト駆動のスキル。探索し、見つけたものを提示し、ユーザーと確認してから、書く。

## プロセス

### 1. 探索

現在のリポジトリの初期状態を理解するため、現状を観察する。あるものを読む。仮定しない:

- `git remote -v` と `.git/config` — これは GitHub repo か？ どれか？
- リポジトリルートの `AGENTS.md` と `CLAUDE.md` — どちらか存在するか？ どちらかにすでに `## Agent skills` セクションがあるか？
- リポジトリルートの `CONTEXT.md` と `CONTEXT-MAP.md`
- `docs/adr/` と `src/*/docs/adr/` ディレクトリ
- `docs/agents/` — このスキルの過去出力がすでにあるか？
- `.scratch/` — ローカル markdown 形式の issue tracker 慣習がすでに使われているサイン

### 2. 発見を提示し、尋ねる

何があり何が欠けているかを要約する。そして 3 つの判断を**1 つずつ**ユーザーに歩かせる — 1 セクション提示、ユーザーの答えを得る、次に移る。3 つを一度に投げない。

ユーザーがこれらの用語の意味を知らないと仮定する。各セクションは短い説明から始める（それは何か、なぜスキルがそれを必要とするか、別を選んだら何が変わるか）。それから選択肢と既定を示す。

**セクション A — Issue tracker.**

> 説明: 「issue tracker」はこのリポジトリの issue が存在する場所のこと。`to-issues`・`triage`・`to-prd`・`qa` といったスキルは tracker から読み、書く — `gh issue create` を呼ぶのか、`.scratch/` 配下に markdown ファイルを書くのか、あるいは別のワークフローに従うのか、知る必要がある。このリポジトリで実際に作業を追跡している場所を選ぶ。

既定の構え: これらのスキルは GitHub 向けに設計されている。`git remote` が GitHub を指していれば、それを提案する。`git remote` が GitLab を指していれば（`gitlab.com` か self-hosted ホスト）、GitLab を提案する。それ以外（あるいはユーザーが希望すれば）、以下を提示する:

- **GitHub** — issue はリポジトリの GitHub Issues に存在（`gh` CLI を使用）
- **GitLab** — issue はリポジトリの GitLab Issues に存在（[`glab`](https://gitlab.com/gitlab-org/cli) CLI を使用）
- **Local markdown** — issue はこのリポジトリの `.scratch/<feature>/` 配下のファイルとして存在（ソロプロジェクトやリモートのないリポジトリに良い）
- **Other**（Jira、Linear など）— ユーザーにワークフローを 1 段落で記述してもらう。スキルはそれを自由形式の散文として記録する

**セクション B — Triage label vocabulary.**

> 説明: `triage` スキルが入ってきた issue を処理するとき、state machine を進める — evaluation 待ち、reporter 待ち、AFK エージェントが拾える状態、人間向けの状態、won't fix。そのためには、ユーザーが*実際に設定している*文字列に一致するラベル（あるいは issue tracker の同等物）を適用する必要がある。リポジトリがすでに別のラベル名（例: `needs-triage` ではなく `bug:triage`）を使っているなら、ここでマップして、スキルが正しいラベルを適用して重複を作らないようにする。

5 つの正典役割:

- `needs-triage` — メンテナの評価が必要
- `needs-info` — reporter 待ち
- `ready-for-agent` — 完全に仕様化済み、AFK 対応可（人間のコンテキストなしでエージェントが拾える）
- `ready-for-human` — 人間による実装が必要
- `wontfix` — 対応しない

既定: 各役割の文字列は名前と同じ。上書きするものはあるかユーザーに尋ねる。issue tracker に既存ラベルがなければ既定で十分。

**セクション C — Domain docs.**

> 説明: スキルの一部（`improve-codebase-architecture`、`diagnose`、`tdd`）は `CONTEXT.md` ファイルを読んでプロジェクトのドメイン言語を学び、過去のアーキテクチャ判断は `docs/adr/` を読む。リポジトリにグローバル context が 1 つあるのか、複数あるのか（例: フロントとバックで context が分かれた monorepo）を知る必要がある — そうすれば正しい場所を見にいける。

レイアウトを確認する:

- **Single-context** — `CONTEXT.md` + `docs/adr/` がリポジトリルートに 1 セット。ほとんどのリポジトリはこれ。
- **Multi-context** — ルートに `CONTEXT-MAP.md` があり、context ごとの `CONTEXT.md` を指す（典型的には monorepo）。

### 3. 確認と編集

ユーザーに以下のドラフトを見せる:

- `CLAUDE.md` / `AGENTS.md` のどちらに追加する `## Agent skills` ブロックか（選択ルールは step 4）
- `docs/agents/issue-tracker.md`、`docs/agents/triage-labels.md`、`docs/agents/domain.md` の中身

書く前に編集させる。

### 4. 書き出し

**編集するファイルを選ぶ:**

- `CLAUDE.md` があれば、それを編集する。
- なければ `AGENTS.md` があれば、それを編集する。
- どちらもなければ、どちらを作るかユーザーに尋ねる — 勝手に決めない。

`CLAUDE.md` がすでにあるのに `AGENTS.md` を新規作成しない（逆も同様）— 常にすでにある方を編集する。

選んだファイルに `## Agent skills` ブロックがすでにあれば、重複を末尾に append するのではなくその中身を in-place で更新する。周囲のセクションへのユーザー編集を上書きしない。

ブロック:

```markdown
## Agent skills

### Issue tracker

[issue が追跡される場所の 1 行要約]。詳細は `docs/agents/issue-tracker.md`。

### Triage labels

[ラベル語彙の 1 行要約]。詳細は `docs/agents/triage-labels.md`。

### Domain docs

[レイアウトの 1 行要約 — "single-context" か "multi-context"]。詳細は `docs/agents/domain.md`。
```

それから、このスキルフォルダにあるシードテンプレートを出発点として 3 つの doc ファイルを書く:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — ラベルマッピング
- [domain.md](./domain.md) — ドメイン doc の消費側ルール + レイアウト

"Other" の issue tracker の場合は、ユーザーの記述を元に `docs/agents/issue-tracker.md` をゼロから書く。

### 5. 完了

セットアップが完了したこと、そしてこれからどのエンジニアリング系スキルがこれらのファイルから読むかをユーザーに伝える。`docs/agents/*.md` は後から直接編集できることを伝える — このスキルを再実行する必要があるのは issue tracker を切り替えたいときか、ゼロからやり直したいときだけ。
