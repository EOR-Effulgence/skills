# 良いテストと悪いテスト

## 良いテスト

**統合スタイル（Integration-style）**: 内部のモックではなく、本物のインターフェースを経由してテストする。

```typescript
// GOOD: 観測可能なふるまいをテスト
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特徴:

- ユーザー / 呼び出し側が気にするふるまいをテスト
- 公開 API のみを使う
- 内部リファクタを生き延びる
- 「何を」記述し、「どう」は記述しない
- 1 テストあたり論理的アサーション 1 個

## 悪いテスト

**実装詳細テスト（Implementation-detail tests）**: 内部構造に密結合している。

```typescript
// BAD: 実装の詳細をテスト
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危険信号:

- 内部の協力者（collaborator）をモックしている
- private メソッドをテストしている
- 呼び出し回数 / 順序にアサートしている
- ふるまいが変わっていないのにリファクタで落ちる
- テスト名が「どう」を記述している（「何を」ではない）
- インターフェース経由ではなく外部手段で検証している

```typescript
// BAD: インターフェースを迂回して検証
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: インターフェース経由で検証
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```
