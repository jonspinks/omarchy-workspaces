# omarchy-workspaces

The Omarchy workspace indicator, with one addition: a workspace that is being
streamed to a television shows a TV glyph instead of its number, and always
sorts to the right-hand end of the row.

Installed as the bar widget `blacksheep.workspaces`, a clone of the stock
`omarchy.workspaces` (`omarchy plugin clone omarchy.workspaces`), so it
survives `omarchy update` instead of being overwritten.

## Install

```bash
omarchy plugin add https://github.com/jonspinks/omarchy-workspaces --enable
omarchy plugin disable omarchy.workspaces   # it replaces the stock widget
omarchy restart shell
```

It needs [omarchy-airplay](https://github.com/jonspinks/omarchy-airplay) to be
useful, but not to run: without a headless `AIRPLAY-*` output it behaves exactly
like the stock indicator.

## Why

[omarchy-airplay](https://github.com/jonspinks/omarchy-airplay) has an Extend
mode: it creates a Hyprland headless output named `AIRPLAY-<workspace>` and
puts a workspace on it, so that workspace lives on the TV rather than on any
screen in front of you. Drag a window there and it plays on the television
while you carry on working on the laptop.

The stock widget labels every button with its id and nothing else, so there is
no way to tell which of them is the one on the TV. Hence the glyph.

## What changed from the stock widget

Three small edits to `Workspaces.qml`:

- `isAirplay(id)` — true when the workspace's monitor name starts with
  `AIRPLAY-`. It reads `HyprlandWorkspace.monitor`, a live property, so this
  needs no polling, no state file and no help from the daemon.
- The button renders `󰍹` (U+F0379 nf-md-television) in place of its number.
  Focus still wins over the glyph, so the focused marker means what it always
  did — and the TV glyph is showing exactly when it is useful, which is while
  you are looking at a different workspace. An AirPlay workspace also keeps
  full opacity while empty, because it is a live destination rather than a
  spare number.
- AirPlay workspaces sort last, whatever their id. The daemon picks the next
  free id above both the highest in use and the bar's five always-rendered
  defaults, so a fresh session lands on the right-hand end by number alone —
  but ids never renumber. Take 6 for the TV, open 7 and 8 later, and a plain
  numeric sort would leave the television stranded in the middle of the row.

## Notes

- The bar renders workspace ids 1-10 only, and always draws 1-5 whether or not
  they are in use. The daemon knows both facts: it appends past the defaults,
  and it refuses to start rather than place the TV on a workspace with no
  button.
- Nothing here is AirPlay-specific beyond the `AIRPLAY-` prefix. Any headless
  output named that way gets the glyph.
