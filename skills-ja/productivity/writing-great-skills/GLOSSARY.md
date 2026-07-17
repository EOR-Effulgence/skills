# Glossary — Building Great Skills

skill を優れたものにする要因のドメインモデル。skill は確率的なシステムから決定性を絞り出すために存在し、その根本の美徳は **Predictability** であって、以下のすべての用語はそれに対するレバーだ。これは [`writing-great-skills`](SKILL.md) の disclosed な reference である。

用語は軸ごとにまとめてある: **Invocation**（skill にどう到達するか）、**Information Hierarchy**（そのコンテンツをどう配置するか）、**Steering**（エージェントの実行時の振る舞いをどう形づくるか）、**Pruning**（どう無駄なく保つか）。各 **failure mode** はそれを治すレバーの隣に置かれ、_failure mode_ とタグ付けされている。

いずれかの定義中の **太字の用語** は、それ自体がこの glossary で定義されている。見出しから探せ。

## Predictability

skill がエージェントを毎回同じ _やり方_ で振る舞わせる度合い — 同じ process であって、同じ出力ではない（brainstorming の skill は _予測どおりに_ 発散すべきだ。そのトークンは変わるが、振る舞いは変わらない）。他のすべての用語が奉仕する根本の美徳 — コストや保守性はその症状であって、競合相手ではない。

_Avoid_: consistency, reliability, robustness, output-determinism

## Invocation

skill にどう到達するか — そしてその選択に対して払う 2 つの load。

### Model-Invoked

**description** フィールドを保持する skill で、エージェントがそれを見て自律的に発火でき — かつ人間も依然その名前をタイプできるため、model-invocation は常に user の到達性を _含む_。model 限定の状態は存在しない: description はエージェントの発見可能性を _足す_ だけで、人間のそれを取り除くことは決してない。その発見可能性と引き換えに、毎ターン恒久的な **context load** を払う。他の skill からも到達可能だ。エージェントから発見可能にする description が、そのまま起動可能性を与えるからだ。コンテンツが全部 **reference** の model-invoked な skill は、共有 reference の住処にもなる: 別の skill がそれを起動できるので、複数の skill が必要とする reference が一箇所に住む。model-invocation を選ぶのは、エージェント自身が skill に到達しなければならない場合だけにする。手動でしか発火しないなら、description を落として context load を一切払うな。

_Avoid_: ability, tool, capability

### User-Invoked

**description** を剥ぎ取られた skill — エージェントには見えず、その名前をタイプする人間だけが到達できる（**model-invoked** が user-_かつ_-agent なのに対し、こちらは user-_限定_）。エージェントからの発見可能性を、ゼロの **context load** と引き換えにする。description を持たないので、人間以外の何ものも到達できない: 他のどの skill も発火させられない。

_Avoid_: procedure, workflow, command

### Description

skill の機械可読なトリガーであり、**model-invoked** な skill が常時ロードし続けることを強いられる唯一の **context pointer**。その存在それ自体が invocation の軸だ: 保持すれば skill は model-invoked（かつ他の skill から到達可能）になり、削除すれば **user-invoked** になって人間だけが到達できる。model-invoked な skill の **context load** の源。

_Avoid_: frontmatter, summary

### Context Pointer

エージェントの context に保持される参照で、context 外のある素材を名指しし、それに到達する条件を符号化したもの。**description** は最上位の context pointer（context window → skill）であり、disclosed なファイルへのポインタは 1 段下の同じ対象だ。エージェントが _いつ_ 到達するか — そして _どれだけ確実に_ 到達するか — を決めるのは、指し先ではなくその文言である。弱く書かれたポインタの背後にある必携の指し先は variance のバグだ: まず文言を直し、それでも鋭くならない場合にのみ素材を inline せよ。

_Avoid_: link, reference, import

### Context Load

**model-invoked** な skill がエージェントの context window に課すコスト — 常時ロードされるその **description** が、トークンと注意の両方を費やす。**user-invoked** な skill が description を持たないことで逃れているもの。そして、より多くの model-invoked な skill へ分割することへのブレーキ。

_Avoid_: token cost, context bloat

### Cognitive Load

**user-invoked** な skill が人間に課すコスト — 頭の中に抱えておかねばならないもの: どの skill が存在し、それぞれをいつ手に取るか（人間が索引だ）。**model-invocation** がエージェントから発見可能になることで取り除くもの。そして、より多くの user-invoked な skill へ分割することへのブレーキ。最小化すべきコストではない: それは人間のエージェンシーの対価であり、一部の skill が user-invoked のままである理由だ。人間の判断が重要な場所では費やし、重要でない場所では取り除け。

_Avoid_: human index, burden, overhead

### Router Skill

他の user-invoked な skill 群を指し示すことを仕事とする **user-invoked** な skill — それぞれと、いつ手に取るかを名指しし — 人間が覚えるべき skill を多数ではなく 1 つにする。ほのめかすことしかできず、決して発火させられない: user-invoked な skill は **description** を持たないので、人間以外の何ものも到達できないからだ。user-invoked な skill が増殖したときの **cognitive load** の治療薬。

_Avoid_: dispatcher, menu, registry, index, router procedure

### Granularity

skill をどれだけ細かく分割するか。より細かい分割は 2 つの load のいずれかを消費する: より多くの **model-invoked** な skill は **context load** を消費し（より多くの description が window を混雑させ注意を奪い合う）、より多くの **user-invoked** な skill は **cognitive load** を消費する（人間が覚え手に取るものが増える）。分割を導く切り分けは 2 種類。**invocation** による切り分けでは、それを発火させる明確な **leading word** — あなたが実際にプロンプトで使うトリガー語 — があるところで model-invoked な skill を切り出す。**sequence** による切り分けでは、ある step の **post-completion steps** を隠す必要があるところで一連の **steps** を分割する。それを自身の context に隔離すると後続がクリアされるからだ。逆に注意せよ: sequence を統合すると各 step の post-completion steps が後続に露出し、premature completion を招く。

_Avoid_: chunking, modularity

## Information Hierarchy

skill のコンテンツをどう配置するか、そして各要素が梯子のどこまで下に位置するか。

### Information Hierarchy

skill のコンテンツを、エージェントがどれだけ即座に必要とするかで順位づけしたもの — 2 つの切り分けから生まれる単一の梯子: ファイル内かポインタの背後か、そして step か reference か。その段は:

- **Steps** — ファイル内、最上位
- **Reference**、ファイル内 — 二次
- **Reference**、disclosed — **context pointer** の背後

**steps** を持たない skill は下 2 段だけを使う — しばしば正当にフラットな peer-set（例: レビューの全ルールが同一段に並ぶ）になり、これは良い配置であって smell ではない。この階層は invocation とは独立している: skill は全部 steps でも、全部 reference でも、両方でも、model- でも user-invoked でもよい。skill が steps を持つとき、disclose すべきファイル内 reference はそれらを埋もれさせ、注意を向けるかどうかをコイン投げに変える — 単なる可読性のレバーではなく variance のレバーだ。梯子の頂点は読みやすく保て。押し下げられるものは何でも押し下げろ。

_Avoid_: structure, organization, layout

### Steps

エージェントが実行する順序づけられたアクション — skill がそれを持つとき、コンテンツの最上位の階層であり、SKILL.md にその場所を勝ち取る部分だ。すべての skill が steps を持つわけではない: skill は全部 steps（`tdd`）でも、全部 **reference**（レビュー）でも、両方でもよく、invocation とは独立している。すべての step は **completion criterion** で終わる。明確か曖昧かはさておき。

_Avoid_: workflow, instructions, choreography

### Reference

エージェントが必要に応じて参照する素材 — 定義・事実・パラメータ・例・条件つき指示。skill が **steps** を持つときはそれに従属し、持たないときはコンテンツ全体になる。あるいは、どの skill の外にも住む — **External Reference** を見よ。**context pointer** 経由で到達され、**progressive disclosure** の第一候補。

_Avoid_: supporting material, docs, background

### External Reference

skill システムの外に住む **reference** — **description** も **steps** も持たず、起動不可能な素のファイル — で、どの skill からでも指し示せる。単独で発火する必要のない共有 reference の住処であり、2 つの **user-invoked** な skill が使える唯一の共有の住処だ。どちらも description を持たず、したがって互いを発火させられないからだ。

_Avoid_: doc, resource, knowledge base

### Progressive Disclosure

**reference** を梯子の下へ移すこと — SKILL.md から出して **context pointer** の背後へ — であり、それによって頂点は読みやすいまま保たれる。主にトークンの最適化ではない。**information hierarchy** を守る手段だ。**branching** によって認可される: 一部の branch しか必要としないものを disclose し、あらゆる経路が必要とするものは inline せよ。そして必携の素材でポインタが不確実に発火するなら、その文言を鋭くし、それでも失敗する場合にのみ inline へ引き戻せ。

_Avoid_: lazy loading, chunking

### Co-location

エージェントが同時に必要とする素材を 1 つの場所に保つこと — ある概念の定義・ルール・注意点を、ファイル中に散らばらせず単一の見出しの下に — それによって一部を読めばその隣人たちも連れてくる。**Information Hierarchy** のファイル内での相棒: 階層は各要素が _どこまで下に_ 位置するかを順位づけし、co-location はそこに置かれた後 _その隣に何が並ぶか_ を決める。**reference** の一群の正しいフォーマットに公式はない。判定基準は、skill がエージェントのために書かれたドキュメントのように読めることであり、まとめられた素材はそう読めるが散らばった素材はそう読めない。**Duplication** とは異なる: あちらは 1 つの意味を 2 箇所で繰り返すが、こちらは単一の意味を多数に断片化させる。

_Avoid_: grouping, clustering, cohesion

### Sprawl

_Failure mode._ 単純に長すぎる skill — SKILL.md の行数が多すぎる — 古びているか繰り返されているかとは独立している。全部が生きていて全部が一意な skill でさえ sprawl しうる。可読性（エージェントは行動できるまでより多くを掻き分け、注意が超過分に薄まる）、保守性（余分な行はどれも **relevant** に保つべきものが 1 つ増える）、そしてトークンのコストを払う。治療は **information hierarchy** だ: **reference** を **context pointer** の背後へ押し下げ、**branch** または sequence で分割して各経路が必要なものだけを運ぶようにする。**sediment**（古びた蓄積による長さ）や **duplication**（繰り返された意味による長さ）とは異なる — sprawl は原因が何であれ、長さそのものだ。

_Avoid_: bloat, length, size, verbosity

## Steering

エージェントの実行時の振る舞いを **Predictability** へ向けて形づくるレバー。

### Branch

skill が起動されうる別個の道 — skill が扱う 1 つのケース — であり、異なる実行がその中の異なる経路を辿る。多くの step を持つ skill は多くの branch を運びうる。線形なものは 1 つも持たない。

_Avoid_: path, case, fork

### Leading Word

凝縮された概念 — _Leitwort_ とも呼ばれる — で、モデルの pretraining に既に住んでおり、エージェントが skill を実行しながらそれで思考するもの。モデルが既に持つ prior を呼び出すことで、可能な限り少ないトークンで振る舞いの原則を符号化する（例: _lesson_、_proximal zone of development_、_fog of war_、_tracer bullets_）。文としてではなくトークンとして繰り返され、skill 全体にわたって分散した定義を蓄積し、振る舞いの領域全体を錨づける。自分で語を造ることも、明確に定義すれば機能するが、でっち上げた語は prior を何も呼び出さない — pretrained な語がただで与えるものを、定義トークンで払うことになる。まず既存の語に手を伸ばせ。

leading word は **predictability** に二度奉仕する。本文では **execution** を錨づける — その概念が現れるたびにエージェントは同じ振る舞いに手を伸ばし、フラットな reference の内側では、探すべき種類のものへ注意を絞り込み、毎回正しいチェックを呼び出す。**description** では **invocation** を錨づける — しかも skill の内側にとどまらない: 同じ語があなたのプロンプト・ドキュメント・コードベースに住んでいると、エージェントはその共有言語を skill に結びつけ、より確実に発火させる。その skill を使いたいときに実際に使う leading word で description を書け。

_Avoid_: keyword, term, motif

### Completion Criterion

エージェントに 1 単位の作業が完了したことを告げる条件 — それが照らして判断する目標。2 つの性質がこれを単なる品質ではなくレバーにする。その **clarity**（エージェントは完了と未完了を見分けられるか？）は **premature completion** に抗する — 曖昧な境界（"understanding reached"）はエージェントに完了を宣言させ次の step へ滑らせる。この軸が噛みつくには _steps_ が要る。premature completion は step 間の失敗だからだ。その **demand**（どれだけ要求するか）は **legwork** を設定する — "変更されたすべての model を漏れなく扱う" は "change list を作れ" がしないところで徹底した作業を強いる — そしてこの軸は step 束縛的ではない: フラットな reference の一群をも縛りうるので、steps を持たない skill でも網羅性の基準（"every rule applied"）を運べる。最強の criterion は checkable かつ exhaustive の両方だ。

_Avoid_: done condition, exit condition, stopping rule

### Legwork

エージェントが単一の step の内側で舞台裏で行う作業 — ファイルを読み、コードベースを探索し、変更を加え、ユーザーに押し付けずに必要なものを掘り出すこと。step 構造の下に住む: 決して独自の step としては書かれず、文言の中に潜み、skill ではなくエージェントによって制御される。**post-completion steps** の step 間の引力に対する、step 内の対応物。**leading word**（_comprehensive_、_thorough_）や、作業を exhaustive であれと要求する **completion criterion** — フラットな reference に適用された demand 軸を含み、これがフラットな reference の skill にそのすべての段を覆わせる原動力だ — によって高められる。その demand が欠けているとき、または **premature completion** が step を途中で断ち切るとき、痩せていく。

_Avoid_: scope, effort, diligence, coverage

### Post-Completion Steps

現在の step に続く **steps**。可視だと、それらはエージェントを前方の **premature completion** へと引っ張る — 見えるものが多いほど引きは強い。防御は、一連の steps を 2 つに分割してそれらを隠すことだ。

_Avoid_: horizon, fog of war, lookahead

### Premature Completion

_Failure mode._ 現在の step が本当に完了する前に終えてしまうこと。エージェントの注意が作業ではなく完了していることの方へ滑るからだ。step 間の失敗: 発生には **steps** が要る — steps を持たない skill が早々にやめるのは premature completion ではなく、満たされない demand の下での痩せた **legwork** だ。2 つの力の綱引き: 可視の **post-completion steps**（前方への引き）と、**completion criterion** の clarity（抵抗 — 鋭く checkable な境界は持ちこたえ、曖昧なものは屈する）。曖昧さが必要条件だ: 鋭い境界は後続の step が何個見えていようと引きに抗するので、決して急がない step は防御を要さない。急ぐ step を持ちこたえさせるレバーは 2 つあるが、順番に手を伸ばせ: **まず境界を鋭くする** — 局所的で安価だ。criterion が本質的に曖昧で _かつ_ 実際に急ぎを観測したときにのみ、**後続の step を隠す** — そして隠すことは実際の context 境界をまたぐときにのみ機能する（user-invoked な受け渡しか subagent のディスパッチ。inline の model-invoked な呼び出しは後続の step を context に残し、何もクリアしない）。痩せた legwork の一因ではあるが、それとは別物だ: legwork は step が完全に完了まで走っても痩せうる。

_Avoid_: premature closure, the rush, rushing, shortcutting

### Negation

_Failure mode._ 禁止による舵取り — エージェントに何を _しない_ かを告げること — であり、これは禁じられた振る舞いを context に引きずり込み、それを減らすどころか _より_手に取りやすくする。_Don't think of an elephant_、すると象しか存在しなくなる。_never write verbose comments_、すると冗長さこそエージェントがたった今読んだパターンだ。negation は弱い修飾語で、強く活性化した概念に押し流されるので、禁止は半ばその行為をせよという指示として読まれてしまう。その **leading word** は _elephant_ だ: 禁止がフレームに名指しするものが何であれ。治療: **positive** をプロンプトせよ — 目標の振る舞いを描き（"write one-line comments"）、禁じたい方を決して口にしないようにする。禁止がその場所を勝ち取るのは、positive に言い換えられない振る舞いへのハードなガードレールとしてだけだ。その場合でも、注意が何をすべきかに着地するよう positive な目標と対にせよ。

_Avoid_: ironic rebound, don't-prompting, the pink elephant

## Pruning

skill を無駄なく保つこと — 各治療策は、それが治す failure と対にしてある。

### Single Source of Truth

各意味がちょうど 1 つの権威ある場所に住む望ましい状態で、skill の振る舞いの変更が一箇所の変更で済むようにする。**Duplication** はその違反だ。

_Avoid_: home, canonical location

### Duplication

_Failure mode._ 同じ意味が複数の **single source of truth** を与えられていること。保守（一箇所を変えたら他も変えねばならない）とトークンのコストを払わせ、目立ち方を膨張させる — 意味を繰り返すことで、梯子上での重みが本来の順位を超える。**leading word** の偶発的な逆だ。あちらは意味ではなくトークンを繰り返すことで、意図的に注意を高める。

_Avoid_: repetition, redundancy

### Relevance

ある行が今も skill の働きに関わっているか — 何を残すかのレンズ。行が relevance を失うのは、タスクに一度も関わらない（単なる説明、または disclose すべき **branch**）か、古びる（それが記述する振る舞いや世界が変わるにつれて時代遅れになる）かのどちらかだ。短い skill ほど relevant に保ちやすい。各行の点検が安上がりだからだ。**no-op** とは異なる: relevance は行がタスクに関わっているかを問い、振る舞いを変えるかは問わない。

_Avoid_: load-bearing, staleness, freshness

### Sediment

_Failure mode._ skill に沈殿して決して除かれない古いコンテンツの層。追加は安全に感じ削除は危険に感じるからだ — こうして古びて無関係な行が蓄積し、まだ生きているものを見つけるにはそれらを掘り抜かねばならない。pruning の規律を持たないあらゆる skill の既定の末路。**duplication** の繰り返された意味に対して、これは **relevance** のゆっくりとした侵食だ。

_Avoid_: accretion, bloat, cruft, rot

### No-Op

_Failure mode._ 何も変えない指示。モデルが既定でそれを既に行うからだ — エージェントにどのみちやることを告げるために load を払う。テスト: ある行は既定に対して振る舞いを変えるか？ 行は完璧に **relevant** でありながら、なお no-op でありうる。**leading word** をただにするのと同じ prior が、no-op を無価値にする。

leading word は _技法_ で、No-Op は行に対する _判定_ だ — そして両者は交差する。既定を打ち負かすには弱すぎる leading word は no-op だ（エージェントが既にそこそこ徹底的なのに _be thorough_）。修正は判定を通過するより強い語（_relentless_）であって、別の技法ではない。だから No-Op テスト — それは既定に対して振る舞いを変えるか？ — は、leading word がその繰り返しに見合っているかを採点する方法でもある。これはモデル相対的であって、読み手相対的ではない: ある行が no-op かどうかで 2 人が食い違うなら、それは既定について食い違っているのであり、議論ではなく skill を実行して決着する。

_Avoid_: redundant instruction, restating the obvious, belaboring
