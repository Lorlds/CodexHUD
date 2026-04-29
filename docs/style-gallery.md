# Style Gallery

Each style is meant for a different terminal layout. Use it with:

```bash
TOKENHUD_STYLE=<style> tokenhud tmux
```

## 1. Balanced

Best default for tmux: adapter, model, context, last/session cost, credits, rate
limits, git.

```text
TH codex:gpt-5.5 ▕████████░░▏ 80.7%  $ 0.127/7.50  cr 3.17cr/187cr  lim 9.0/13.0%  main +11
```

## 2. Minimal

For narrow terminals where only the main numbers matter.

```text
TH 80.7% $7.50 187cr main +11
```

## 3. Ledger

For cost tracking. It separates last turn from whole-session spend.

```text
TH codex last $0.127/3.17cr | session $7.50/187cr | in 6.27M out 45.2k
```

## 4. Risk

For long sessions. The risk label changes from `steady` to `watch`,
`compact-soon`, and `compact-now`.

```text
TH ▕████████░░▏ 80.7% watch  $7.50  lim 9.0/13.0%  main +11
```

## 5. Executive

Readable in recordings or screen shares.

```text
TokenHUD | adapter codex | ctx 80.7% | session $7.50 / 187cr | limits 9.0%/13.0%
```

## 6. Focus

For the far-right corner of a dense statusline.

```text
TH 80.7% watch $7.50
```

## 7. ASCII

For machines without a font that renders block bars cleanly.

```text
TH codex:gpt-5.5 [########--] 80.7% $0.127/$7.50 main +11
```

## 8. Powerline Direction

Not implemented by default because it depends on fonts and tmux theme colors,
but this is a strong visual direction if you use Powerline glyphs.

```text
codex:gpt-5.5  ctx 80.7%  $7.50  main +11
```

## 9. Nerd Font Direction

Also font-dependent. Useful when you want icon scanning instead of text labels.

```text
󰚩 codex:gpt-5.5  󰓅 80.7%  7.50   main +11
```

## 10. Two-Line HUD Direction

This is better for a terminal dashboard than a tmux status-right segment.

```text
codex:gpt-5.5  arc-kit  main +11
▕████████░░▏ 80.7%  last $0.127 / 3.17cr  total $7.50 / 187cr
```
