---
name: setup-matt-pocock-skills
description: このリポジトリを engineering skills 向けに設定する — issue tracker、triage ラベルの語彙、domain doc のレイアウトをセットアップする。他の engineering skills を初めて使う前に一度だけ実行する。Configure this repo for the engineering skills — set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills. 日本語トリガー例 / "engineering skills をセットアップして" "issue tracker を設定して" / English / "set up the engineering skills"
disable-model-invocation: true
---

# Setup Matt Pocock's Skills

engineering skills が前提とするリポジトリ単位の設定を scaffold する:

- **Issue tracker** — issue がどこに存在するか（デフォルトは GitHub。ローカル markdown も標準でサポート）
- **Triage labels** — 5 つの canonical な triage ロールに使う文字列
- **Domain docs** — `CONTEXT.md` と ADR がどこに存在するか、およびそれらを読むための consumer ルール

これは prompt 駆動の skill であり、決定論的なスクリプトではない。探索し、見つけたものを提示し、ユーザーに確認を取ってから書き込む。

## Process

### 1. 探索

現在のリポジトリを見て、開始時点の状態を把握する。存在するものを読む。決めつけるな:

- `git remote -v` と `.git/config` — これは GitHub リポジトリか？ どのリポジトリか？
- リポジトリルートの `AGENTS.md` と `CLAUDE.md` — どちらかが存在するか？ どちらかに既に `## Agent skills` セクションがあるか？
- リポジトリルートの `CONTEXT.md` と `CONTEXT-MAP.md`
- `docs/adr/` および任意の `src/*/docs/adr/` ディレクトリ
- `docs/agents/` — この skill の過去の出力が既に存在するか？
- `.scratch/` — ローカル markdown の issue tracker 規約が既に使われている兆候
- `triage` skill はインストール済みか？（この skill と同じ階層にある `triage` skill フォルダ、または利用可能な skills 内の `triage`。）これで Section B を実行するかどうかが決まる。
- Monorepo のシグナル — `pnpm-workspace.yaml`、`package.json` の `workspaces` フィールド、または独自の `src/` を持つ、中身の入った `packages/*`。本当に大規模なマルチパッケージリポジトリにのみ存在する。これらが無ければ single-context であり、ほぼすべてのリポジトリがそうだ。

### 2. 発見を提示して尋ねる

存在するものと欠けているものを要約する。次にセクションを順に扱う — 1 セクション、1 回答、次へ。

各セクションは推奨回答を先頭に置き、ユーザーが一言で受け入れられるようにする。選択が本当に分岐するときだけ 1 行の説明を添える。探索で既に決着している場合はセクションごと飛ばす（`triage` が未インストールなら Section B、monorepo が無ければ Section C）。

**Section A — Issue tracker.**

> 説明: 「issue tracker」とはこのリポジトリの issue が存在する場所だ。`to-tickets`、`triage`、`to-spec`、`qa` のような skills はそこから読み書きする — `gh issue create` を呼ぶのか、`.scratch/` 配下に markdown ファイルを書くのか、あるいは別のワークフローに従うのかを知る必要がある。このリポジトリで実際に作業を追跡している場所を選ぶ。

デフォルトの姿勢: これらの skills は GitHub 向けに設計された。`git remote` が GitHub を指していればそれを提案する。`git remote` が GitLab（`gitlab.com` またはセルフホストのホスト）を指していれば GitLab を提案する。それ以外（またはユーザーが好む場合）は次を提示する:

- **GitHub** — issue はリポジトリの GitHub Issues に存在する（`gh` CLI を使う）
- **GitLab** — issue はリポジトリの GitLab Issues に存在する（[`glab`](https://gitlab.com/gitlab-org/cli) CLI を使う）
- **Local markdown** — issue はこのリポジトリの `.scratch/<feature>/` 配下にファイルとして存在する（ソロプロジェクトや remote の無いリポジトリに向く）
- **Other**（Jira、Linear など）— ユーザーにワークフローを 1 段落で説明してもらう。skill はそれを自由記述の散文として記録する

選択を `docs/agents/issue-tracker.md` に記録する。GitHub と GitLab のテンプレートは「PRs as a request surface」フラグを持ち、デフォルトは **off** だ — off のまま放置し、話題にも出すな。外部 PR を triage キューに入れたいユーザーは後でファイル内のフラグを切り替えられる。

**Section B — Triage label vocabulary.** `triage` skill がインストールされていなければ（探索で分かる）このセクションはまるごと飛ばす — 未インストールの skill にラベルは要らない。

インストールされている場合は、質問を 1 つだけする:

> デフォルトの triage ラベルをそのまま使うか？（推奨: **yes**）

デフォルトは 5 つの canonical なロールで、各ラベル文字列はその名前と等しい: `needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`。**yes** ならそのまま書く。ユーザーが no と言った場合のみ — 通常はトラッカーが既に別名を使っているため（例: `needs-triage` に対して `bug:triage`）— override を集め、`triage` が重複を作らず既存のラベルを適用するようにする。

**Section C — Domain docs.** デフォルトは **single-context** — リポジトリルートに `CONTEXT.md` 1 つ + `docs/adr/`。これはほぼすべてのリポジトリに合う。尋ねずに書く。

**multi-context** — ルートの `CONTEXT-MAP.md` が context ごとの `CONTEXT.md` ファイルを指す — を提示するのは、探索で monorepo のシグナルを見つけたときだけ。その場合はどのレイアウトを望むか確認する。

### 3. 確認して編集する

ユーザーに次のドラフトを見せる:

- `CLAUDE.md` / `AGENTS.md` のうち編集対象に追加する `## Agent skills` ブロック（選定ルールは step 4 参照）
- `docs/agents/issue-tracker.md`、`docs/agents/domain.md`、`docs/agents/triage-labels.md` の内容（最後の 1 つは `triage` がインストール済みのときのみ）

書き込む前に編集させる。

### 4. 書き込む

**編集するファイルを選ぶ:**

- `CLAUDE.md` が存在すればそれを編集する。
- 無ければ `AGENTS.md` が存在すればそれを編集する。
- どちらも無ければ、どちらを作成するかユーザーに尋ねる — こちらで決めるな。

`CLAUDE.md` が既にあるときに `AGENTS.md` を作成する（あるいはその逆）ことは決してするな — 既にある方を常に編集する。

選んだファイルに `## Agent skills` ブロックが既に存在する場合は、重複を append するのではなくその内容を in-place で更新する。周囲のセクションへのユーザーの編集を上書きするな。

ブロック:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

`### Triage labels` サブブロックを含め、`docs/agents/triage-labels.md` を書くのは、`triage` がインストール済みで Section B を実行したときのみ。そうでなければ両方とも省く。

次に、この skill フォルダ内の seed テンプレートを出発点として docs ファイルを書く:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub の issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab の issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — ローカル markdown の issue tracker
- [triage-labels.md](./triage-labels.md) — ラベルマッピング（`triage` がインストール済みのときのみ）
- [domain.md](./domain.md) — domain doc の consumer ルール + レイアウト

「other」の issue tracker の場合は、ユーザーの説明を使って `docs/agents/issue-tracker.md` をゼロから書く。

### 5. 完了

セットアップが完了したこと、そしてどの engineering skills がこれらのファイルから読むようになるかをユーザーに伝える。後から `docs/agents/*.md` を直接編集できること、この skill の再実行が必要なのは issue tracker を切り替えたいときやゼロからやり直したいときだけであることも伝える。
