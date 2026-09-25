import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  // Left as the stock id on purpose, as `omarchy plugin clone` does: the bar
  // overwrites moduleName with this plugin's own id when it loads the widget,
  // and the manifest's clonedFrom routes calls to the old id here.
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    // AirPlay workspaces always sort last, whatever their id.
    //
    // The daemon picks the next free id above the highest in use, so a fresh
    // session does land on the right-hand end by number alone. But ids never
    // renumber: take 7 for the TV, then open 8 and 9 later, and a plain
    // numeric sort would leave the television sitting in the middle of the
    // row. Sorting on "is this on a TV" first keeps it pinned to the end for
    // the life of the session, which is what the row is read as meaning.
    ids.sort(function(left, right) {
      var leftTv = root.isAirplay(left) ? 1 : 0
      var rightTv = root.isAirplay(right) ? 1 : 0
      if (leftTv !== rightTv) return leftTv - rightTv
      return left - right
    })
    return ids
  }

  // A workspace sitting on an AirPlay virtual output is being streamed to a
  // television, so it is not on any screen in front of you. The stock widget
  // labels every button with its id, which leaves no way to tell that one
  // apart; it gets a TV glyph instead of its number.
  //
  // The airplay daemon names its headless outputs `AIRPLAY-<workspace>`, and
  // HyprlandWorkspace.monitor is a live property, so this needs no polling and
  // no state file — it updates with the compositor.
  readonly property string airplayOutputPrefix: "AIRPLAY-"

  function isAirplay(id) {
    var w = root.workspaceById(id)
    if (w === null || !w.monitor) return false
    return String(w.monitor.name).indexOf(root.airplayOutputPrefix) === 0
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
        readonly property bool airplay: root.isAirplay(modelData)

        bar: root.bar
        // U+F0379 nf-md-television. Focus still wins, so the focused marker
        // keeps meaning exactly what it did \u2014 and the TV glyph is showing
        // precisely when it is useful, i.e. while you are looking elsewhere.
        text: focused ? "\uDB85\uDCFB" : (airplay ? "\uDB80\uDF79" : (modelData === 10 ? "0" : String(modelData)))
        // An AirPlay workspace is worth full weight even while empty: it is a
        // live destination, not a spare number.
        opacity: occupied || focused || airplay ? 1 : 0.5
        tooltipText: airplay ? "On the TV over AirPlay" : ""
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
