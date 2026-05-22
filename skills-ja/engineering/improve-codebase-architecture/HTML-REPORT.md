# HTML レポートフォーマット

アーキテクチャレビューは OS の temp ディレクトリに置く 1 枚の自己完結 HTML ファイルとして描画する。Tailwind と Mermaid はどちらも CDN から。グラフ形の図は Mermaid に任せ、より編集的なビジュアル（質量図・断面図）は手作りの div とインライン SVG で扱う。両者を混ぜる — Mermaid に全部頼ると、すぐに generic な見た目になる。

## 足場（Scaffold）

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
      /* Tailwind で綺麗にカバーできないもの用の小さな custom layer:
         破線の seam、手描き風の矢頭など */
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

## ヘッダー

レポジトリ名、日付、コンパクトな凡例: solid box = module、破線 = seam、赤い矢印 = leakage、太い暗色の box = deep module。導入の段落は不要 — まっすぐ候補に入る。

## Candidate カード

図が荷重を担う。散文は薄く・平易に・[LANGUAGE.md](LANGUAGE.md) の語彙を儀式なしに使う。

各候補は 1 つの `<article>`:

- **Title** — 短く、deepening に名前を付ける（例: "Collapse the Order intake pipeline"）。
- **Badge row** — 推奨度（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate）、加えて依存カテゴリのタグ（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** — 等幅フォントのリスト、`font-mono text-sm`。
- **Before / After diagram** — 中心物。2 列、横並び。下のパターン参照。
- **Problem** — 一文。何が痛いか。
- **Solution** — 一文。何が変わるか。
- **Wins** — 箇条書き、各 ≤6 語。例: 「Tests hit one interface」「Pricing logic stops leaking」「Delete 4 shallow wrappers」。
- **ADR callout**（該当する場合）— amber 色のボックスに 1 行。

説明の段落を入れない。図が段落なしには理解されないなら、図を描き直せ。

## 図のパターン

候補に合うパターンを選ぶ。混ぜる。すべての図を同じに見せない — バラエティが本質だ。

### Mermaid graph（依存・コールフローの主力）

「X が Y を呼び、Y が Z を呼ぶ、ほら散らかってる」を伝えるときは Mermaid の `flowchart` または `graph` を使う。パラシュート降下で置かれた感が出ないよう、Tailwind スタイルのカードで包む。`classDef` で leakage 辺を赤に、deep Module を暗色にする。「before: 6 ラウンドトリップ、after: 1 つ」みたいなときは sequence diagram がよく効く。

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

### 手作りの boxes-and-arrows（Mermaid のレイアウトと闘うとき）

Module を border とラベル付きの `<div>` に。矢印は relative コンテナの上に絶対配置したインライン SVG の `<line>` / `<path>`。"after" の図を「太枠の deep Module 1 つ + 内部はグレーアウト」のように見せたいときに伸ばすやつ — Mermaid では適切な重さで描画されない。

### Cross-section（層状の shallowness に良い）

水平な帯（`h-12 border-l-4`）を積んで、呼び出しが通る層を示す。Before: 何もしていない薄い層が 6 つ。After: 統合された責務 1 つを示す太い帯 1 つ。

### Mass diagram（「interface が implementation と同じ幅」に良い）

Module ごとに 2 つの矩形 — interface の面積を表すもの、implementation の面積を表すもの。Before: interface 矩形が implementation 矩形とほぼ同じ高さ（shallow）。After: interface 矩形が短く、implementation 矩形が高い（deep）。

### Call-graph collapse

Before: 入れ子の box で描画された関数呼び出しのツリー。After: 同じツリーが 1 つの box に折り畳まれ、いまや内部となった呼び出しが薄く中に表示される。

## スタイル指針

- corporate-dashboard ではなく editorial に寄せる。余白を惜しまない。見出しに serif も可（`font-serif` は stone/slate と相性がいい）。
- 色は控えめに: アクセント 1 つ（emerald か indigo）+ leakage の赤 + warning の amber。
- 図は高さ ~320px に抑え、before/after が横並びで快適に収まるように。
- 図内の Module ラベルは `text-xs uppercase tracking-wider` — UI ではなく schematic に読めるように。
- スクリプトは Tailwind CDN と Mermaid ESM import の 2 つだけ。レポートはそれ以外は static — アプリコードなし、Mermaid 自身の描画以外にインタラクションなし。

## Top recommendation セクション

少し大きめのカード 1 つ。候補名、理由を一文、そのカードへのアンカーリンク。それだけ。

## トーン

平易な日本語/英語、簡潔に — ただしアーキテクチャの名詞と動詞は [LANGUAGE.md](LANGUAGE.md) からそのまま持ってくる。簡潔さは流れることの言い訳にならない。

**そのまま使う:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality。

**置き換えない:** component, service, unit（module の代わりに） · API, signature（interface の代わりに） · boundary（seam の代わりに） · layer, wrapper（module を意図しているときの代わりに）。

**スタイルに合う言い回し:**

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Wins の箇条書き**は得るものを用語集の言葉で名指す: *"locality: bugs concentrate in one module"*、*"leverage: one interface, N call sites"*、*"interface shrinks; implementation absorbs the wrappers"*。「easier to maintain」や「cleaner code」とは書かない — それらは用語集にない、居場所を得ていない。

ヘッジなし、咳払いなし、「ちなみに…」なし。文が箇条書きにできるなら箇条書きにする。箇条書きが削れるなら削る。用語が [LANGUAGE.md](LANGUAGE.md) になければ、新語を作る前に既存の言葉に手を伸ばす。
