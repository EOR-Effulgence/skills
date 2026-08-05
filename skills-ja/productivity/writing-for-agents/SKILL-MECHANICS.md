# Skill mechanics

[`writing-for-agents`](SKILL.md) の skill 固有の branch: 文書が skill であるとき何が変わるか — frontmatter、invocation の選択、router skill。それ以外の書き方はすべて `SKILL.md` の汎用リファレンスにある。

## Invocation

2 つの選択肢があり、2 つの load をトレードする:

- **model-invoked** な skill は `description` を保持するため、agent が自律的に発火でき — 他の skill からも到達できる。自分でその名前をタイプすることも依然できる: model-invocation は常にユーザーからの到達を _含む_。description は agent による発見性を足すだけで、人間の到達を奪うことは決してない。description は skill の最上位の context pointer であり、常時ロードされ続けることを強いられる — 発見性と引き換えの恒久的な context load だ。中身がすべて reference である model-invoked な skill は、共有 reference の置き場でもある: 他の skill から invoke できるので、複数の skill が必要とする reference を 1 か所に置ける。仕組み: `disable-model-invocation` を省略し、トリガーの branch を担うモデル向け description を書く（`SKILL.md` のポインタ執筆ルールがそのまま適用される）。
- **user-invoked** な skill は description を agent の手の届く範囲から剥ぎ取る: その名前をタイプする人間だけが起動でき、他のどの skill も起動できない。context load はゼロだが、cognitive load を払う — それが存在することを覚えておくべき索引はあなた自身だ。仕組み: `disable-model-invocation: true` を設定する。すると `description` は人間向けになる — 一行の要約で、トリガーリストは剥がされる。

model-invocation を選ぶのは、agent 自身が skill に到達しなければならない場合、または別の skill が到達しなければならない場合だけにしろ。手動でしか発火しないなら user-invoked にして、context load を一切払うな。

2 つの user-invoked な skill が両方とも必要とする共有 reference は、そのどちらにも置けない — description が無いので、互いに相手を発火できないからだ。skill システムの外の素のファイルへ押し出せ: どの skill からでも指し示せる external reference だ。

## invocation で分割する

分割の invocation 側の切り口（sequence 側の切り口は `SKILL.md` にある）: それ単独で発火させるべき別個の leading word がある — 実際に自分のプロンプトで使うトリガー語だ — か、別の skill が到達しなければならないとき、model-invoked な skill として切り出せ。新しく常時ロードされる description の分だけ context load を払うので、その独立した到達性はその対価に見合わなければならない。

## Router skills

user-invoked な skill が覚えきれないほど増えたら、その積み上がった cognitive load は **router skill** で癒やす: 他の skill 群とそれぞれをいつ手に取るかを名指しする、1 つの user-invoked skill だ。人間が覚えるべき skill は多数ではなく 1 つになる。router はヒントを出せるだけで、決して skill を発火できない: user-invoked な skill には description が無いので、人間以外には何も到達できない。
