# テスト可能性のためのインターフェース設計

良いインターフェースはテストを自然にする:

1. **依存は受け取れ、生成するな**

   ```typescript
   // テスト可能
   function processOrder(order, paymentGateway) {}

   // テストしづらい
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **結果を返せ、副作用を起こすな**

   ```typescript
   // テスト可能
   function calculateDiscount(cart): Discount {}

   // テストしづらい
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **小さな表面積**
   - メソッドが少ない = 必要なテストが少ない
   - 引数が少ない = テストセットアップがシンプル
