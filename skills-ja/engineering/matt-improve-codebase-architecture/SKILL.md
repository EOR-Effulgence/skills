---
name: matt-improve-codebase-architecture
description: CONTEXT.md のドメイン用語と docs/adr/ の決定事項を踏まえつつ、コードベースに潜む「深化（deepening）」の機会を炙り出す。アーキテクチャ改善、リファクタリング機会の発見、密結合モジュールの統合、テスト可能性や AI 走査性の向上を望むときに使用。Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable.
---

# コードベースアーキテクチャの改善

アーキテクチャ上の摩擦を可視化し、**深化の機会（deepening opportunities）** — shallow なモジュールを deep なモジュールへと変えるリファクタ — を提案する。狙いはテスト可能性と AI 走査性。

## 用語集

提案の中でこれらの用語は**そのまま**使う。「component」「service」「API」「boundary」などに流れない。一貫した言語こそが本旨だ。完全な定義は [LANGUAGE.md](LANGUAGE.md)。

- **Module** — interface と implementation を持つもの（関数・クラス・パッケージ・スライス）。
- **Interface** — 呼び出し側がモジュールを使うために知らなければならない一切: 型、不変条件、エラーモード、順序、設定。型シグネチャだけではない。
- **Implementation** — 中身のコード。
- **Depth** — interface から得られるレバレッジ。小さな interface の裏に大量のふるまいがある状態。**Deep** = 高レバレッジ。**Shallow** = interface が implementation とほぼ同じ複雑さ。
- **Seam** — interface が存在する場所。その場所を編集せずに振る舞いを変えられる地点。（「boundary」ではなくこれを使う。）
- **Adapter** — seam で interface を満たす具体物。
- **Leverage** — 呼び出し側が depth から得るもの。
- **Locality** — 保守側が depth から得るもの。変更・バグ・知識が 1 箇所に集まる。

主要原則（フルリストは [LANGUAGE.md](LANGUAGE.md)）:

- **Deletion test**: モジュールを削除したと想像する。複雑性が消えるなら、それは素通り（pass-through）だった。複雑性が N 個の呼び出し側に再出現するなら、そのモジュールは仕事をしていた。
- **The interface is the test surface.**（interface こそがテスト面）
- **One adapter = hypothetical seam. Two adapters = real seam.**（adapter 1 つでは仮定の seam、2 つで初めて本物）

このスキルはプロジェクトのドメインモデルに**情報を与えられる**側だ。ドメイン言語は良い seam に名前を与え、ADR はこのスキルが蒸し返すべきでない決定を記録している。

## プロセス

### 1. 探索

まず触ろうとしている領域のプロジェクトドメイン用語集と ADR を読む。

次に Agent ツール（`subagent_type=Explore`）でコードベースを歩く。硬直したヒューリスティックに従わない — 有機的に探索し、摩擦を感じた場所をメモする:

- ひとつの概念を理解するために、多数の小さなモジュール間を行き来する必要があるのはどこか？
- **shallow** なモジュール — interface が implementation とほぼ同じ複雑さ — はどこか？
- 純粋関数がテスト可能性のためだけに切り出されているが、本当のバグは呼ばれ方の中に潜んでいる（**locality** がない）箇所はどこか？
- 密結合モジュールが seam を越えて漏れている（leak している）のはどこか？
- 現在の interface ではテストが書きにくい、あるいは未テストの箇所はどこか？

shallow だと疑うものには **deletion test** を当てる: 削除したら複雑性が 1 箇所に集まるか、それとも単に移動するだけか？「集まる」が欲しい答え。

### 2. HTML レポートとして候補を提示

自己完結した HTML ファイルを OS の temp ディレクトリに書く（レポジトリに何も残さないため）。temp ディレクトリは `$TMPDIR` から解決し、なければ `/tmp`（Windows なら `%TEMP%`）にフォールバックして、`<tmpdir>/architecture-review-<timestamp>.html` に書く（毎回新しいファイルになるように）。ユーザーのためにそれを開く — Linux なら `xdg-open <path>`、macOS なら `open <path>`、Windows なら `start <path>` — そして絶対パスを伝える。

レポートはレイアウトとスタイリングに **Tailwind via CDN**、グラフ・フロー・シーケンスが構造を確実に伝える箇所では **Mermaid via CDN** を使う。Mermaid と手作りの CSS/SVG ビジュアルを**混ぜる** — グラフ形（コールグラフ・依存・シーケンス）には Mermaid、もっと編集的なもの（質量図、断面図、collapse アニメーション）には手作りの div/SVG。各候補に**before/after の図**を付ける。視覚的にやれ。

各候補ごとに、これまでと同じテンプレートをカードとして描画する:

- **Files** — 関与するファイル/モジュール
- **Problem** — 現在のアーキテクチャが摩擦を起こしている理由
- **Solution** — 何が変わるかを平易な日本語/英語で
- **Benefits** — locality と leverage の言葉で、そしてテストがどう改善するかで説明
- **Before / After diagram** — 並べて、カスタム描画で、shallowness と deepening を図解
- **Recommendation strength** — `Strong` / `Worth exploring` / `Speculative` のいずれかをバッジで

レポートの末尾は **Top recommendation** セクション: 最初にどの候補に取り組むべきか、なぜか。

**ドメインには CONTEXT.md の語彙、アーキテクチャには [LANGUAGE.md](LANGUAGE.md) の語彙を使う。** `CONTEXT.md` が "Order" を定義しているなら、「the Order intake module」と書く — 「the FooBarHandler」でも「the Order service」でもなく。

**ADR との衝突**: 候補が既存 ADR と矛盾する場合は、ADR の再検討に値するほど摩擦が本物のときだけ表面化する。カード内に明確にマーク（例: 警告コールアウト — *「ADR-0007 に矛盾するが、再オープンに値する。なぜなら…」*）。ADR が禁じる理論上のリファクタを全部リストアップしてはいけない。

HTML の足場・図のパターン・スタイル指針は [HTML-REPORT.md](HTML-REPORT.md) を参照。

まだ interface を提案するな。ファイルを書いたあと、ユーザーに尋ねる: 「どれを深掘りしますか？」

### 3. Grilling ループ

ユーザーが候補を 1 つ選んだら、grilling 会話に入る。設計ツリーを一緒に歩く — 制約、依存、deep 化されたモジュールの形、seam の裏に何が座るか、どのテストが生き残るか。

副作用は判断が固まり次第その場で起こす:

- **`CONTEXT.md` にない概念で deep 化モジュールに命名しようとした？** `CONTEXT.md` にその用語を追加する — 規律は `/grill-with-docs` と同じ（[CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md) 参照）。ファイルが存在しなければ遅延作成。
- **会話中に曖昧な用語を研ぎ澄ました？** その場で `CONTEXT.md` を更新。
- **ユーザーが load-bearing な理由で候補を却下した？** ADR を提案する。フレーミングは: *「将来のアーキテクチャレビューで同じことが再提案されないよう、これを ADR として記録しましょうか？」* 将来の探索者が同じ提案を避けるために実際に必要となるであろう理由のときだけ提案する — その場限りの理由（「今は割に合わない」）や自明な理由はスキップ。[ADR-FORMAT.md](../grill-with-docs/ADR-FORMAT.md) 参照。
- **deep 化モジュールの代替 interface を探索したい？** [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) 参照。
