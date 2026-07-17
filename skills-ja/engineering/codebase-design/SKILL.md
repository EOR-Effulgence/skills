---
name: codebase-design
description: deep module を設計するための共通語彙。ユーザーがある module の Interface を設計・改善したい、deepening の機会を見つけたい、Seam をどこに置くか決めたい、コードをよりテスト可能・AI 走査可能にしたいとき、あるいは別のスキルが deep-module 語彙を必要とするときに使う。Shared vocabulary for designing deep modules. Use when designing or improving a module's interface, finding deepening opportunities, deciding where a seam goes, or making code more testable and AI-navigable. 日本語トリガー例 / "module を設計して" "deepening の機会を探して" "Seam をどこに置く" / English / "design a deep module" "find deepening opportunities"
---

# Codebase Design

**deep module** を設計する。小さな Interface の背後に多くの振る舞いを置き、それをきれいな Seam に配置し、その Interface を通してテスト可能にする。コードを設計・再構成する場ではどこでもこの言葉と原則を使う。狙いは、呼び出し側のための Leverage、保守側のための Locality、そして全員のためのテスト可能性だ。

## Glossary

これらの用語は正確にそのまま使う。「component」「service」「API」「boundary」で置き換えるな。一貫した言葉を使うことがすべての要点だ。

**Module** — Interface と Implementation を持つあらゆるもの。意図的にスケール非依存にしている。関数、クラス、パッケージ、あるいは tier をまたぐスライスでもよい。_避ける_: unit, component, service。

**Interface** — 呼び出し側が module を正しく使うために知らねばならないすべて。型シグネチャだけでなく、不変条件、順序制約、error mode、必要な設定、性能特性も含む。_避ける_: API, signature（狭すぎる。型レベルの表層しか指さない）。

**Implementation** — module の内側にあるもの、そのコード本体。**Adapter** とは区別する。あるものは小さな Adapter に大きな Implementation を持つ場合（Postgres repo）もあれば、大きな Adapter に小さな Implementation を持つ場合（in-memory fake）もある。Seam が話題のときは「adapter」を、それ以外では「implementation」を使う。

**Depth** — Interface における Leverage。学ばねばならない Interface の単位あたり、呼び出し側（またはテスト）が行使できる振る舞いの量。大量の振る舞いが小さな Interface の背後にあるとき module は **deep** であり、Interface が Implementation とほぼ同じくらい複雑なとき **shallow** だ。

**Seam** _(Michael Feathers)_ — その場所を編集せずに振る舞いを変えられる箇所。module の Interface が存在する *位置*。Seam をどこに置くかは、その背後に何を置くかとは別の、それ自体独立した設計判断だ。_避ける_: boundary（DDD の bounded context と意味が衝突する）。

**Adapter** — Seam において Interface を満たす具体物。実体（中身が何か）ではなく *役割*（どのスロットを埋めるか）を表す。

**Leverage** — 呼び出し側が Depth から得るもの。学ぶ Interface の単位あたり、より多くの能力。1 つの Implementation が N 個の call site と M 個のテストにわたって元を取る。

**Locality** — 保守側が Depth から得るもの。変更、バグ、知識、検証が、呼び出し側に散らばるのではなく 1 箇所に集中する。1 度直せば、どこでも直る。

## Deep vs shallow

**deep module** = 小さな Interface + 大量の Implementation:

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**shallow module** = 大きな Interface + わずかな Implementation（避ける）:

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

Interface を設計するときは、こう問え:

- メソッドの数を減らせないか?
- パラメータを単純化できないか?
- もっと多くの複雑さを内側に隠せないか?

## Principles

- **Depth は Interface の性質であって、Implementation の性質ではない。** deep module は内部的には小さく、mock 可能で差し替え可能な部品から構成されていてよい。それらは単に Interface の一部ではないというだけだ。module は Interface における **external seam** に加えて、**internal seam**（その Implementation に閉じており、自身のテストで使う）を持てる。
- **削除テスト。** その module を削除したと想像する。複雑さが消え去るなら、それは pass-through だった。複雑さが N 個の呼び出し側にわたって再出現するなら、それは働きに見合っていた。
- **Interface が test surface だ。** 呼び出し側とテストは同じ Seam を横切る。Interface の *向こう側* をテストしたくなるなら、その module はおそらく形が間違っている。
- **1 つの Adapter は仮説的な Seam を意味する。2 つの Adapter は本物の Seam を意味する。** 何かが実際にそこをまたいで変化するのでない限り、Seam を導入するな。

## テスト可能性のための設計

良い Interface はテストを自然にする:

1. **依存を受け取れ、生成するな。**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **結果を返せ、side effect を生むな。**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **小さな表面積。** メソッドが少ない = 必要なテストが少ない。パラメータが少ない = テストのセットアップが単純。

## Relationships

- **Module** はちょうど 1 つの **Interface**（呼び出し側とテストに提示する表層）を持つ。
- **Depth** は **Module** の性質であり、その **Interface** に対して測る。
- **Seam** は **Module** の **Interface** が存在する場所だ。
- **Adapter** は **Seam** に位置し、**Interface** を満たす。
- **Depth** は呼び出し側のための **Leverage** と保守側のための **Locality** を生む。

## 却下した枠組み

- **Depth を Implementation の行数と Interface の行数の比とする**（Ousterhout）: Implementation を水増しするほど有利になってしまう。代わりに Leverage としての Depth を使う。
- **「Interface」を TypeScript の `interface` キーワードやクラスの public メソッドとする**: 狭すぎる。ここでの Interface は呼び出し側が知らねばならないあらゆる事実を含む。
- **「Boundary」**: DDD の bounded context と意味が衝突する。**Seam** か **Interface** と言え。

## さらに深く

- **依存を踏まえてクラスタを deepen する** — [DEEPENING.md](DEEPENING.md) を参照: 依存カテゴリ、Seam の規律、そして layer を重ねるのではなく置き換えるテスト手法。
- **代替 Interface を探索する** — [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) を参照: 並列サブエージェントを立ち上げて Interface を複数の極端に異なるやり方で設計し、Depth・Locality・Seam の配置で比較する。
