---
name: ask-matt
description: 状況にどの skill / flow が合うかを尋ねる。このリポジトリの skill 群を横断する router。Ask which skill or flow fits your situation. A router over the skills in this repo. 日本語トリガー例 / "どのスキルを使えばいい" "この状況に合う flow は" / English / "ask matt" "which skill fits"
disable-model-invocation: true
---

# Ask Matt

すべての skill を覚えてはいないのだから、尋ねろ。

**flow** とは skill 群を貫く経路だ。ほとんどの経路は 1 本の **main flow** に沿って走り、2 本の **on-ramp** がそこへ合流する。それ以外はすべて standalone か、あるいはその下で走る vocabulary layer だ。

## main flow: idea → ship

作業の大半が辿る経路。idea があり、それを作りたいときに。

1. **`/grill-with-docs`** — interview で idea を研ぎ澄ます。**working directory の中で作業している**ならいつでもここから始める。これは stateful で、学んだことを `CONTEXT.md` と ADR に保持する。(working directory が無い? なら **`/grill-me`** を使う — Standalone 参照。両者とも同じ `/grilling` primitive を走らせるが、paper trail を残すのは `grill-with-docs` の方だ。残す先のリポジトリがあるなら常にこちらが優る。)
2. **分岐 — すべての問いを会話の中で決着できるか?** ある問いが runnable な答え（状態、ビジネスロジック、実際に見ないとわからない UI）を要するなら、prototype へ迂回する。往路・復路とも **`/handoff`** で橋渡しする（prototype は自分のディレクトリに存在する。それこそ `/handoff` の用途だ — Phase boundaries 参照）:
   - **`/handoff`** で出て、そのファイルに対して新しいセッションを開き、
   - **`/prototype`** で使い捨てコードによって問いに答え、
   - 学んだことを **`/handoff`** で戻し、元の idea スレッドから参照する。
3. **分岐 — これは multi-session の build か?**
   - **Yes** → **`/to-spec`**（スレッドを spec に変換）、続いて **`/to-tickets`** で tracer-bullet ticket に分割する。各 ticket は自身の **blocking edge** を宣言する。ローカル tracker では `.scratch/<feature>/issues/` 配下に 1 ticket 1 ファイルとなり、blocker 優先で手作業でさばく。実 tracker では edge がネイティブの blocking link になるので、blocker が完了した ticket はどれでも掴める — ticket ごとに **`/implement`** を起動し、**各回のあいだで `/clear` して context を空にする**。各 ticket は自己完結しているので、直前の ticket の context は捨ててよい。
   - **No** → 同じ context window の中で、ここで直接 **`/implement`**。

   どちらの道でも、**`/implement`** は内部で **`/tdd`** を駆動して各 issue を作り上げる — 一度に 1 本の red-green スライスずつ — そして commit の前に **`/code-review`**（diff に対する Standards + Spec の 2 軸レビュー）を走らせて締める。フルの spec 抜きに具体的な振る舞いを test-first で作りたいだけなら **`/tdd`** を単独で、固定点に対して branch や PR をレビューしたいときはいつでも **`/code-review`** を単独で使え。

### Context hygiene

ステップ 1〜3 は **1 つの途切れない context window** に収めろ — `/to-tickets` が終わるまで compact もクリアもするな — そうすれば grilling、spec、ticket がすべて同じ思考の上に積み上がる。各 `/implement` はそのあと ticket を起点に、まっさらな状態から始まる。

これの上限が **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)** だ。モデルがまだ鋭く推論できる窓（state-of-the-art モデルで ~150k tokens）を指す。もしセッションが `/to-tickets` の前にそこへ近づいたら、劣化した状態で押し切るな — 最も近い phase boundary で `/compact` して続けろ（Phase boundaries 参照）。

## On-ramp

作業を生み出す出発状況で、そこから main flow に合流する。

- **バグや要望が積み上がっている** → **`/triage`**。issue を triage role の中で動かし、agent-ready な issue を生み出す。それを **`/implement`** が後で拾う。

  triage は **自分が作っていない** issue 専用だ — バグ報告、入ってくる機能要望、生のまま到着したものすべて。`/to-tickets` が生んだ ticket はすでに agent-ready なので、**triage するな**。

- **何かが壊れている** → **`/diagnosing-bugs`**。難物向け — 一目では歯が立たないバグ、断続的な flake、2 つの既知の good state のあいだに忍び込んだ regression。**tight な feedback loop**（*この*バグですでに red になる 1 コマンド）を手にするまで理論化を拒み、そのうえで regression test とともに直す。その post-mortem は、真の発見が「バグを封じ込める良い seam が無い」ことだったとき、**`/improve-codebase-architecture`** へ handoff する。

- **巨大で霧のかかった取り組み — greenfield プロジェクトや、1 セッションには大きすぎる巨大な機能 build** → **`/wayfinder`**。ここで最も認知負荷の高い flow だ。今いる地点から目的地への道がまだ見えないとき、issue tracker 上に **decision ticket** の **shared map** を描き、それを一度に 1 つずつ解決していく — 生み出すのは **decision であって deliverable ではない** — 霧が押し戻され、道が見えるまで。**`/grill-with-docs`** が 1 セッションで抱えきれる idea を研ぐのに対し、wayfinder は抱えきれない idea 向けだ — しかも遅く濃密なので、まさにそういうときのために取っておけ。決してスコープの定まった機能には使うな。

  map が晴れたら、**それは handoff する。build はしない**: **`/to-spec`** で main flow に合流し、map のリンクされた decision を build 可能な plan へ畳み込む。そのあとはいつも通り `/to-tickets` と `/implement`。map をそのまま `/implement` へループさせると、その畳み込みを飛ばしてリンクされた詳細を捨てることになる — 取り組みが本当に小さかったと判明したときにだけ、直接 `/implement` へ行け。

## Codebase health

feature work ではなく、手入れ。

- **`/improve-codebase-architecture`** — 手が空いたときはいつでも走らせ、agent が動きやすい良い codebase を保て。**deepening opportunity** を炙り出す。1 つ選べば _idea が生まれ_、それを main flow の `/grill-with-docs` へ持ち込める。これは候補を見つける調査で、**`/codebase-design`**（下記）は選んだものを設計する作業台だ。

## 下で走る Vocabulary

他の skill の *下* で走る、model-invoked な 2 つの reference — それぞれが自分の vocabulary の唯一の source of truth だ。プロセスではなく **言葉** の方が問題のときに直接手を伸ばすか、上の skill 群に引き込ませろ。

- **`/domain-modeling`** — プロジェクトの *domain* 言語を研ぎ澄ます: 曖昧な用語に挑み、多重定義された語（3 つの役目を負う "account"）を解きほぐし、覆しにくい decision を ADR として記録する。`/grill-with-docs` が `CONTEXT.md` をきれいな glossary に保つために駆動する、能動的な規律そのものだ。
- **`/codebase-design`** — module の *形* を設計するための deep-module vocabulary（module、interface、depth、seam、adapter、leverage、locality）: きれいな seam にある小さな interface の背後に、多くの振る舞いを収める。`/tdd` も `/improve-codebase-architecture` もこの言葉を話す。

## Phase boundaries

**phase** とはセッション内の作業のかたまりだ — grilling、implementation、QA。その 2 つの **境界** では 5 つの選択肢があり、この地図全体で最も判断が曖昧なのがここだ:

- **Continue** — そのまま留まる。コストゼロ、失うものもゼロ。
- **`/clear`** — 窓を空にする。ここにあるものが次に何も効かないとき。
- **`/handoff`** — 可搬な markdown ファイルを書く。用途は狭い: **別の harness**、**別のディレクトリ**、**同僚**、あるいは phase の途中で横道の作業を fork するときだけ。得られるのは可搬性だ。
- **Subagent** — きつくスコープを絞ったタスクを専用の窓へ送り、報告を受け取る。
- **`/compact`** — この context を圧縮し、それを種に新しいセッションを立てる。**デフォルト** ではあるが、最初に手を伸ばす先ではなく、ツリーの末尾にある。

順序付きの決定ツリー — 5 つの問い、各分岐の理由、そして一次情報 (primary source) のコストゆえに **Continue** が真っ先に除外される理由 — は [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) を読め。判断は境界 **で** 下せ。phase の途中なら、そのまま続けるか、残りを subagent に切り分けろ。

## Standalone

main flow から完全に外れたもの。

- **`/grill-me`** — `/grill-with-docs` と同じ容赦ない interview だが、**stateless** だ: ローカルに何も保存せず、`CONTEXT.md` も作らない。**working directory の中で作業していない** ときに手を伸ばせ — plan、design、文章、リポジトリの無いもの全般を研ぎ澄ますとき。working directory の中にいるなら代わりに `/grill-with-docs` を使え: 同じ interview を走らせたうえで paper trail を残すので、厳密にそちらが優る。
- **`/grilling`** — interview の primitive そのもの: ラウンド、frontier、事実を調べるのは agent の仕事で判断はあなたのもの、という原則。`/grill-me` と `/grill-with-docs` が名前の付いた 2 つの入口であり、`/triage`、`/wayfinder`、`/improve-codebase-architecture` はいずれも内部でこれを走らせる。ラッパー無しの interview が欲しいときだけ直接手を伸ばせ。
- **`/resolving-merge-conflicts`** — 進行中の merge / rebase の conflict を hunk 単位でさばく。行を選ぶのではなく、双方の一次情報 (primary source) まで辿った **意図** で解決し、そのうえで操作を完了させる。`--abort` は決して走らせない。standalone であらゆる flow の外にある: すでに conflict の只中にいるときに手を伸ばせ。
- **`/prototype`** — 1 つの design 上の問いに答える、小さな使い捨てプログラム: この状態モデルはしっくりくるか、あるいはこの UI はどう見えるべきか。「使い捨て」はコードの書き方に対する制約であって、破棄する約束ではない: 答えは実コードへ畳み込まれ、プロトタイプ自体は main の外の `prototype/<name>` ブランチに **一次情報 (primary source)** として残し、実装 Issue からそこを指す。main flow のステップ 2 の迂回路だが、design 上の問いが紙の上で決着しづらいときはいつでも手を伸ばせ。
- **`/research`** — 読み込みの下働きを **background agent** に委譲する: **一次情報** に対して問いを調査し、引用付きの Markdown ファイルをリポジトリに残す。それが読んでいるあいだ、作業を続けろ。生まれるファイルは、main flow の `/grill-with-docs` へ *持ち込む* ためのものだ — research は思考に燃料を与えるのであって、思考を置き換えはしない。
- **`/to-questionnaire`** — 詰まりの原因が自分の頭の中でもコードベースでもなく **他人の頭の中** にあるとき、その人に記入してもらう questionnaire を書く。`/grill-me` の逆だ: 主題についてあなたを詰めるのではなく、**送付** についてあなたを詰め — 誰に送るのか、何を返してほしいのか — 質問をその欠落へ向ける。返ってきたものは `/grill-with-docs` や `/to-spec` の材料になる。
- **`/wizard`** — **人間にしか**踏めない手順のためのもの: インフラの払い出し、認証情報や CI secret の設定、不慣れなサードパーティのダッシュボードのクリック作業、一度きりの migration や切り替え。各 URL を開き、各値を取り込み、`.env` と GitHub secrets へ書き込む対話的な bash スクリプトを生成する — その手順を、毎回 agent に説明し直すものではなくす。model-invoked なので、あなたにしか越えられない壁に当たった瞬間に agent が自分で手を伸ばす。agent が自分でできることなら自分でやるべきだ。これは人間が本当に loop の中にいる場合のためのものだ。
- **`/wait-what`** — 伝わらなかったメッセージへの是正措置。会話の途中、他のどの skill の内側でも使え。agent は直前に言ったことを、あなたに欠けていた context を補い、平易な言葉で、`CONTEXT.md` の語彙を使って言い直す。これは事後の手当てだ。前もっての治療は `/grill-with-docs` の方で、早い段階で合意された共通言語こそが、そもそも jargon の到来を止める。
- **`/teach`** — 現在のディレクトリを stateful なワークスペースとして使い、複数セッションにわたって概念を学ぶ。
- **`/writing-for-agents`** — agent が読む文書 — skill、AGENTS.md、指し示されるドキュメント — を書くための reference。

## Precondition

**`/setup-matt-pocock-skills`** — 最初の engineering flow の前に走らせ、他の skill 群が前提とする issue tracker、triage label、doc レイアウトを設定する。カスタムの issue tracker も使える。
