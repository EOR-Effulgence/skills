# いつ mock するか

**システム境界（system boundary）**でのみ mock する:

- 外部 API（決済、メール等）
- データベース（場合による — テスト DB を優先）
- 時刻 / 乱数
- ファイルシステム（場合による）

mock しないもの:

- 自分のクラス / Module
- 内部の協調オブジェクト
- 自分が制御できるもの

## mock しやすい設計

システム境界では、mock しやすい interface を設計する:

**1. dependency injection を使う**

外部依存を内部で生成せず、引数として渡す:

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 汎用 fetcher より SDK スタイルの interface を優先**

条件分岐で動く汎用関数 1 個ではなく、外部操作ごとに特化した関数を作る:

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK アプローチが意味するもの:
- 各 mock は 1 つの specific な shape を返す
- テストセットアップに条件分岐が不要
- どのエンドポイントを叩くテストか一目で分かる
- エンドポイントごとに型安全
