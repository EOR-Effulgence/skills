# Deepening

依存を踏まえて、shallow module のクラスタを安全に deepen する方法。[SKILL.md](SKILL.md) の語彙 — **module**、**interface**、**seam**、**adapter** — を前提とする。

## 依存カテゴリ

deepening の候補を評価するときは、その依存を分類する。カテゴリによって、deepen した module をその Seam をまたいでどうテストするかが決まる。

### 1. In-process

純粋な計算、in-memory な状態、I/O なし。常に deepen 可能 — module をマージし、新しい Interface を通して直接テストする。Adapter は不要。

### 2. Local-substitutable

ローカルなテスト代役を持つ依存（Postgres に対する PGLite、in-memory filesystem）。代役が存在すれば deepen 可能。deepen した module は、テストスイート内で代役を走らせてテストする。Seam は internal であり、module の external interface に port は置かない。

### 3. Remote but owned (Ports & Adapters)

ネットワーク境界の向こうにある自前のサービス（マイクロサービス、内部 API）。Seam に **port**（interface）を定義する。deep module がロジックを所有し、transport は **adapter** として注入する。テストは in-memory adapter を使う。本番は HTTP/gRPC/queue adapter を使う。

推奨の形: *「Seam に port を定義し、本番向けに HTTP adapter を、テスト向けに in-memory adapter を実装する。そうすればネットワークをまたいでデプロイされていても、ロジックは 1 つの deep module に収まる。」*

### 4. True external (Mock)

自分では制御できないサードパーティサービス（Stripe、Twilio など）。deepen した module は外部依存を注入される port として受け取り、テストは mock adapter を提供する。

## Seam の規律

- **1 つの Adapter は仮説的な Seam を意味する。2 つの Adapter は本物の Seam を意味する。** 少なくとも 2 つの Adapter（典型的には本番 + テスト）が正当化されない限り、port を導入するな。Adapter が 1 つだけの Seam はただの間接参照だ。
- **Internal seam vs external seam。** deep module は Interface における external seam に加えて、internal seam（その Implementation に閉じており、自身のテストで使う）を持てる。テストが使うからというだけで internal seam を Interface を通して露出させるな。

## テスト戦略: layer を重ねず、置き換える

- shallow module に対する古い unit テストは、deepen した module の Interface でのテストが存在すれば無駄になる — 削除する。
- deepen した module の Interface で新しいテストを書く。**Interface が test surface だ**。
- テストは内部状態ではなく、Interface を通した観測可能な結果に対してアサートする。
- テストは内部の refactor を生き延びるべきだ — テストは Implementation ではなく振る舞いを記述する。Implementation が変わったときにテストも変えねばならないなら、それは Interface の向こう側をテストしている。
