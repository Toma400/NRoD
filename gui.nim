import nigui
import nrod

let w_x = 700
let w_y = 500

proc setMnSettings* (window: Window, left: LayoutContainer, right: LayoutContainer) =
  window.width  = w_x
  window.height = w_y
  left.frame    = newFrame()
  right.frame   = newFrame()
  left.xAlign  = XAlign_Center
  right.xAlign = XAlign_Center
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

proc setElmSettings* (loc_text: Label, health: ProgressBar, hp: int) =
  loc_text.yTextAlign = YTextAlign_Center
  health.value        = hp/100

proc setLayout* (window: Window, main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                 loc_text: Label, health: ProgressBar) =
  block wContainers:
    window.add(main)
    main.add(left)
    main.add(right)
  block wElements:
    right.add(loc_text)
    right.add(health)