# いつモックするか

**システム境界**でのみモックする:

- 外部 API（決済、メール等）
- データベース（場合による — テスト DB を優先）
- 時刻 / 乱数
- ファイルシステム（場合による）

モックしないもの:

- 自分のクラス / Module
- 内部の協力者
- 自分が制御できるもの

## モックしやすい設計

システム境界では、モックしやすいインターフェースを設計する:

**1. dependency injection を使う**

外部依存を内部で生成せず、引数として渡す:

```typescript
// モックしやすい
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// モックしにくい
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 汎用 fetcher より SDK スタイルのインターフェースを優先**

条件分岐で動く汎用関数 1 個ではなく、外部操作ごとに特化した関数を作る:

```typescript
// GOOD: 各関数が独立にモック可能
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: モック内に条件分岐が必要になる
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK アプローチが優れている点:
- 各モックは 1 つの shape だけを返す
- テストセットアップに条件分岐が不要
- どのエンドポイントを叩くテストか一目で分かる
- エンドポイントごとに型安全
