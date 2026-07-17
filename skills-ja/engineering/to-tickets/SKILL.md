---
name: to-tickets
description: 計画・仕様・現在の会話を、それぞれが自分の blocking edges を宣言する tracer-bullet ticket 群に分割し、設定済みの tracker に公開する — ローカルでは ticket ごとに 1 ファイルへ edge をテキストで、実際の tracker ではネイティブな blocking link で。Break a plan, spec, or conversation into tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker. 日本語トリガー例 / "計画を ticket に分割して" "実装チケットを起票して" "作業を issue に分解して" / English / "convert plan into tickets" "break down work into issues"
disable-model-invocation: true
---

# To Tickets

計画・仕様・会話を **ticket** 群 — それぞれが自分を **block** する ticket を宣言する tracer-bullet vertical slice — に分割する。

issue tracker と triage ラベルの語彙は事前に提示されているはずだ — もし無ければ `/setup-matt-pocock-skills` を走らせる。

## Process

### 1. コンテキストを集める

すでに会話コンテキストに入っているものを土台に作業する。ユーザーが引数として参照（仕様のパス、issue 番号や URL）を渡してきたら、それを取得して本文とコメントを全部読む。

### 2. コードベースを探索（任意）

まだコードベースを探索していなければ、コードの現状を理解するために探索する。ticket のタイトルと説明はプロジェクトの domain glossary の語彙を使い、触る領域の ADR を尊重する。

実装を楽にするために、コードを prefactor する機会を探す。"Make the change easy, then make the easy change."

### 3. 垂直スライスを起案

作業を **tracer bullet** ticket 群に分解する。

<vertical-slice-rules>

- 各スライスは、狭くても全レイヤ（schema・API・UI・tests）を端から端まで貫く COMPLETE なパスを切る — 垂直であり、ひとつのレイヤだけの水平スライスにしない
- 完了したスライスは単体でデモまたは検証ができる
- 各スライスは 1 つの新鮮なコンテキストウィンドウに収まるサイズにする
- prefactoring があるなら先に済ませる

</vertical-slice-rules>

各 ticket に **blocking edges** — それが着手できる前に完了していなければならない他の ticket — を与える。ブロッカーが無い ticket はすぐに着手できる。

**wide refactor は vertical slicing の例外だ。** **wide refactor** とは、1 つの機械的な変更 — カラムのリネーム、共有シンボルの再型付け — でありながら、その **blast radius** がコードベース全体に扇状に広がるものを指す。単一の編集が数千の call sites を一斉に壊し、どんな vertical slice も green で着地できない。これを tracer bullet に押し込もうとするな。**expand–contract** として順序立てる。まず expand: 何も壊さないよう、古い形の隣に新しい形を足す。次に call sites を blast radius でサイズ決めしたバッチ（パッケージ単位、ディレクトリ単位）で移行する。各バッチは expand によってブロックされる個別の ticket とし、古い形がまだ存在するのでバッチからバッチへ CI を green に保つ。最後に contract: どの呼び出し元も残っていなくなったら古い形を削除する。これは移行バッチすべてによってブロックされる ticket とする。バッチ単体でも green を保てない場合は、順序はそのままに、全バッチがブロックする最終の integrate-and-verify ticket をブロックする形で共有の統合ブランチを持たせる — green はそこでのみ約束される。

### 4. ユーザーに確認する

提案する分解を番号付きリストで提示する。各 ticket について以下を示す:

- **Title**: 短く説明的な名前
- **Blocked by**: 先に完了させるべき他の ticket（あれば）
- **What it delivers**: この ticket が動かす端から端までのふるまい

ユーザーに問う:

- 粒度は適切か？（粗すぎる / 細かすぎる）
- blocking edges は正しいか — 各 ticket は本当にそれをゲートする ticket にだけ依存しているか？
- マージや更なる分割をすべき ticket はあるか？

ユーザーが分解を承認するまで反復する。

### 5. ticket を設定済みの tracker に公開する

承認された ticket を公開する。**どう**公開するかは `/setup-matt-pocock-skills` が設定した tracker による — ticket 自体はどちらでも同じで、blocking edges の形だけが変わる:

- **ローカルファイル** → ticket ごとに 1 ファイルを `.scratch/<feature-slug>/issues/<NN>-<slug>.md` の下に書く。依存順（ブロッカーが先）に `01` から採番する。各ファイルの「Blocked by」に依存する番号/タイトルを列挙する。下記の ticket ごとのファイルテンプレートを使う — 1 ファイルにつき 1 ticket、決して 1 つの結合ファイルにしない。
- **実際の issue tracker（GitHub、Linear、…）** → 各 ticket の blocking edges が実在の識別子を参照できるよう、依存順（ブロッカーが先）に ticket ごとに 1 issue を公開する。ネイティブな blocking / sub-issue 関係があればそれを使い、なければ各 ticket の「Blocked by」にブロックする issue を設定する。指示がない限り `ready-for-agent` triage ラベルを付ける — これらの ticket は構成上エージェントが着手可能だ。

**frontier** を進める: ブロッカーがすべて完了している ticket。純粋に線形なチェーンなら上から下へという意味だ。

親 issue を close したり変更したりしてはいけない。

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** この ticket が動かす端から端までのふるまいを、ユーザーの視点で — レイヤごとの実装リストではなく。

**Blocked by:** この ticket をゲートする ticket の番号/タイトル、または "None — can start immediately"。

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

tracker 上の親 issue への参照（元資料が既存 issue だった場合のみ。そうでなければこのセクションは省略）。

## What to build

この ticket が動かす端から端までのふるまいを、ユーザーの視点で — レイヤごとの実装ではなく。

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- ブロックしている各 ticket への参照、または "None — can start immediately"。

</issue-template>

どちらの形式でも、具体的なファイルパスやコードスニペットは避ける — 古びるのが早い。例外: プロトタイプが、散文より正確に意思決定をエンコードするスニペット（state machine、reducer、schema、type shape）を生んだ場合、それをインラインで貼り、プロトタイプ由来であることを簡潔に明記する。意思決定の核となる部分だけに刈り込む — 動くデモではなく、重要な要点だけ。

frontier を `/implement` で 1 度に 1 ticket ずつ進め、ticket 間でコンテキストをクリアする。
