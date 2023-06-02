import std/tables
import nigui
import nrod

let w_x* = 700
let w_y* = 430

proc setMnSettings (window: Window, left: LayoutContainer, right: LayoutContainer) =
  window.width  = w_x
  window.height = w_y
  left.frame    = newFrame()
  right.frame   = newFrame()
  left.xAlign  = XAlign_Center
  left.yAlign  = YAlign_Center
  right.xAlign = XAlign_Center
  right.yAlign = YAlign_Center
  left.padding  = (w_x/4).int
  left.setInnerSize(width=(w_x/2).int,  height=w_y)
  right.setInnerSize(width=(w_x/2).int, height=w_y)
# window.iconPath = bcsd() & "/bcs/assets/graphical/bcs.png"
# left.x      = 0
# left.y      = 0
# left.width  = w_x/2.int
# left.height = w_y
# right.x     = w_x/2.int
# right.y     = 0
# right.width = w_x
# right.y     = w_y

proc setElmSettings (loc_text: Label, health: ProgressBar, hp: int) =
  loc_text.yTextAlign = YTextAlign_Center
  health.value        = hp/100

proc setLayout (window: Window, main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                loc_text: Label, health: ProgressBar, buttons: OrderedTable) =
  block wContainers:
    window.add(main)
    main.add(left)
    main.add(right)
  block wElements:
    right.add(loc_text)
    right.add(health)
  block wButtons:
    right.add(buttons["shop"])
    right.add(buttons["hunt"])
    right.add(buttons["travel"])

proc updateWindow* (window: Window, main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                    loc_text: Label, health: ProgressBar, hp: int, buttons: OrderedTable) =

  setMnSettings(window = window,
                left   = left,
                right  = right)
  setElmSettings(loc_text = loc_text,
                 health   = health,
                 hp       = hp)
  setLayout(window = window,
            main   = main,
            left   = left,
            right  = right,
            loc_text = loc_text,
            health   = health,
            buttons  = buttons)