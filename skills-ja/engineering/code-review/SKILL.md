---
name: code-review
description: 固定点（commit / branch / tag / merge-base）以降の変更を、Standards 軸（コードがこのリポジトリの文書化されたコーディング標準に従っているか）と Spec 軸（コードが起点となった issue/PRD の要求に合致しているか）の 2 軸でレビューする。両レビューを parallel sub-agent で走らせ、並べて報告する。Review changes since a fixed point along two axes — Standards and Spec — running both reviews in parallel sub-agents and reporting them side by side. 日本語トリガー例 / "このブランチをレビューして" "PR をレビューして" "X 以降の変更をレビュー" / English / "review this branch" "review since X"
---

ユーザーが指定した固定点と `HEAD` の間の diff を 2 軸でレビューする:

- **Standards** — コードがこのリポジトリの文書化されたコーディング標準に準拠しているか?
- **Spec** — コードが起点となった issue / PRD / spec を忠実に実装しているか?

両軸は **parallel sub-agent** として走らせ、互いの context を汚染しないようにする。その後、このスキルが両者の findings を集約する。

issue tracker は事前に渡されているはずだ — `docs/agents/issue-tracker.md` が無ければ `/setup-matt-pocock-skills` を実行しろ。

## Process

### 1. 固定点を固定する

ユーザーが言ったものが固定点だ — commit SHA、branch 名、tag、`main`、`HEAD~5` など。指定が無ければ尋ねろ。

diff コマンドを一度だけ確定する: `git diff <fixed-point>...HEAD`（three-dot なので比較は merge-base に対して行われる）。また `git log <fixed-point>..HEAD --oneline` で commit のリストを控えておく。

先に進む前に、固定点が解決できること（`git rev-parse <fixed-point>`）と diff が空でないことを確認しろ。不正な ref や空の diff はここで失敗させる — 2 つの parallel sub-agent の内側ではなく。

### 2. spec の出所を特定する

起点となった spec を、次の順で探せ:

1. commit メッセージ内の issue 参照（`#123`、`Closes #45`、GitLab の `!67` など）— `docs/agents/issue-tracker.md` のワークフローで fetch する。
2. ユーザーが引数として渡したパス。
3. branch 名や機能に一致する、`docs/`、`specs/`、`.scratch/` 配下の PRD/spec ファイル。
4. 何も見つからなければ、spec の場所をユーザーに尋ねる。無いと言われた場合、**Spec** sub-agent は skip して「no spec available」と報告する。

### 3. standards の出所を特定する

コードをどう書くべきかを文書化しているものすべて。例えば `CODING_STANDARDS.md` や `CONTRIBUTING.md`。

リポジトリが文書化しているものに加えて、Standards 軸は常に下記の **smell baseline** を携える — これは Fowler の code smell（_Refactoring_、ch.3）の固定セットで、リポジトリが何も文書化していなくても適用される。これを縛るルールは 2 つ:

- **リポジトリが上書きする。** 文書化されたリポジトリ標準が常に勝つ。baseline がフラグを立てるものをリポジトリ標準が是認している場合は、その smell を抑制する。
- **常に判断の問題。** 各 smell はラベル付きのヒューリスティック（「possible Feature Envy」）であって、決してハードな違反ではない — そしてここのどの標準とも同様、ツールが既に強制しているものは skip する。

各 smell は *それが何か* → *どう直すか* の順で読む。diff に照らして突き合わせろ:

- **Mysterious Name** — 何をするか / 何を保持するかを名前が明かさない関数・変数・型。→ rename する。誠実な名前が出てこないなら、設計が濁っている。
- **Duplicated Code** — 同じロジックの形が、変更内の複数の hunk やファイルに現れる。→ 共有される形を抽出し、両方から呼ぶ。
- **Feature Envy** — 自分自身よりも別のオブジェクトのデータに手を伸ばすメソッド。→ そのメソッドを、envy しているデータの側へ move する。
- **Data Clumps** — 同じ少数のフィールドやパラメータがいつも一緒に旅する（生まれたがっている型）。→ 1 つの型にまとめ、それを渡す。
- **Primitive Obsession** — 自分の型を持つに値する Domain 概念の代わりに立つ primitive や string。→ その概念に自前の小さな型を与える。
- **Repeated Switches** — 同じ型に対する同じ `switch`/`if` カスケードが変更全体で再発する。→ polymorphism で置き換えるか、両サイトが共有する 1 つの map にする。
- **Shotgun Surgery** — 1 つの論理的変更が、diff 内の多数のファイルに散らばった編集を強いる。→ 一緒に変わるものを 1 つの module に集める。
- **Divergent Change** — 1 つのファイルや module が、無関係な複数の理由で編集される。→ 各 module が 1 つの理由で変わるように分割する。
- **Speculative Generality** — spec が持たないニーズのために追加された抽象・パラメータ・hook。→ 削除する。実際のニーズが現れるまで inline に戻す。
- **Message Chains** — 呼び出し側が依存すべきでない長い `a.b().c().d()` ナビゲーション。→ その歩き回りを、最初のオブジェクト上の 1 つのメソッドの背後に隠す。
- **Middle Man** — ほとんどただ先へ委譲するだけのクラスや関数。→ それを切り、本来のターゲットを直接呼ぶ。
- **Refused Bequest** — 継承したものの大半を無視または override する subclass や実装者。→ 継承をやめ、composition を使う。

### 4. 両 sub-agent を parallel で spawn する

2 つの `Agent` tool 呼び出しを 1 つのメッセージで送る。両方とも `general-purpose` subagent を使う。

**Standards sub-agent prompt** — 含めるもの:

- diff コマンド一式と commit リスト。
- step 3 で見つけた standards の出所ファイルのリスト、**加えて step 3 の smell baseline** を全文貼り付ける — sub-agent はそれに他からアクセスできない。
- ブリーフ: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — 含めるもの:

- diff コマンドと commit リスト。
- spec のパス、または fetch した内容。
- ブリーフ: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

spec が無い場合は Spec sub-agent を skip し、最終レポートにその旨を記す。

### 5. 集約する

2 つのレポートを `## Standards` と `## Spec` の見出しの下に、そのまま、または軽く整えて提示する。findings を merge したり再ランク付けしたりは **するな** — 2 軸は意図的に分離してある（_Why two axes_ を参照）。

最後に 1 行のサマリーで締める: 軸ごとの findings 総数と、_各軸の中での_ 最悪の issue（あれば）。軸をまたいで単一の勝者を選ぶな — それこそ、この分離が防ぐために存在する再ランク付けだ。

## Why two axes

ある変更は、一方の軸を通過して他方で失敗し得る:

- すべての標準に従っているが、間違ったものを実装しているコード → **Standards pass、Spec fail。**
- issue が求めたことを正確にやっているが、プロジェクトの規約を壊しているコード → **Spec pass、Standards fail。**

両者を別々に報告することで、一方の軸が他方を覆い隠すのを防ぐ。
