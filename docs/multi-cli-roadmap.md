# Multi-CLI Roadmap

CodexHUD starts as a Codex statusline, but the larger product is a local-first
AI CLI spend ledger: one prompt/statusline that answers "how much am I burning
right now?" across Codex, Claude Code, Aider, Cursor, and local inference.

## Positioning

The important shift is from prompt decoration to cost observability.

CodexHUD today:

- Reads one CLI's local session telemetry.
- Renders one active session.
- Estimates current/session spend from a local price table.

The broader product:

- Normalizes usage events from multiple AI CLIs.
- Maintains a local spend ledger across sessions and tools.
- Warns before cost gets surprising.
- Exports spend for personal finance, teams, and reimbursements.

## Naming

Rename before the adapter split lands. The public command can keep `codexhud` as
a compatibility alias for the Codex adapter, but the main product should be
vendor-neutral.

Recommended working name: `tokenline`.

Why:

- It says tokens and statusline without tying the product to one vendor.
- It can cover cloud and local models.
- It is short enough for a CLI command.
- It leaves `codexhud` available as a familiar alias.

Other viable names:

- `aihud`: clear, but generic and harder to search.
- `spendline`: strong for cost, weaker for token/context telemetry.
- `meterline`: good utility feel, less obviously AI.
- `promptledger`: accurate, but long for a command.

Suggested transition:

```text
tokenline              main command
tokenline codex        explicit Codex adapter mode
codexhud               compatibility alias for tokenline codex/status
CODEXHUD_*             accepted for one release train
TOKENLINE_*            new canonical environment variables
```

## Adapter Boundary

The current implementation already has natural adapter seams:

- Session discovery.
- Session metadata extraction.
- Token/cost event extraction.
- Model identity normalization.
- Price lookup.

Keep the core renderer and pricing code independent from any specific CLI. Each
adapter should emit normalized JSONL usage records that the core ledger can
dedupe, aggregate, render, and export.

Adapter contract v1:

```json
{
  "adapter": "codex",
  "source_file": "/path/to/session.jsonl",
  "session_id": "stable-session-id",
  "timestamp": "2026-04-29T01:00:00Z",
  "cwd": "/repo",
  "model": "gpt-5.5",
  "provider": "openai",
  "usage": {
    "input_tokens": 1000,
    "cached_input_tokens": 500,
    "output_tokens": 100,
    "reasoning_output_tokens": 25,
    "total_tokens": 1100
  },
  "context": {
    "window": 200000,
    "used_tokens": 1100
  },
  "rate_limits": {},
  "event_id": "stable-dedupe-key"
}
```

Adapter responsibilities:

- Discover local session/log files without blocking prompt rendering.
- Parse only local telemetry; never send prompts or transcripts anywhere.
- Emit cumulative usage when available.
- Emit delta usage if cumulative usage is not available.
- Mark confidence when a source format is incomplete or heuristic.

Core responsibilities:

- Dedupe records by `adapter`, `session_id`, and `event_id`.
- Join usage to model pricing.
- Compute current session spend, daily spend, and historical aggregates.
- Render statuslines, prompt summaries, alerts, and exports.

## Initial Adapter Order

1. `codex`: current implementation, highest confidence.
2. `claude`: read local Claude Code project/session telemetry after verifying
   the current file layout.
3. `aider`: parse Aider chat/history or analytics files when present; fall back
   to explicit model/token summaries where available.
4. `cursor`: treat as research first. Cursor storage may move between versions,
   so the adapter must be conservative and confidence-tagged.
5. `llamacpp`: no API bill, but useful for local energy/time accounting and
   token throughput. Cost can be configured as zero or user-defined.

Do not hardcode unverified paths for non-Codex adapters. Each adapter should
ship with a `doctor` check that reports which files were found and which parser
will be used.

## Killer Features

Build these before spending time on more visual styles.

### Threshold Alerts

Environment variables:

```bash
TOKENLINE_ALERT_USD=5
TOKENLINE_ALERT_DAILY_USD=20
TOKENLINE_ALERT_MODE=bell,notify
```

Behavior:

- Alert when one session crosses a configured spend threshold.
- Alert once per threshold per session, not on every prompt.
- Support terminal bell everywhere.
- Support `notify-send` on Linux, `osascript`/Notification Center on macOS, and
  no-op fallback elsewhere.
- Keep `CODEXHUD_ALERT_USD` as an alias during transition.

### Daily Summary

Print once per shell startup or once per day:

```text
AI spend yesterday: $4.20 across 3 sessions; biggest spike 14:30 UTC ($1.10, codex/gpt-5.5)
```

Implementation:

- Store state in `~/.tokenline/state.json`.
- Store ledger records in `~/.tokenline/ledger.jsonl`.
- Keep prompt path fast: prompt reads cached summary; background refresh updates
  the ledger.

### Spend Export

Command shape:

```bash
tokenline spend --since 2026-04-01 --until 2026-04-30
tokenline spend --since today --by adapter
tokenline spend --since 2026-04-01 --csv
tokenline spend --json
```

CSV columns:

```text
date,adapter,provider,model,session_id,cwd,input_tokens,cached_input_tokens,output_tokens,reasoning_output_tokens,usd,credits
```

## Pricing Strategy

Price tables become harder once multiple providers are involved. Treat pricing
as community-maintained configuration, not live quotes.

Recommended path:

1. Keep local `prices.json` as the source of truth for cost calculations.
2. Add `tokenline prices-check --remote` to compare local metadata with a
   community registry.
3. Create a separate `tokenline-prices` repo for PR-driven updates.
4. Later, add a weekly GitHub Actions job that opens a PR when official pricing
   pages appear to change.

Registry rules:

- Never auto-apply remote price changes silently.
- Show source URLs, last updated date, status, and stale markers.
- Separate official, configured, provisional, and unknown statuses.
- Require human review for changes that affect cost estimates.

## Distribution

The current `./install.sh` is fine for contributors, but public adoption needs a
one-command path.

Priority:

1. Raw GitHub installer:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/Lorlds/CodexHUD/main/install.sh | bash
   ```

2. Homebrew tap:

   ```bash
   brew install lorlds/tap/tokenline
   ```

3. Terminal demo GIF or asciinema/VHS recording in the README.
4. Submit to relevant awesome lists after the rename and adapter boundary land.

Install safety:

- Print what will be installed before writing.
- Never overwrite user price/config files without confirmation.
- Support `TOKENLINE_INSTALL_MODE=copy|link`.
- Keep `CODEXHUD_INSTALL_MODE` as a compatibility alias during transition.

## Milestones

### 0.3: Codex Ledger

- Add `spend --since --csv --json` for Codex only.
- Add single-session and daily threshold alerts.
- Add daily summary cache.
- Keep command name `codexhud`.

### 0.4: Rename Foundation

- Introduce `tokenline` command.
- Keep `codexhud` as a compatibility alias.
- Rename config root to `~/.tokenline`.
- Accept both `TOKENLINE_*` and `CODEXHUD_*` env vars.
- Move Codex-specific code behind `adapters/codex`.

### 0.5: Multi-CLI Preview

- Add `tokenline adapters` and `tokenline doctor`.
- Add Claude Code adapter after local format verification.
- Add Aider adapter with confidence tags.
- Add provider-neutral price schema.

### 0.6: Registry and Distribution

- Add `prices-check --remote`.
- Publish install one-liner.
- Publish Homebrew tap.
- Add README GIF.

### 1.0: Personal AI Spend Ledger

- Stable adapter contract.
- Stable ledger format.
- Codex and at least two non-Codex adapters.
- Alerts, daily summaries, spend export, and price registry flow documented.

## Non-Goals

- Do not upload local session files to a hosted service.
- Do not parse or export prompt text unless the user explicitly opts in.
- Do not promise exact billing parity with vendor invoices.
- Do not auto-update prices without review.

## Immediate Next Commit

If the name is accepted, the next implementation should be:

1. Add a `tokenline` wrapper command that calls the current core.
2. Add `adapters/codex.sh` and move Codex-specific session parsing there.
3. Add `spend --since --csv --json` on top of the existing Codex parser.
4. Add `CODEXHUD_ALERT_USD` before the rename so current users get value
   immediately.
