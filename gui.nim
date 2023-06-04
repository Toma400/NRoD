import std/tables
import nigui
import nrod

let w_x* = 700
let w_y* = 430

proc setMnSettings (mode: int, window: Window,
                    left: LayoutContainer, right: LayoutContainer, contr: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer) =
  if mode == 0: # initial value
    window.width  = w_x
    window.height = w_y
  else:         # retriggered with update
    window.width  = window.width
    window.height = window.height
  left.frame    = newFrame()
  right.frame   = newFrame()
  contr.frame   = newFrame()
  savn.frame    = newFrame()
  actn.frame    = newFrame()
  left.xAlign  = XAlign_Center
  left.yAlign  = YAlign_Center
  right.xAlign = XAlign_Center
  right.yAlign = YAlign_Center
  contr.xAlign = XAlign_Center
  contr.yAlign = YAlign_Center
  savn.xAlign  = XAlign_Center
  savn.yAlign  = YAlign_Center
  actn.xAlign  = XAlign_Center
  actn.yAlign  = YAlign_Center
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

proc setElmSettings (loc_img: Image, loc_uid: string, loc_label: Label, loc_text: string,
                     health: ProgressBar, hp: int, travel_cb: ComboBox, travel_dt: seq[string], load_cb: ComboBox, load_data: seq[string]) =
  try:    loc_img.loadFromFile("assets/" & loc_uid & ".png")
  except: loc_img.loadFromFile("assets/q_mark.png")
  loc_label.yTextAlign = YTextAlign_Center
  loc_label.text       = loc_text
  health.value         = hp/100
  travel_cb.options    = travel_dt
  load_cb.options      = load_data

proc setLayout (window: Window,
                main: LayoutContainer, left: LayoutContainer, right: LayoutContainer, contr: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer,
                loc_label: Label, health: ProgressBar, buttons: OrderedTable, travel_cb: ComboBox, save_txt: TextBox, load_cb: ComboBox) =
  block wContainers:
    window.add(main)
    main.add(left)
    main.add(right)
  block wElements:
    right.add(loc_label)
    right.add(health)
  block wButtons:
    right.add(contr)
    contr.add(buttons["shop"])
    contr.add(buttons["hunt"])
    contr.add(buttons["travel"])
    contr.add(travel_cb)
  block wSaveLoad:
    right.add(savn)
    savn.add(save_txt)
    savn.add(buttons["save"])
    savn.add(buttons["load"])
    savn.add(load_cb)
  block wSegments:
    right.add(actn)

proc updateWindow* (mode: int, window: Window,
                    main: LayoutContainer, left: LayoutContainer, right: LayoutContainer, contr: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer,
                    loc_img: Image, loc_uid: string, loc_label: Label, loc_text: string, health: ProgressBar, hp: int, buttons: OrderedTable,
                    travel_cb: ComboBox, travel_dt: seq[string], save_txt: TextBox, load_cb: ComboBox, load_data: seq[string]) =

  setMnSettings(mode   = mode,
                window = window,
                left   = left,
                right  = right,
                contr  = contr,
                savn   = savn,
                actn   = actn)
  setElmSettings(loc_img   = loc_img,
                 loc_uid   = loc_uid,
                 loc_label = loc_label,
                 loc_text  = loc_text,
                 health    = health,
                 hp        = hp,
                 travel_cb = travel_cb,
                 travel_dt = travel_dt,
                 load_cb   = load_cb,
                 load_data = load_data)
  if mode == 0: # 0 is set as initial, 1 is for update
    setLayout(window = window,
              main   = main,
              left   = left,
              right  = right,
              contr  = contr,
              savn   = savn,
              actn   = actn,
              loc_label = loc_label,
              health    = health,
              buttons   = buttons,
              travel_cb = travel_cb,
              save_txt  = save_txt,
              load_cb   = load_cb)