---
name: writing-great-skills
description: skill をうまく書き・編集するためのリファレンス。skill を予測可能にする語彙と原則をまとめる。Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable. 日本語トリガー例 / "skill の書き方" "skill を良くしたい" "skill をレビューして" / English / "how to write a skill" "make this skill predictable"
disable-model-invocation: true
---

skill は、確率的なシステムから決定性を絞り出すために存在する。**Predictability** — エージェントが毎回同じ _process_ を取ること、同じ出力を生むことではない — が根本の美徳であり、以下のすべてのレバーはこれに奉仕する。

**太字の用語** は [`GLOSSARY.md`](GLOSSARY.md) で定義されている。完全な意味はそちらで引く。

## Invocation

2 つの選択肢があり、それぞれ異なるコストを払う:

- **model-invoked** な skill は **description** を保持するため、エージェントが自律的に発火でき _かつ_ 他の skill からも到達できる（自分でその名前をタイプすることも依然できる）。これは **context load** に寄与する — description は毎ターン window に居座る。仕組み: `disable-model-invocation` を省略し、豊富なトリガー表現（"Use when the user wants…, mentions…"）を備えたモデル向け description を書く。
- **user-invoked** な skill は description をエージェントの手の届く範囲から剥ぎ取る: その名前をタイプするあなただけが起動でき、他のどの skill も起動できない。context load はゼロだが、代わりに **cognitive load** を払う: それが存在することを覚えておくべき索引は _あなた_ 自身だ。仕組み: `disable-model-invocation: true` を設定する。すると `description` は人間向けになる — 一行の要約で、トリガーリストは剥がされる。

model-invocation を選ぶのは、エージェント自身が skill に到達しなければならない場合、または別の skill が到達しなければならない場合だけにする。手動でしか発火しないなら、user-invoked にして context load を一切払うな。

user-invoked な skill が覚えきれないほど増えたら、積み上がった cognitive load は **router skill** で癒やす: 他の skill 群とそれぞれをいつ手に取るかを名指しする、1 つの user-invoked skill だ。

## Writing the description

model-invoked な **description** は 2 つの仕事をこなす — skill が何であるかを述べること、そしてそれを発火させるべき **branches** を列挙することだ。あらゆる語が **context load** を増やすので、description は本文よりもさらに厳しい pruning に値する:

- **skill の leading word を前に置く** — description こそが、その語が invocation の仕事をする場所だ。
- **1 branch につき 1 トリガー。** 単一の branch を言い換えただけの同義語は **duplication** だ — "build features using TDD … asks for test-first development" は 1 つの branch を二度書いている。それらは collapse させ、本当に別個の branch だけを残せ。
- **本文に既にある素性は削れ。** description はトリガーと、"when another skill needs…" のような到達句だけに留めろ。

## Information hierarchy

skill は 2 つのコンテンツ型 — **steps** と **reference** — から作られ、それらは自由に混ざる: skill は全部 steps でも、全部 reference でも、両方でもよい。核心となる判断は、どちらを使うか、そして各要素が **information hierarchy** のどこに位置するかだ。これはエージェントがその素材をどれだけ即座に必要とするかで順位づけした梯子である:

1. **In-skill step** — `SKILL.md` 内の順序づけられたアクション、最上位の階層: エージェントが何を、どの順で行うか。各 step は **completion criterion** で終わる。これはエージェントに作業が完了したことを告げる条件だ。それを _checkable_（エージェントは完了と未完了を見分けられるか？）にし、重要な場面では _exhaustive_（"change list を作れ" ではなく "変更されたすべての model を漏れなく扱う"）にせよ — 曖昧な criterion は **premature completion** を招く。
2. **In-skill reference** — `SKILL.md` 内の定義・ルール・事実で、必要に応じて参照される。しばしば正当にフラットな peer-set（レビューの全ルールが同一段に並ぶ）になる — これは良い配置であって、smell ではない。_この skill は全部 reference だ。_
3. **External reference** — `SKILL.md` から別ファイルへ押し出された reference で、**context pointer** から到達され、ポインタが発火したときにのみロードされる。（_disclosed_ な reference — `GLOSSARY.md` のような、依然 skill の一部である兄弟ファイル — から、skill システムの外に存在しどの skill からでも指し示せる完全な **external reference** までの幅を持つ。）

要求の厳しい completion criterion は徹底した **legwork** — エージェントが作業の内側で行う掘り下げ — を駆動する。skill が steps を持つかどうかに関わらずだ。というのも "every step done" が一連の並びを縛るのと同じように、"every rule applied" はフラットな reference を縛るからだ。

下へ押し込む量が少なすぎれば頂点が膨れ、多すぎればエージェントが実際に必要とする素材を隠してしまう。この緊張こそが判断のすべてだ。

**Progressive disclosure** とは梯子を下る動き — `SKILL.md` からリンクされたファイルへ出すこと — であり、それによって頂点は読みやすいまま保たれる。仕組み: skill フォルダ内のリンクされた `.md` ファイルで、その中身にちなんで名付ける（この skill は完全な定義を `GLOSSARY.md` へ disclose している）。一部の skill は複数の使われ方をし、その別個の使われ方それぞれが **branch** だ — 異なる実行が skill の中の異なる経路を辿る。branching は最も明快な disclosure の判定基準だ: あらゆる branch が必要とするものは inline し、一部の branch しか到達しないものはポインタの背後へ押しやる。素材にいつ、そしてどれだけ確実にエージェントが到達するかを決めるのは、**context pointer** の _文言_ であって、その指し先ではない。

梯子が各要素を _どこまで下に_ 置くかを決めるのに対し、**co-location** はそこに置かれた後 _その隣に何が並ぶか_ を決める: ある概念の定義・ルール・注意点を散らばらせず 1 つの見出しの下にまとめ、一部を読めばその隣人たちも連れてくるようにせよ。

## When to split

**Granularity** とは skill をどれだけ細かく分割するかであり、どの切り分けも 2 つの load のいずれかを消費するので、切り分けがそれに値するときだけ分割せよ。2 種類の切り分けがある:

- **By invocation** — それ単独で発火させるべき明確な **leading word** があるとき、または別の skill が到達しなければならないとき、**model-invoked** な skill を切り出す。新しく常時ロードされる **description** の分だけ **context load** を払うので、その独立した到達性は見合うものでなければならない。
- **By sequence** — まだ先にある steps（ある step の **post-completion steps**）が、目の前の step を急がせる（**premature completion**）ようエージェントを誘惑するとき、一連の **steps** を分割する。それらを視界の外に置くと、エージェントは現在のタスクにより多くの **legwork** を注ぐようになる。

## Pruning

それぞれの意味を **single source of truth** に保て: 唯一の権威ある場所に置けば、振る舞いの変更は一箇所の編集で済む。

あらゆる行を **relevance** の観点で点検せよ: それは今も skill の働きに関わっているか？

次に **no-ops** を、行単位だけでなく文単位で狩れ: 各文を単独で no-op テストにかけ、落ちたらその文から語を削るのではなく文まるごと削除せよ。攻めろ — 落ちた散文のほとんどは書き直すのではなく消すべきだ。

## Leading words

**leading word** とは、モデルの pretraining に既に住んでいる凝縮された概念で、エージェントが skill を実行しながらそれで思考するものだ（例: _lesson_、_fog of war_、_tracer bullets_）。テキスト全体で繰り返され（ただし必ずしもそうではない — 強い leading word は一度だけで足りることもある）、分散した定義を蓄積し、モデルが既に持つ prior を動員することで、最小のトークンで振る舞いの領域全体を錨づける。

これは predictability に二度奉仕する。本文では _execution_ を錨づける: その語が現れるたびに、エージェントは同じ振る舞いに手を伸ばす。description では _invocation_ を錨づける: 同じ語があなたのプロンプト・ドキュメント・コードに住んでいると、エージェントはその共有言語を skill に結びつけ、より確実に発火させる。

skill を leading word を使うようリファクタリングする機会を狩れ。三つ組が三箇所で綴られている（**duplication**）、description が 1 つの考えを示すために一文を費やしている — どれも単一のトークンへと **collapse** させてくれと懇願している一節だ。例:

- "fast, deterministic, low-overhead" → _tight_ — 1 つの性質がフェーズをまたいで言い直されている — を単一の pretrained な語へ（_tight_ な loop）。
- "a loop you believe in" → _red_ — 曖昧なゲートを二値の観測可能な状態へ変換する（loop はバグに対して _red_ になるか、ならないかだ）。

二重に勝てる: トークンが減り、_かつ_ エージェントが思考を掛ける鉤がより鋭くなる。あらゆる skill には leading word が退けられる言い直しが積まれていると想定し、それを探しに行け。

## Failure modes

これらを使って、ユーザーが skill で抱えているかもしれない問題を診断せよ。

- **Premature completion** — step が本当に完了する前に終えてしまうこと。注意が _完了していること_ の方へ滑る。防御は順番に: まず completion criterion を鋭くする（安価で局所的）。それが本質的に曖昧で _かつ_ 急ぎが観測される場合に限り、分割によって post-completion steps を隠す（sequence の切り分け）。
- **Duplication** — 同じ意味が複数の場所にあること。保守とトークンのコストを払わせ、ある意味の梯子上での目立ち方を本来の順位を超えて膨張させる。
- **Sediment** — 追加は安全に感じ削除は危険に感じるために沈殿する、古びた層。pruning の規律を持たないあらゆる skill の既定の末路。
- **Sprawl** — あらゆる行が生きていて一意であってさえ、単純に長すぎる skill。可読性と保守性を損ない、トークンを浪費する。治療は梯子だ: **reference** をポインタの背後へ disclose し、**branch** または sequence で分割して各経路が必要なものだけを運ぶようにする。
- **No-op** — モデルが既定で既に従っている行。何も言わないのに load を払う。テスト: それは既定に対して振る舞いを変えるか？ 弱い leading word（エージェントが既にそこそこ徹底的なのに _be thorough_）は no-op だ。修正はより強い語（_relentless_）であって、別の技法ではない。
- **Negation** — 禁止による舵取りは裏目に出る: _don't think of an elephant_ は象を名指しし、それを減らすどころか手に取りやすくする。**positive** をプロンプトせよ — 目標の振る舞いを述べ、禁じたい方を決して口にしないようにする。禁止は positive に言い換えられないハードなガードレールとしてのみ残し、その場合でも代わりに何をすべきかと対にせよ。
