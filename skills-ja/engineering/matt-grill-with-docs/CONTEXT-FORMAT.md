# CONTEXT.md フォーマット

## 構造

```md
# {コンテキスト名}

{このコンテキストが何で、なぜ存在するかを 1〜2 文で。}

## Language

**Order**:
{用語の説明 1〜2 文}
_Avoid_: Purchase, transaction

**Invoice**:
配送後に顧客へ送られる支払い要求。
_Avoid_: Bill, payment request

**Customer**:
注文を行う個人または組織。
_Avoid_: Client, buyer, account
```

## ルール

- **意見を持て。** 同じ概念に複数の語が存在するなら、最良を 1 つ選び残りを「避けるべき別名」として列挙する。
- **衝突は明示的にフラグする。** 用語があいまいに使われているなら "Flagged ambiguities" で解決と共に呼び出す。
- **定義は引き締める。** 1〜2 文まで。何で**ある**か定義する。何を**する**かではない。
- **関係を示す。** 用語名を太字にし、自明な箇所では多重度を表現する。
- **このプロジェクト固有の用語だけを含める。** 一般プログラミング概念（タイムアウト、エラー型、ユーティリティパターン）はプロジェクトで多用していても入れない。追加前に問え: これはこのコンテキスト固有の概念か、一般プログラミング概念か。**前者だけ**入れる。
- **自然なまとまりが現れたら**サブ見出しで用語をグループ化。すべての用語が単一の凝集領域なら平リストで構わない。
- **対話例を書く。** 開発者とドメインエキスパートの会話で、用語が自然にどう絡むかを示し、関連概念間の境界を明らかにする。

## 単一 vs マルチコンテキスト

**単一コンテキスト（ほとんどのリポジトリ）:** ルートに `CONTEXT.md` 1 つ。

**マルチコンテキスト:** ルートの `CONTEXT-MAP.md` がコンテキストの所在と相互関係を列挙する:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 顧客注文の受付と追跡
- [Billing](./src/billing/CONTEXT.md) — 請求書発行と支払い処理
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 倉庫ピッキングと出荷管理

## Relationships

- **Ordering → Fulfillment**: Ordering が `OrderPlaced` イベントを発行、Fulfillment が消費してピッキング開始
- **Fulfillment → Billing**: Fulfillment が `ShipmentDispatched` を発行、Billing が消費して請求書生成
- **Ordering ↔ Billing**: `CustomerId` と `Money` の型を共有
```

スキルは構造を推論する:

- `CONTEXT-MAP.md` があれば、それを読んでコンテキストを見つける
- ルートに `CONTEXT.md` だけがあれば、単一コンテキスト
- どちらもなければ、最初の用語が固まったときにルート `CONTEXT.md` を遅延作成

複数コンテキストが存在するときは、現在の話題がどれに関連するか推論する。不明なら聞く。
