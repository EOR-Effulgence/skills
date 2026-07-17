# Writing Agent Briefs

agent brief とは、Issue や PR が `ready-for-agent` に移ったときに投稿する構造化コメントだ。AFK エージェントが作業の拠り所にする権威ある仕様書である。元の body と議論はコンテキストにすぎず、agent brief こそが契約（contract）だ。

brief は **エージェントが何をすべきか** を述べ、それは両方の surface に及ぶ: Issue なら、ゼロから変更を作ること; PR なら、*既存の diff に対して* 残された作業 — 仕上げる、隙間を埋める、レビュー指摘に対応する。どちらでも原則は同じで、下記の PR 例がその違いを示す。

## Principles

### Durability over precision

Issue は数日から数週間 `ready-for-agent` に留まることがある。その間にコードベースは変わる。ファイルが rename・移動・refactor されても有用であり続けるように brief を書く。

- **やる**: Interface、型、振る舞いの契約を記述する
- **やる**: エージェントが探すべき / 変更すべき、具体的な型・関数シグネチャ・config の形を名指しする
- **やるな**: ファイルパスを参照する — 陳腐化する
- **やるな**: 行番号を参照する
- **やるな**: 現在の実装構造がそのまま残ると仮定する

### Behavioral, not procedural

システムが **何を** すべきかを記述し、**どう** 実装するかは書かない。エージェントはコードベースを新鮮に探索し、自分で実装判断を下す。

- **良い:** "The `SkillConfig` type should accept an optional `schedule` field of type `CronExpression`"
- **悪い:** "Open src/types/skill.ts and add a schedule field on line 42"
- **良い:** "When a user runs `/triage` with no arguments, they should see a summary of issues needing attention"
- **悪い:** "Add a switch statement in the main handler function"

### Complete acceptance criteria

エージェントは、いつ完了したかを知る必要がある。すべての agent brief は、具体的でテスト可能な acceptance criteria を持たねばならない。各基準は独立に検証可能であるべきだ。

- **良い:** "Running `gh issue list --label needs-triage` returns issues that have been through initial classification"
- **悪い:** "Triage should work correctly"

### Explicit scope boundaries

何がスコープ外かを述べる。これはエージェントが gold-plating したり、隣接機能について勝手な仮定をするのを防ぐ。

## Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one-line description of what needs to happen

**Current behavior:**
Describe what happens now. For bugs, this is the broken behavior.
For enhancements, this is the status quo the feature builds on.

**Desired behavior:**
Describe what should happen after the agent's work is complete.
Be specific about edge cases and error conditions.

**Key interfaces:**
- `TypeName` — what needs to change and why
- `functionName()` return type — what it currently returns vs what it should return
- Config shape — any new configuration options needed

**Acceptance criteria:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

**Out of scope:**
- Thing that should NOT be changed or addressed in this issue
- Adjacent feature that might seem related but is separate
```

## Examples

### Good agent brief (bug)

```markdown
## Agent Brief

**Category:** bug
**Summary:** Skill description truncation drops mid-word, producing broken output

**Current behavior:**
When a skill description exceeds 1024 characters, it is truncated at exactly
1024 characters regardless of word boundaries. This produces descriptions
that end mid-word (e.g. "Use when the user wants to confi").

**Desired behavior:**
Truncation should break at the last word boundary before 1024 characters
and append "..." to indicate truncation.

**Key interfaces:**
- The `SkillMetadata` type's `description` field — no type change needed,
  but the validation/processing logic that populates it needs to respect
  word boundaries
- Any function that reads SKILL.md frontmatter and extracts the description

**Acceptance criteria:**
- [ ] Descriptions under 1024 chars are unchanged
- [ ] Descriptions over 1024 chars are truncated at the last word boundary
      before 1024 chars
- [ ] Truncated descriptions end with "..."
- [ ] The total length including "..." does not exceed 1024 chars

**Out of scope:**
- Changing the 1024 char limit itself
- Multi-line description support
```

### Good agent brief (enhancement)

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Add `.out-of-scope/` directory support for tracking rejected feature requests

**Current behavior:**
When a feature request is rejected, the issue is closed with a `wontfix` label
and a comment. There is no persistent record of the decision or reasoning.
Future similar requests require the maintainer to recall or search for the
prior discussion.

**Desired behavior:**
Rejected feature requests should be documented in `.out-of-scope/<concept>.md`
files that capture the decision, reasoning, and links to all issues that
requested the feature. When triaging new issues, these files should be
checked for matches.

**Key interfaces:**
- Markdown file format in `.out-of-scope/` — each file should have a
  `# Concept Name` heading, a `**Decision:**` line, a `**Reason:**` line,
  and a `**Prior requests:**` list with issue links
- The triage workflow should read all `.out-of-scope/*.md` files early
  and match incoming issues against them by concept similarity

**Acceptance criteria:**
- [ ] Closing a feature as wontfix creates/updates a file in `.out-of-scope/`
- [ ] The file includes the decision, reasoning, and link to the closed issue
- [ ] If a matching `.out-of-scope/` file already exists, the new issue is
      appended to its "Prior requests" list rather than creating a duplicate
- [ ] During triage, existing `.out-of-scope/` files are checked and surfaced
      when a new issue matches a prior rejection

**Out of scope:**
- Automated matching (human confirms the match)
- Reopening previously rejected features
- Bug reports (only enhancement rejections go to `.out-of-scope/`)
```

### Good agent brief (PR)

PR の場合、"Current behavior" は diff の状態を記述し、brief はエージェントにゼロから作らせるのではなく、それを仕上げる / 直すよう求める。

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Finish the contributor's `--json` output flag for `triage list`

**Current behavior:**
The PR adds a `--json` flag that serializes the issue list to JSON. The happy
path works and the diff matches the project's command structure. Two gaps
remain: errors are still printed as human text (not JSON), and the new flag has
no test coverage.

**Desired behavior:**
With `--json`, all output — including errors — is well-formed JSON on stdout,
and the command's exit codes are unchanged. The existing human-readable output
is untouched when the flag is absent.

**Key interfaces:**
- The command's error path should emit `{ "error": string }` under `--json`
  instead of the plain-text error
- Reuse the existing serializer the PR already added; don't introduce a second

**Acceptance criteria:**
- [ ] `triage list --json` emits valid JSON for both success and error cases
- [ ] Exit codes match the non-JSON command
- [ ] A test covers the `--json` success output and one error case
- [ ] Default (non-JSON) output is byte-for-byte unchanged

**Out of scope:**
- Adding `--json` to any other command
- Changing the JSON shape of the success payload the PR already defined
```

### Bad agent brief

```markdown
## Agent Brief

**Summary:** Fix the triage bug

**What to do:**
The triage thing is broken. Look at the main file and fix it.
The function around line 150 has the issue.

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

これがダメな理由:
- category が無い
- 説明が曖昧（"the triage thing is broken"）
- 陳腐化するファイルパスと行番号を参照している
- acceptance criteria が無い
- scope の境界が無い
- current と desired の振る舞いの記述が無い
