# CONTEXT.md フォーマット

## 構造

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## ルール

- **意見を持て。** 同じ概念に複数の語が存在するなら、最良の一つを選び、他は `_Avoid_` の下に挙げろ。
- **定義を締めろ。** 最大でも 1〜2 文。それが何を *する* かではなく、何で *ある* かを定義しろ。
- **この project の context に固有の用語だけを含めろ。** 一般的なプログラミング概念(timeout、error type、utility パターン)は、project がそれらを多用していても含めない。用語を追加する前に問え ── これはこの context に固有の概念か、それとも一般的なプログラミング概念か? 前者だけが含まれる。
- **自然なまとまりが現れたら、用語を subheading の下にグループ化しろ。** すべての用語が単一の凝集した領域に属するなら、フラットなリストで構わない。

## 単一 context vs 複数 context の repo

**単一 context(ほとんどの repo):** repo root に `CONTEXT.md` が一つ。

**複数 context:** repo root の `CONTEXT-MAP.md` が、各 context・その所在・相互の関係を列挙する:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

スキルはどの構造が当てはまるかを推論する:

- `CONTEXT-MAP.md` が存在するなら、それを読んで context を見つける
- root `CONTEXT.md` だけが存在するなら、単一 context
- どちらも存在しないなら、最初の用語が解決したときに root `CONTEXT.md` を lazy に作る

複数の context が存在するとき、現在の話題がどれに関係するかを推論しろ。不明確なら、尋ねろ。
