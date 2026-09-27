# omarchy-workspaces

The TV in your workspace bar: Omarchy's workspace indicator, plus a TV icon for
the workspace that is on your television.

## AirPlay for Omarchy

On a Mac, AirPlay is a menu in the menu bar: pick a TV, then pick how to use
it. You can mirror the screen, send one window, or use the TV as a separate
display. AirPlay for Omarchy brings that experience to Omarchy, natively. It
isn't a wrapper around someone else's tool. The sender was written and tested
from the ground up in Rust for Wayland and Hyprland, and performance and
security were the design constraints from the start.

![AirPlay for Omarchy: the TV's workspace in the bar, and the AirPlay menu streaming a second desktop](preview.png)

- **Three ways to use a TV, as on a Mac:** this screen, one window, or a second
  desktop.
- **Video, or video with sound.** With **Send audio** on, the laptop's sound
  moves to the TV through its own *AirPlay: <TV>* output, the way a Mac hands
  over its sound. The TV's volume follows the laptop's, and your speakers come
  back when the session ends.
- **The second desktop is one click away.** The TV gets its own workspace, and
  the workspace bar shows it as a TV icon at the end of the row: click it to
  switch there, and drag a window onto it to put that window on the TV.
- **Fast.** Screen capture stays on the GPU and goes straight into the
  hardware H.264 encoder (zero-copy). It takes about 5 ms from a frame being
  drawn to being encoded, using about 7 % of one CPU core. See
  [Performance](https://github.com/jonspinks/omarchy-airplay#performance).
- **Careful.** Pairing keys stay private to your account. Every build is pinned
  to a tested commit. The bar menu only ever stops, cleans up or signals
  something it started and recorded.

It is three pieces, and the full experience needs all three:

| Piece | Its part in the set |
|-------|---------------------|
| [omarchy-airplay](https://github.com/jonspinks/omarchy-airplay) | **The sender.** Finds receivers, pairs, captures the screen, a window or a virtual display, encodes on the GPU and streams video and sound. |
| [omarchy-cast](https://github.com/jonspinks/omarchy-cast) (`blacksheep.airplay`) | **The AirPlay menu.** The bar icon and panel: receivers, the three modes, pairing, Send audio and Stop. |
| [omarchy-workspaces](https://github.com/jonspinks/omarchy-workspaces) (`blacksheep.workspaces`, listed as *Cast Workspaces*) | **The TV in your workspace bar.** Marks the second desktop's workspace with a TV icon at the end of the row, so it is one click to reach. |

Omarchy plugins can't declare dependencies, so each piece is installed on its
own. [omarchy-cast's README](https://github.com/jonspinks/omarchy-cast#install)
has the steps in order.

### This repo: the TV in your workspace bar

Installs as the bar widget `blacksheep.workspaces` (listed as *Cast Workspaces*),
and replaces Omarchy's stock `omarchy.workspaces`. It started as a clone of the
stock widget (`omarchy plugin clone omarchy.workspaces`), so it survives
`omarchy update`, and it behaves the same until a session starts. When AirPlay's
**Second desktop** puts a workspace on the TV, that workspace's button becomes
a TV icon and moves to the right-hand end of the row, whatever its number. Click
it to switch there. Without the sender there is no TV workspace, so this is
simply the stock indicator.

## Install

```bash
omarchy plugin add https://github.com/jonspinks/omarchy-workspaces --enable
omarchy plugin disable omarchy.workspaces   # it replaces the stock widget
omarchy restart shell
```

Install the sender and omarchy-cast first; their steps are in [omarchy-cast's
README](https://github.com/jonspinks/omarchy-cast#install). This widget needs
them to be useful, but not to run: without a headless `AIRPLAY-*` output it
behaves exactly like the stock indicator.

## Remove

```bash
omarchy plugin remove blacksheep.workspaces
omarchy plugin enable omarchy.workspaces    # bring the stock widget back
omarchy restart shell
```

The widget itself stores nothing and writes no files, so there is nothing else to
clean up.

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

## License

MIT — see [LICENSE](LICENSE). `Workspaces.qml` is derived from Omarchy's stock
widget, © David Heinemeier Hansson, also MIT; that notice is kept in the
license file.
