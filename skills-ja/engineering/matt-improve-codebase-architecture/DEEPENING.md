# Deepening

shallow な Module 群を、その依存関係を踏まえて安全に deep 化する方法。[LANGUAGE.md](LANGUAGE.md) の語彙 — **module**, **interface**, **seam**, **adapter** — を前提とする。

## 依存のカテゴリ

deepening 候補を評価するときは、その依存を分類する。カテゴリによって deep 化 Module を seam を越えてどうテストするかが決まる。

### 1. In-process

純粋計算、メモリ上の状態、I/O なし。常に deep 化可能 — Module をマージして、新しい interface 経由で直接テストする。adapter 不要。

### 2. Local-substitutable

ローカルなテスト代替物を持つ依存（Postgres なら PGLite、ファイルシステムなら in-memory Implementation）。代替物があれば deep 化可能。deep 化 Module はテストスイート内で代替物を走らせてテストする。seam は内部にあり、Module の外部 interface には port を出さない。

### 3. Remote but owned（Ports & Adapters）

ネットワーク境界をまたぐ自社サービス（マイクロサービス、内部 API）。seam に **port**（interface）を定義する。deep Module がロジックを所有し、トランスポートは **adapter** として注入される。テストは in-memory な adapter を使う。本番は HTTP/gRPC/queue の adapter を使う。

推奨の形: *「seam に port を定義し、本番用に HTTP adapter、テスト用に in-memory adapter を実装し、ネットワークをまたいでデプロイされているにもかかわらずロジックは 1 つの deep Module に収まる。」*

### 4. True external（Mock）

自分が制御できない第三者サービス（Stripe、Twilio など）。deep 化 Module は外部依存を注入された port として受け取り、テストでは mock adapter を提供する。

## Seam の規律

- **adapter 1 つでは仮定の seam、2 つで初めて本物。** 少なくとも 2 つの adapter が正当化されない限り（典型的には本番 + テスト）、port を導入しない。adapter が 1 つだけの seam はただの間接化（indirection）。
- **内部 seam vs 外部 seam。** deep Module は、interface にある外部 seam だけでなく、内部 seam（implementation に閉じた private、自分のテストが使う）も持てる。テストが使うからといって、内部 seam を interface 経由で露出してはいけない。

## テスト戦略: 重ねるのではなく置き換える

- shallow Module 上の旧 unit test は、deep 化 Module の interface におけるテストが揃った瞬間に無駄になる — 削除する。
- deep 化 Module の interface に対して新しいテストを書く。**interface こそがテスト面（test surface）。**
- テストは interface 経由で観測可能な結果を検証する。内部状態を検証しない。
- 内部リファクタを生き残るテストにする — テストはふるまいを記述し、implementation は記述しない。implementation が変わったときにテストも変えざるを得ないなら、それは interface の向こう側をテストしている。
