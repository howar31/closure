---
name: closure
description: Use when a work session is wrapping up or about to end — the user signals closing, e.g. 「本 session 還有未盡事宜嗎」「這個 session 還有未盡事宜嗎」「還有未盡事宜嗎」「還有未完成的事嗎」「還有未完成的事項嗎」「還有沒完成的事嗎」「還有什麼沒做/沒處理的嗎」「收尾」「未盡事宜」「結案」「收工」, or (en) "anything left?", "are we done?", "what's left?", "wrap up", "loose ends" — or before you end a long or multi-thread session. Covers session loose ends, outstanding/unresolved items, undocumented decisions, work left unhanded-off.
---

# Closure

## Overview
Before a session ends, every thread it opened must reach an explicit **disposition** — resolved, documented, memorized, or handed off. A loose end with no disposition is a dropped ball.

**Core principle:** Don't summarize the session — audit it, then drive each open item to closure. Listing problems and asking "which one?" is not closure.

## The audit
Reconstruct from THIS session by re-reading it — do not rely on memory or on a summary. Check all four categories:

1. **Opening request(s)** — did each original ask get *fully* resolved, including verification (tests run, behavior confirmed)? "Implemented but untested" is still open.
2. **Mid-session threads** — side requests, pivots, and deferrals raised along the way. Each resolved, or explicitly carried over?
3. **Unexpected findings** — bugs, risks, or tech debt noticed in passing. Each fixed, tracked, or surfaced to the user?
4. **Decisions** — important calls made only in conversation. Each written somewhere durable?

Also surface any **uncommitted / unpushed changes**.

## Disposition routing
Give every open item exactly one disposition. When a skill for that disposition is available (for example a memory-writing skill, a session handoff skill, or a skill that maintains a project doc), delegate to it rather than reinventing it; otherwise do the work directly. If the user's own instructions say where decisions, docs or handoffs go, follow them.

| Disposition | When | How |
|---|---|---|
| **Resolve now** | quick and in scope | just do it |
| **Document** | decisions, behavior, deprecations | the project's own docs or issue tracker; delegate to a doc skill when one covers that file |
| **Memorize** | durable preference, decision, or project state | the agent's persistent memory; delegate to a memory skill when available |
| **Hand off** | unfinished work needing next-session context | a handoff document the next session can load; delegate to a handoff skill when available |
| **Drop** | genuinely not needed | only with the user's explicit OK |

## Output
Report each open item with its chosen disposition (a short list or table). End by confirming **no open item is left without a disposition**, then carry out — or propose, and get the user's go — the items that need action. If the audit finds nothing open, say so plainly; an empty audit is a valid result.

## Common mistakes
- Producing a recap instead of an audit — skipping the systematic four-category sweep, so a long session quietly drops a thread.
- Listing open items and asking "which one do you want?" without proposing a disposition for each.
- Letting a decision made only in chat evaporate — neither documented nor memorized.
- Claiming "all done" without re-reading the session to confirm it.
- Treating memorize / hand-off as optional afterthoughts instead of the routing targets for carry-over items.
