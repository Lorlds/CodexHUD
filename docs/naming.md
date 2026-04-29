# Naming Notes

## Final Choice: TokenHUD

`TokenHUD` is the selected product name.

Why:

- It is vendor-neutral and can cover Codex, Claude Code, Aider, Cursor, and local
  inference.
- It keeps the strongest concept from the original project: a lightweight HUD
  for token and spend telemetry.
- It leaves room for non-statusline features such as alerts, daily summaries,
  CSV export, and a multi-provider price registry.
- It is short enough for a CLI command: `tokenhud`.

## Compatibility

`CodexHUD` remains as the Codex adapter alias:

```text
tokenhud              main command
tokenhud adapters     supported/planned adapter list
codexhud              compatibility alias for tokenhud
```

The transition keeps:

- `codexhud` command wrapper.
- `tmux/codexhud.tmux` wrapper.
- `CODEXHUD_*` environment variable compatibility when `TOKENHUD_*` is unset.
- Legacy `~/.codexhud/prices.json` fallback when `~/.tokenhud/prices.json` has
  not been created yet.

## Earlier Name

The project launched as `CodexHUD` because the first implemented adapter reads
Codex session telemetry. The broader product direction is now TokenHUD:
one local statusline and ledger for AI CLI token/cost usage across tools.
