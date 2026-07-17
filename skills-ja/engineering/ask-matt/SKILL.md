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

1. **`/grill-with-docs`** — interview で idea を研ぎ澄ます。**codebase がある**ならここから始める。これは stateful で、学んだことを `CONTEXT.md` と ADR に保持する。(codebase が無い? なら **`/grill-me`** を使う — Standalone 参照。両者とも同じ `/grilling` primitive を走らせるが、paper trail を残すのは `grill-with-docs` の方だ。)
2. **分岐 — すべての問いを会話の中で決着できるか?** ある問いが runnable な答え（状態、ビジネスロジック、実際に見ないとわからない UI）を要するなら、prototype へ迂回する。往路・復路とも **`/handoff`** で橋渡しする（Crossing sessions 参照）:
   - **`/handoff`** で出て、そのファイルに対して新しいセッションを開き、
   - **`/prototype`** で使い捨てコードによって問いに答え、
   - 学んだことを **`/handoff`** で戻し、元の idea スレッドから参照する。
3. **分岐 — これは multi-session の build か?**
   - **Yes** → **`/to-spec`**（スレッドを spec に変換）、続いて **`/to-tickets`** で tracer-bullet ticket に分割する。各 ticket は自身の **blocking edge** を宣言する。ローカル tracker では `.scratch/<feature>/issues/` 配下に 1 ticket 1 ファイルとなり、blocker 優先で手作業でさばく。実 tracker では edge がネイティブの blocking link になるので、blocker が完了した ticket はどれでも掴める — ticket ごとに **`/implement`** を起動し、**各回のあいだで context をクリアする**。
   - **No** → 同じ context window の中で、ここで直接 **`/implement`**。

   どちらの道でも、**`/implement`** は内部で **`/tdd`** を駆動して各 issue を作り上げる — 一度に 1 本の red-green スライスずつ — そして commit の前に **`/code-review`**（diff に対する Standards + Spec の 2 軸レビュー）を走らせて締める。フルの spec 抜きに具体的な振る舞いを test-first で作りたいだけなら **`/tdd`** を単独で、固定点に対して branch や PR をレビューしたいときはいつでも **`/code-review`** を単独で使え。

### Context hygiene

ステップ 1〜3 は **1 つの途切れない context window** に収めろ — `/to-tickets` が終わるまで compact もクリアもするな — そうすれば grilling、spec、ticket がすべて同じ思考の上に積み上がる。各 `/implement` はそのあと ticket を起点に、まっさらな状態から始まる。

これの上限が **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)** だ。モデルがまだ鋭く推論できる窓（state-of-the-art モデルで ~120k tokens）を指す。もしセッションが `/to-tickets` の前にそこへ近づいたら、劣化した状態で押し切るな — `/handoff` して新しいスレッドで続けろ。

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

## Crossing sessions

- **`/handoff`** — スレッドが一杯になったとき、あるいは（例えば `/prototype` セッションへ）枝分かれする必要があるとき、会話を markdown ファイルに圧縮する。その場では続けない — **新しいセッションを開き、そのファイルを参照して** context を渡す。これは context window どうしの橋であり、双方向に効く。**まっさらなセッション** が欲しいが **今の会話を保持** したいときに使え。
- **`/compact`**（built-in）— **同じ会話** に留まり、前のターンを要約させる。**フェーズ間の意図的な区切り** で、逐語の履歴を失っても構わないときに使え。フェーズの途中で compact するな — agent が道を見失いうる。`/handoff` は fork し、`/compact` は continue する。

## Standalone

main flow から完全に外れたもの。

- **`/grill-me`** — `/grill-with-docs` と同じ容赦ない interview だが、**codebase が無い** ときのためのもの。stateless で、ローカルに何も保存せず、`CONTEXT.md` も作らない。リポジトリに存在しない plan や design を研ぎ澄ますために手を伸ばせ。
- **`/prototype`** — 1 つの design 上の問いに答える、小さな使い捨てプログラム: この状態モデルはしっくりくるか、あるいはこの UI はどう見えるべきか。初日から使い捨て — 答えは残し、コードは消す。main flow のステップ 2 の迂回路だが、design 上の問いが紙の上で決着しづらいときはいつでも手を伸ばせ。
- **`/research`** — 読み込みの下働きを **background agent** に委譲する: **一次情報** に対して問いを調査し、引用付きの Markdown ファイルをリポジトリに残す。それが読んでいるあいだ、作業を続けろ。生まれるファイルは、main flow の `/grill-with-docs` へ *持ち込む* ためのものだ — research は思考に燃料を与えるのであって、思考を置き換えはしない。
- **`/teach`** — 現在のディレクトリを stateful なワークスペースとして使い、複数セッションにわたって概念を学ぶ。
- **`/writing-great-skills`** — skill をうまく書き、編集するための reference。

## Precondition

**`/setup-matt-pocock-skills`** — 最初の engineering flow の前に走らせ、他の skill 群が前提とする issue tracker、triage label、doc レイアウトを設定する。カスタムの issue tracker も使える。
