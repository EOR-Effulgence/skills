---
name: improve-codebase-architecture
description: コードベースを走査して deepening opportunities を炙り出し、visual な HTML report として提示し、選んだものを grilling で詰める。Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. 日本語トリガー例 / "アーキテクチャを改善して" "リファクタリング機会を探して" "密結合 Module を統合して" / English / "improve architecture" "find refactoring opportunities"
disable-model-invocation: true
---

# Improve Codebase Architecture

アーキテクチャ上の摩擦を可視化し、**deepening opportunities**（deepening opportunities） — shallow な Module を deep な Module へと変えるリファクタ — を提案する。狙いはテスト可能性と AI 走査性。

このコマンドはプロジェクトのドメインモデルに _informed_ され、共有された設計 vocabulary の上に成り立つ:

- アーキテクチャの vocabulary（**module**、**interface**、**depth**、**seam**、**adapter**、**leverage**、**locality**）とその原則（the deletion test、"the interface is the test surface"、"one adapter = hypothetical seam, two = real"）については `/codebase-design` skill を実行する。これらの用語をすべての提案で正確に使い、"component"、"service"、"API"、"boundary" へ流れるな。
- `CONTEXT.md` のドメイン言語は良い seam に名前を与える。`docs/adr/` の ADR はこのコマンドが蒸し返すべきでない決定を記録している。

## Process

### 1. Explore

**走査する前にスコープを絞れ — YAGNI。** Module を deepen することは、それに対する将来の変更を楽にすることで報われる。したがって最近変更されたコードベースの部分に重みを置け。*どこ*を見るかを、見る前に決めろ:

- ユーザーが方向を指定したなら — Module、サブシステム、痛点 — それを採り、以下の推論はスキップする。
- そうでなければ、commit history をそれなりの範囲まで遡り（`git log --oneline`）、コードベースの hot spot — 何度も出てくるファイルや領域 — を見つけ、それらのパスに最初に注意を引かせる。変更が散らばっていて明確な hot spot が無ければ、網を広げる。

まず、着手する領域のプロジェクトの domain glossary（`CONTEXT.md`）と ADR を読む。

次に Agent tool を `subagent_type=Explore` で使ってコードベースを歩く。硬直したヒューリスティックに従うな — 有機的に探索し、摩擦を感じた場所を書き留めろ:

- 1 つの概念を理解するのに、多くの小さな Module を行き来する必要があるのはどこか?
- Module が **shallow** — interface が implementation とほぼ同じ複雑さ — なのはどこか?
- テスト可能性のためだけに純粋関数が抽出されているが、実際のバグはそれがどう呼ばれるか（**locality** が無い）に隠れているのはどこか?
- 密結合な Module が seam をまたいで漏れているのはどこか?
- コードベースのどの部分がテストされていない、または現在の interface 経由でテストしづらいか?

shallow だと疑うものには **deletion test** を適用しろ: それを削除すると複雑さが集中するか、それとも移動するだけか? "yes、集中する" が欲しいシグナルだ。

### 2. Present candidates as an HTML report

自己完結した HTML ファイルを OS の temp ディレクトリに書き、リポジトリには何も残さない。temp ディレクトリは `$TMPDIR` から解決し、`/tmp`（Windows では `%TEMP%`）にフォールバックする。実行のたびに新しいファイルになるよう `<tmpdir>/architecture-review-<timestamp>.html` に書く。ユーザー向けに開き — Linux では `xdg-open <path>`、macOS では `open <path>`、Windows では `start <path>` — 絶対パスを伝える。

レポートはレイアウトとスタイリングに **Tailwind via CDN** を、そしてグラフ/フロー/シーケンスが構造を確実に伝える箇所の図に **Mermaid via CDN** を使う。Mermaid と手作りの CSS/SVG ビジュアルを混ぜろ — 関係がグラフ状（call graph、依存、シーケンス）なら Mermaid を、もっとエディトリアルなもの（質量図、断面図、崩壊アニメーション）が欲しいなら手組みの div/SVG を使う。各候補には **before/after のビジュアライゼーション** を付ける。ビジュアルであれ。

各候補について、次を含むカードを描画する:

- **Files** — どのファイル/Module が関わるか
- **Problem** — 現在のアーキテクチャがなぜ摩擦を生んでいるか
- **Solution** — 何が変わるかの平易な英語での説明
- **Benefits** — locality と leverage の観点で、そしてテストがどう改善するかで説明する
- **Before / After diagram** — 横並び、カスタム描画で、shallowness と deepening を図示する
- **Recommendation strength** — `Strong`、`Worth exploring`、`Speculative` のいずれか、バッジとして描画

レポートの末尾は **Top recommendation** セクションで締める: どの候補を最初に取り組むか、そしてなぜか。

**ドメインには CONTEXT.md の vocabulary を、アーキテクチャには `/codebase-design` の vocabulary を使え。** `CONTEXT.md` が "Order" を定義しているなら、"the Order intake module" と言え — "the FooBarHandler" でも、"the Order service" でもない。

**ADR との衝突**: 候補が既存の ADR と矛盾する場合、その ADR を見直す価値があるほど摩擦が本物のときだけ表に出す。カード内で明確に印を付ける（例: warning callout: _"contradicts ADR-0007 — but worth reopening because…"_）。ある ADR が禁じる理論上のリファクタをすべて列挙するな。

完全な HTML scaffold、diagram パターン、スタイリングガイダンスは [HTML-REPORT.md](HTML-REPORT.md) を参照。

まだ interface を提案するな。ファイルを書いた後、ユーザーに尋ねろ: "Which of these would you like to explore?"

### 3. Grilling loop

ユーザーが候補を選んだら、`/grilling` skill を実行して decision tree を一緒に歩く — 制約、依存、deepen された Module の形、seam の裏に何が座るか、どのテストが生き残るか。

判断が固まり次第、副作用がインラインで発生する — 進めながらドメインモデルを最新に保つため `/domain-modeling` skill を実行しろ:

- **deepen した Module を `CONTEXT.md` に無い概念にちなんで命名しようとしているか?** その用語を `CONTEXT.md` に追加する。ファイルが存在しなければ遅延的に作成する。
- **会話中に曖昧な用語を研ぎ澄ましたか?** その場で `CONTEXT.md` を更新する。
- **ユーザーが load-bearing な理由で候補を却下したか?** ADR を提案し、こう枠づける: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ その理由が、将来の探索者が同じことを再提案しないために実際に必要になるときだけ提案しろ — 一時的な理由（"not worth it right now"）や自明な理由はスキップする。
- **deepen した Module の代替 interface を探りたいか?** `/codebase-design` skill を実行し、その design-it-twice の並列 sub-agent パターンを使う。
