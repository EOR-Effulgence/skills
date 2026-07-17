# HTML Report Format

アーキテクチャ review は、OS の temp ディレクトリ内の単一の自己完結した HTML ファイルとして描画する。Tailwind と Mermaid はどちらも CDN から来る。Mermaid はグラフ状の図を確実に扱う。手組みの div とインライン SVG は、よりエディトリアルなビジュアル（質量図、断面図）を扱う。両者を混ぜろ — すべてを Mermaid に頼るな、汎用的に見え始める。

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

リポジトリ名、日付、そしてコンパクトな凡例: 実線ボックス = module、破線 = seam、赤い矢印 = leakage、太い暗色ボックス = deep module。導入段落は無し — まっすぐ候補へ入る。

## Candidate card

図が重みを担う。散文はまばらで平易、そして glossary 用語（`/codebase-design` skill 由来）を仰々しさなしに使う。

各候補は 1 つの `<article>`:

- **Title** — 短く、deepening に名前を付ける（例: "Collapse the Order intake pipeline"）。
- **Badge row** — recommendation strength（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate）、加えて依存カテゴリのタグ（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** — 等幅リスト、`font-mono text-sm`。
- **Before / After diagram** — 中心。2 カラム、横並び。下記のパターン参照。
- **Problem** — 一文。何が痛むか。
- **Solution** — 一文。何が変わるか。
- **Wins** — 箇条書き、各 6 語以内。例: "Tests hit one interface"、"Pricing logic stops leaking"、"Delete 4 shallow wrappers"。
- **ADR callout**（該当する場合）— amber 色のボックス内に一行。

説明の段落は無し。図を理解するのに段落が要るなら、図を描き直せ。

## Diagram patterns

候補に合うパターンを選べ。混ぜろ。すべての図を同じに見せるな — variety が肝の一部だ。

### Mermaid graph (the workhorse for dependencies / call flow)

要点が "X calls Y calls Z, and look at the mess" のときは Mermaid の `flowchart` または `graph` を使う。パラシュートで降ってきたように感じないよう、Tailwind でスタイルしたカードで包め。classDef で leakage エッジを赤に、deep module を暗色にスタイルする。シーケンス図は "before: 6 round-trips; after: 1" によく効く。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### Hand-built boxes-and-arrows (when Mermaid's layout fights you)

Module を境界とラベル付きの `<div>` として。矢印を、relative なコンテナ上に絶対配置したインライン SVG の `<line>` や `<path>` 要素として。"after" の図を、内部がグレーアウトした 1 つの太枠 deep module のように感じさせたいときにこれを使う — Mermaid はそれを正しい重みで描画しない。

### Cross-section (good for layered shallowness)

呼び出しが通過するレイヤーを示すために水平の帯（`h-12 border-l-4`）を積む。Before: 何もしない 6 枚の薄いレイヤー。After: 統合された責務でラベル付けされた 1 枚の厚い帯。

### Mass diagram (good for "interface as wide as implementation")

Module ごとに 2 つの長方形 — 1 つは interface の表面積、もう 1 つは implementation。Before: interface の長方形が implementation の長方形とほぼ同じ高さ（shallow）。After: interface の長方形が低く、implementation の長方形が高い（deep）。

### Call-graph collapse

Before: 関数呼び出しのツリーをネストしたボックスとして描画。After: 同じツリーが 1 つのボックスに崩れ、内部化された呼び出しがその中に薄く表示される。

## Style guidance

- コーポレートダッシュボードではなくエディトリアル寄りに。ゆとりある余白。見出しにはセリフも可（`font-serif` は stone/slate とよく合う）。
- 色は控えめに: 1 つのアクセント（emerald か indigo）に加え、leakage に赤、warning に amber。
- before/after がスクロールなしで快適に横並びになるよう、図は ~320px の高さに保つ。
- 図の中の module ラベルには `text-xs uppercase tracking-wider` を使う — UI ではなく schematic に読めるべきだ。
- スクリプトは Tailwind CDN と Mermaid ESM import のみ。それ以外レポートは静的だ — アプリコードは無く、Mermaid 自身の描画を超えるインタラクティビティも無い。

## Top recommendation section

より大きなカードを 1 つ。候補名、なぜかを一文、そのカードへのアンカーリンク。それだけ。

## Tone

平易な英語で簡潔に — ただしアーキテクチャの名詞と動詞は `/codebase-design` skill からそのまま来る。簡潔さは流れる言い訳にならない。

**必ずこう使え:** module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**決して置き換えるな:** component、service、unit（module の代わりに）· API、signature（interface の代わりに）· boundary（seam の代わりに）· layer、wrapper（module を意味するときの module の代わりに）。

**このスタイルに合う言い回し:**

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Wins の箇条書き** は gain を glossary 用語で名指す: *"locality: bugs concentrate in one module"*、*"leverage: one interface, N call sites"*、*"interface shrinks; implementation absorbs the wrappers"*。*"easier to maintain"* や *"cleaner code"* とは書くな — それらの用語は glossary に無く、居場所を稼いでいない。

ヘッジも、前置きも、"it's worth noting that…" も無し。一文が箇条書きにできるなら、箇条書きにしろ。箇条書きが削れるなら、削れ。ある用語が `/codebase-design` の glossary に無いなら、新しいものを発明する前に glossary にあるものへ手を伸ばせ。
