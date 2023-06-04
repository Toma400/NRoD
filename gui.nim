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

proc setElmSettings (loc_label: Label, loc_text: string,
                     health: ProgressBar, hp: int, travel_cb: ComboBox, travel_dt: seq[string]) =
  loc_label.yTextAlign = YTextAlign_Center
  loc_label.text       = loc_text
  health.value         = hp/100
  travel_cb.options    = travel_dt

proc setLayout (window: Window, main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                loc_label: Label, health: ProgressBar, buttons: OrderedTable, travel_cb: ComboBox) =
  block wContainers:
    window.add(main)
    main.add(left)
    main.add(right)
  block wElements:
    right.add(loc_label)
    right.add(health)
  block wButtons:
    right.add(buttons["shop"])
    right.add(buttons["hunt"])
    right.add(buttons["travel"])
    right.add(travel_cb)

proc updateWindow* (mode: int, window: Window, main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                    loc_label: Label, loc_text: string, health: ProgressBar, hp: int, buttons: OrderedTable,
                    travel_cb: ComboBox, travel_dt: seq[string]) =

  setMnSettings(window = window,
                left   = left,
                right  = right)
  setElmSettings(loc_label = loc_label,
                 loc_text  = loc_text,
                 health    = health,
                 hp        = hp,
                 travel_cb = travel_cb,
                 travel_dt = travel_dt)
  if mode == 0: # 0 is set as initial, 1 is for update
    setLayout(window = window,
              main   = main,
              left   = left,
              right  = right,
              loc_label = loc_label,
              health    = health,
              buttons   = buttons,
              travel_cb = travel_cb)