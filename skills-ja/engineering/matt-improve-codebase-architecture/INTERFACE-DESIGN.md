# Interface Design

選ばれた deepening 候補について代替 interface を探索したい場合は、この並列 sub-agent パターンを使う。Ousterhout の "Design It Twice" に基づく — 最初の案が最良である見込みは低い。

[LANGUAGE.md](LANGUAGE.md) の語彙 — **module**, **interface**, **seam**, **adapter**, **leverage** — を使う。

## プロセス

### 1. 問題空間をフレーミングする

sub-agent を生やす前に、選ばれた候補について問題空間のユーザー向け説明を書く:

- 新しい interface が満たすべき制約
- 依存するもの、そしてそれらがどのカテゴリに属するか（[DEEPENING.md](DEEPENING.md) 参照）
- 制約を地に足を付けるための、ラフな例示コードスケッチ — 提案ではなく、制約を具体化する手段に過ぎない

これをユーザーに見せ、ただちに Step 2 に進む。ユーザーが読みながら考えている間に sub-agent たちが並列で働く。

### 2. sub-agent を生やす

Agent ツールで 3 つ以上の sub-agent を並列に生やす。各 agent は deep 化 Module について**根本的に異なる** interface を作らねばならない。

各 sub-agent には別の技術ブリーフ（ファイルパス、coupling の詳細、[DEEPENING.md](DEEPENING.md) からの依存カテゴリ、seam の裏に何が座るか）でプロンプトする。ブリーフは Step 1 のユーザー向け問題空間説明とは独立。各 agent に異なる設計制約を渡す:

- Agent 1: 「interface を最小化 — エントリポイントは 1〜3 個。エントリポイントあたりの leverage を最大化」
- Agent 2: 「柔軟性を最大化 — 多様なユースケースと拡張をサポート」
- Agent 3: 「最も一般的な呼び出し側に最適化 — デフォルトケースを自明にする」
- Agent 4（該当時）: 「seam をまたぐ依存については ports & adapters を中心に設計」

ブリーフには [LANGUAGE.md](LANGUAGE.md) の語彙と CONTEXT.md の語彙の両方を含める。各 sub-agent がアーキテクチャ言語とプロジェクトのドメイン言語に整合した命名をするように。

各 sub-agent の出力:

1. interface（型、メソッド、パラメータ — 加えて不変条件、順序、エラーモード）
2. 呼び出し側がどう使うかを示す使用例
3. seam の裏に implementation が何を隠すか
4. 依存戦略と adapter（[DEEPENING.md](DEEPENING.md) 参照）
5. トレードオフ — leverage が高い箇所、薄い箇所

### 3. 提示と比較

設計を順に提示し、ユーザーが 1 つずつ吸収できるようにしてから、散文で比較する。**depth**（interface での Leverage）、**locality**（変更がどこに集まるか）、**seam の位置**で対比する。

比較したあとは、自分の推奨を出す: どの設計が最強だと思うか、なぜか。異なる設計の要素が組み合わさるとうまく行きそうなら、ハイブリッドを提案する。意見を持て — ユーザーが欲しているのは強い読みであって、メニューではない。
