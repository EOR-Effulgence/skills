# Language

このスキルが行うあらゆる提案に共通の語彙。これらの用語は**そのまま**使う — 「component」「service」「API」「boundary」に置き換えない。一貫した言語こそが本旨。

## 用語

**Module**
interface と implementation を持つもの。意図的にスケール非依存 — 関数・クラス・パッケージ・複数層をまたぐスライスのいずれにも等しく適用される。
_避ける_: unit, component, service。

**Interface**
呼び出し側が Module を正しく使うために知らねばならない一切。型シグネチャを含むが、不変条件・順序制約・エラーモード・必要な設定・性能特性も含む。
_避ける_: API, signature（狭すぎる — それらは型レベルの面だけを指す）。

**Implementation**
Module の内部 — コード本体。**Adapter** とは別物: あるものは大きな implementation を持つ小さな adapter（Postgres repo）にも、小さな implementation を持つ大きな adapter（in-memory fake）にもなりうる。seam が話題のときは「adapter」、それ以外では「implementation」に手を伸ばす。

**Depth**
interface での Leverage — 呼び出し側（あるいはテスト）が学ばねばならない interface 1 単位あたりで行使できるふるまいの量。**deep** な Module = 小さな interface の裏に大量のふるまいがある。**shallow** な Module = interface が implementation とほぼ同じ複雑さ。

**Seam** _(Michael Feathers より)_
その場所を編集せずに振る舞いを変えられる場所。Module の interface が「存在する」*位置*。seam をどこに置くかは独自の設計判断で、何を裏に置くかとは別物。
_避ける_: boundary（DDD の bounded context と重なって overload されている）。

**Adapter**
seam で interface を満たす具体物。*役割*（どのスロットを埋めるか）を記述し、*中身*（何が中にあるか）を記述しない。

**Leverage**
呼び出し側が depth から得るもの。学ばねばならない interface 1 単位あたりの能力が大きい。1 つの implementation が N 個の呼び出し箇所と M 個のテストにわたって元を取る。

**Locality**
保守側が depth から得るもの。変更・バグ・知識・検証が、呼び出し側に散らばらず 1 箇所に集まる。一度直せば全箇所が直る。

## 原則

- **Depth は interface の性質であって implementation の性質ではない。** deep な Module は内部的に小さく・モック可能で・差し替え可能な部品から構成されていてよい — それらが interface の一部でないというだけ。Module は **内部 seam**（implementation に閉じた private、自分のテストが使う）も持てるし、interface にある **外部 seam** も持てる。
- **Deletion test.** Module を削除したと想像する。複雑性が消えるなら、Module は何も隠していなかった（素通りだった）。複雑性が N 個の呼び出し側に再出現するなら、その Module は仕事をしていた。
- **interface こそがテスト面（test surface）。** 呼び出し側もテストも同じ seam を越える。interface の*向こう側*をテストしたいなら、たぶん Module の形が間違っている。
- **adapter 1 つでは仮定の seam、2 つで初めて本物。** 何かが実際に seam をまたいで varies しない限り、seam を導入しない。

## 関係

- **Module** はちょうど 1 つの **Interface** を持つ（呼び出し側とテストに見せている面）。
- **Depth** は **Module** の性質で、その **Interface** に対して測られる。
- **Seam** は **Module** の **Interface** が存在する場所。
- **Adapter** は **Seam** に座り **Interface** を満たす。
- **Depth** は呼び出し側に **Leverage** を、保守側に **Locality** を生む。

## 退ける枠組み

- **Depth = implementation 行数 / interface 行数の比** (Ousterhout): implementation を水増しすることに報奨を与える。代わりに「depth = leverage」を使う。
- **「Interface」を TypeScript の `interface` キーワードやクラスの public メソッドと同義とする**: 狭すぎる — ここでの interface は呼び出し側が知らねばならない一切の事実を含む。
- **「Boundary」**: DDD の bounded context と overload されている。**seam** か **interface** と言う。
