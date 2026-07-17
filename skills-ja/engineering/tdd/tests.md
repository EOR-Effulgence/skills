# 良いテストと悪いテスト

## 良いテスト

**統合スタイル（Integration-style）**: 内部の mock ではなく、本物の interface を経由してテストする。

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特徴:

- ユーザー / 呼び出し側が気にする振る舞いをテストする
- public API のみを使う
- 内部の refactor を生き延びる
- 「何を（WHAT）」を記述し、「どう（HOW）」は記述しない
- 1 テストあたり論理的アサーション 1 個

## 悪いテスト

**実装詳細テスト（Implementation-detail tests）**: 内部構造に密結合している。

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危険信号:

- 内部の協調オブジェクトを mock している
- private メソッドをテストしている
- 呼び出し回数 / 順序にアサートしている
- 振る舞いが変わっていないのに refactor で落ちる
- テスト名が「何を」ではなく「どう」を記述している
- interface 経由ではなく外部手段で検証している

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**同語反復テスト（Tautological tests）**: 期待値が実装を言い換えているだけなので、構造上必ずパスする。

```typescript
// BAD: Expected value is recomputed the way the code computes it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: Expected value is an independent, known literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
