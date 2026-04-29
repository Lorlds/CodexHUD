# CodexHUD

CodexHUD is a local-first statusline for Codex CLI sessions. It reads
`~/.codex/sessions/**/*.jsonl`, finds the latest `token_count` event, and renders
context usage, token usage, estimated API cost, Codex credits, rate limits, model,
git state, and session metadata.

The command is `codexhud`; configuration uses `CODEXHUD_*` environment
variables.

## Features

- Token counts from Codex's local `token_count` telemetry.
- Estimated USD and Codex credit cost from the local model price table.
- Current context window usage with compact risk labels.
- Rate limit percentages and reset windows when Codex emits them.
- Git branch and dirty-file count for the active session cwd.
- `tmux`, compact, full, JSON, model table, and style-gallery modes.
- Several statusline styles controlled by one environment variable.

## Install

```bash
./install.sh
```

This links `bin/codexhud` to `~/.local/bin/codexhud` and installs the default
price config to `~/.codexhud/prices.json` if that file does not already exist.
Use `CODEXHUD_INSTALL_MODE=copy ./install.sh` if you prefer copying the binary.

## Usage

```bash
codexhud tmux
codexhud compact
codexhud full
codexhud json
codexhud models
codexhud prices-check
codexhud styles
codexhud init bash
codexhud init zsh
```

Useful environment variables:

```bash
CODEXHUD_STYLE=balanced   # balanced|minimal|ledger|risk|executive|focus|ascii
CODEXHUD_MODEL=gpt-5.5    # override model detection
CODEXHUD_ASCII=1          # force ASCII progress bars
CODEXHUD_PROMPT=0         # temporarily disable shell prompt integration
CODEXHUD_DEBUG=1          # log prompt refresh errors to cache/refresh.log
CODEXHUD_HOME=~/.codexhud
CODEXHUD_CACHE_DIR=~/.codexhud/cache
CODEXHUD_PRICE_FILE=~/.codexhud/prices.json
CODEXHUD_PRICES_CHECK_FETCH=1 # optional URL reachability probes
CODEXHUD_TAIL_LINES=500    # 0 scans the full JSONL directly
CODEXHUD_CACHE_TTL=2
CODEXHUD_SESSION_SCAN_LIMIT=0 # 0 scans all sessions when matching cwd
CODEX_HOME=~/.codex          # override Codex home
```

## Shell Prompt

CodexHUD can print one line immediately above each new terminal prompt. The
prompt hook reads a small per-cwd cache file and refreshes it in the background
so a large `~/.codex/sessions` directory does not block your input line. The
first prompt for a directory generates the cache once in the foreground; later
prompts refresh only when the matching session JSONL has changed. Cache entries
older than 30 days are cleaned during refresh.

Bash:

```bash
eval "$(codexhud init bash)"
```

Zsh:

```zsh
eval "$(codexhud init zsh)"
```

Add the matching line to `~/.bashrc` or `~/.zshrc` if you want it enabled for
new terminals. Set `CODEXHUD_PROMPT=0` in a terminal to silence it temporarily.
Set `CODEXHUD_DEBUG=1` to write foreground/background refresh diagnostics to
`$CODEXHUD_CACHE_DIR/refresh.log`; the hook rotates that file once it grows
beyond roughly 200 KB.

## Style Examples

```text
balanced   CX gpt-5.5 ▕████████░░▏ 80.7%  $ 0.127/7.50  cr 3.17cr/187cr  lim 9.0/13.0%  main +11
minimal    CX 80.7% $7.50 187cr main +11
ledger     CX last $0.127/3.17cr | session $7.50/187cr | in 6.27M out 45.2k
risk       CX ▕████████░░▏ 80.7% watch  $7.50  lim 9.0/13.0%  main +11
executive  CodexHUD | ctx 80.7% | session $7.50 / 187cr | limits 9.0%/13.0%
focus      CX 80.7% watch $7.50
ascii      CX gpt-5.5 [########--] 80.7% $0.127/$7.50 main +11
```

More options and rationale live in [docs/style-gallery.md](docs/style-gallery.md).

## tmux

One-line status-right example:

```tmux
set -g status-interval 5
set -g status-right "#{?#{==:#{pane_current_command},codex},#(CODEXHUD_STYLE=balanced ~/.local/bin/codexhud tmux #{q:pane_current_path}) ,}%H:%M"
```

Plugin-style entrypoint:

```tmux
set -g @codexhud_style "risk"
# Optional. If omitted, CodexHUD leaves your existing status-interval alone.
set -g @codexhud_interval "5"
run-shell "/path/to/codexhud/tmux/codexhud.tmux"
```

## Pricing Notes

`codexhud models` reads locally callable models from `codex debug models` and
joins them with `~/.codexhud/prices.json`. The price file has `last_updated` and
`stale_after_days`; JSON output exposes `pricing.status` and `pricing.stale`
separately, unknown models are labeled `unknown-model`, and missing configs
render cost as `n/a`.

Run `codexhud prices-check` to inspect the active price file, freshness, source
URLs, and the manual refresh steps. CodexHUD does not auto-rewrite pricing data:
check the source URLs, edit `~/.codexhud/prices.json`, update `last_updated`,
then run `codexhud models` to inspect coverage. Set
`CODEXHUD_PRICES_CHECK_FETCH=1` if you also want lightweight URL reachability
probes.

`gpt-5.3-codex-spark` is intentionally mapped to `gpt-5.3-codex` pricing in the
default config as a provisional rule.

Reasoning output tokens are displayed, but cost is computed from `output_tokens`;
the script does not add reasoning tokens a second time. This matches observed
Codex session telemetry where `reasoning_output_tokens` is included within
`output_tokens`, not an extra billable bucket.

## Requirements

- Bash
- `jq`
- `git`
- GNU `find` or BSD/macOS `stat`
- Codex CLI with local session files under `~/.codex/sessions`

## Project Layout

```text
bin/codexhud             executable statusline script
config/prices.json       default editable price config
tmux/codexhud.tmux       tmux plugin-style entrypoint
docs/style-gallery.md    visual directions and examples
docs/naming.md           name search notes and alternatives
examples/codexhud.json   sample JSON output shape
scripts/check.sh        local smoke checks
```

## Checks

```bash
./scripts/check.sh
```
