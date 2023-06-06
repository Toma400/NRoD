import std/tables
import nigui
import nrod

let w_x* = 830
let w_y* = 490

proc setMnSettings (mode: int, window: Window, layouts: OrderedTable[string, LayoutContainer], left: LayoutContainer, right: LayoutContainer,
                    contr: LayoutContainer, trav: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer, shpn: LayoutContainer, hntn: LayoutContainer) =
  if mode == 0: # initial value
    window.width  = w_x
    window.height = w_y
  left.frame    = newFrame()
  right.frame   = newFrame()
  contr.frame   = newFrame()
  trav.frame    = newFrame("Travel")
  savn.frame    = newFrame("Save/Load")
  shpn.frame    = newFrame("Shop")
  hntn.frame    = newFrame("Hunt")
  layouts["money"].frame  = newFrame("Money")
  layouts["att"].frame    = newFrame("Attack")
  layouts["def"].frame    = newFrame("Defence")
  layouts["hunt_p"].frame = newFrame("Hunting")
  layouts["hunt_c"].frame = newFrame("Creature")
  layouts["hunt_b"].frame = newFrame("Beast Info")
  left.xAlign  = XAlign_Center
  left.yAlign  = YAlign_Center
  right.xAlign = XAlign_Center
  right.yAlign = YAlign_Center
  contr.xAlign = XAlign_Center
  contr.yAlign = YAlign_Center
  trav.xAlign  = XAlign_Center
  trav.yAlign  = YAlign_Center
  savn.xAlign  = XAlign_Center
  savn.yAlign  = YAlign_Center
  actn.xAlign  = XAlign_Center
  actn.yAlign  = YAlign_Center
  shpn.xAlign  = XAlign_Center
  shpn.yAlign  = YAlign_Center
  hntn.xAlign  = XAlign_Center
  hntn.yAlign  = YAlign_Center
  layouts["money"].xAlign  = XAlign_Center
  layouts["att"].xAlign    = XAlign_Center
  layouts["def"].xAlign    = XAlign_Center
  layouts["hunt_p"].xAlign = XAlign_Center
  layouts["hunt_c"].xAlign = XAlign_Center
  layouts["hunt_d"].xAlign = XAlign_Center
  layouts["hunt_b"].xAlign = XAlign_Center
  layouts["money"].yAlign  = YAlign_Center
  layouts["att"].yAlign    = YAlign_Center
  layouts["def"].yAlign    = YAlign_Center
  layouts["hunt_p"].yAlign = YAlign_Center
  layouts["hunt_c"].yAlign = YAlign_Center
  layouts["hunt_d"].yAlign = YAlign_Center
  layouts["hunt_b"].yAlign = YAlign_Center
  left.padding  = (w_x/4).int
  # actn.padding  = (w_y/6).int
  left.setInnerSize(width=(w_x/2).int,  height=w_y)
  right.setInnerSize(width=(w_x/2).int, height=w_y)
  actn.setInnerSize(width=(w_x/2).int,  height=(w_y/2).int)
  window.iconPath = "assets/nr_nomad_camp.png"# bcsd() & "/bcs/assets/graphical/bcs.png"
# left.x      = 0
# left.y      = 0
# left.width  = w_x/2.int
# left.height = w_y
# right.x     = w_x/2.int
# right.y     = 0
# right.width = w_x
# right.y     = w_y

proc setElmSettings (loc_img: Image, loc_imt: OrderedTableRef[string, Image], loc_uid: string, loc_label: Label, loc_text: string,
                     health: ProgressBar, hp: int, travel_cb: ComboBox, travel_dt: seq[string], shop_cb: ComboBox, shop_dt: seq[string],
                     load_cb: ComboBox, load_data: seq[string]) =
  # ---- this section is not-prerended form
  try:    loc_img.loadFromFile("assets/" & loc_uid & ".png")
  except: loc_img.loadFromFile("assets/q_mark.png")
  # ---- this section is not-prerended form
  loc_label.yTextAlign    = YTextAlign_Center
  loc_label.text          = " " & loc_text & " "
  health.value            = hp/100
  travel_cb.options       = travel_dt
  shop_cb.options         = shop_dt
  load_cb.options         = load_data

proc setLayout (window: Window, layouts: OrderedTable[string, LayoutContainer], labels: OrderedTable[string, Label],
                main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                contr: LayoutContainer, trav: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer, shpn: LayoutContainer, hntn: LayoutContainer,
                loc_label: Label, states: seq[Label], health: ProgressBar, buttons: OrderedTable[string, Button], travel_cb: ComboBox, shop_cb: ComboBox, save_txt: TextBox, load_cb: ComboBox) =
  block wContainers:
    window.add(main)
    main.add(left)
    main.add(right)
  block wElements:
    right.add(loc_label)
    right.add(health)
  block wControl:
    right.add(contr)
    contr.add(layouts["money"])
    contr.add(layouts["att"])
    contr.add(layouts["def"])
    layouts["money"].add(states[0])
    layouts["att"].add(states[1])
    layouts["def"].add(states[2])
  block wTravel:
    right.add(trav)
    trav.add(buttons["travel"])
    trav.add(travel_cb)
  block wSaveLoad:
    right.add(savn)
    savn.add(save_txt)
    savn.add(buttons["save"])
    savn.add(buttons["load"])
    savn.add(load_cb)
  block wSegments:
    right.add(actn)
    actn.add(shpn)
    actn.add(hntn)
  block wShop:
    shpn.add(buttons["shop"])
    shpn.add(shop_cb)
  block wHunt:
    hntn.add(layouts["hunt_d"])
    layouts["hunt_d"].add(buttons["hunt"])
    layouts["hunt_d"].add(buttons["flee"])
    hntn.add(layouts["hunt_p"])
    hntn.add(layouts["hunt_c"])
    layouts["hunt_p"].add(labels["hunt_p"])
    layouts["hunt_c"].add(labels["hunt_c"])
    hntn.add(layouts["hunt_b"])
    layouts["hunt_b"].add(labels["hunt_b"])
    layouts["hunt_b"].add(labels["hunt_h"])
    layouts["hunt_b"].add(buttons["att"])

proc updateWindow* (mode: int, window: Window, layouts: OrderedTable[string, LayoutContainer], labels: OrderedTable[string, Label],
                    main: LayoutContainer, left: LayoutContainer, right: LayoutContainer,
                    contr: LayoutContainer, trav: LayoutContainer, savn: LayoutContainer, actn: LayoutContainer, shpn: LayoutContainer, hntn: LayoutContainer,
                    loc_img: Image, loc_imt: OrderedTableRef[string, Image], loc_uid: string, loc_label: Label, loc_text: string,
                    states: seq[Label], health: ProgressBar, hp: int, buttons: OrderedTable[string, Button],
                    travel_cb: ComboBox, travel_dt: seq[string], shop_cb: ComboBox, shop_dt: seq[string],
                    save_txt: TextBox, load_cb: ComboBox, load_data: seq[string]) =

  setMnSettings(mode    = mode,
                window  = window,
                layouts = layouts,
                left   = left,
                right  = right,
                contr  = contr,
                trav   = trav,
                savn   = savn,
                actn   = actn,
                shpn   = shpn,
                hntn   = hntn)
  setElmSettings(loc_img   = loc_img,
                 loc_imt   = loc_imt,
                 loc_uid   = loc_uid,
                 loc_label = loc_label,
                 loc_text  = loc_text,
                 health    = health,
                 hp        = hp,
                 travel_cb = travel_cb,
                 travel_dt = travel_dt,
                 shop_cb   = shop_cb,
                 shop_dt   = shop_dt,
                 load_cb   = load_cb,
                 load_data = load_data)
  if mode == 0: # 0 is set as initial, 1 is for update
    setLayout(window  = window,
              layouts = layouts,
              labels  = labels,
              main   = main,
              left   = left,
              right  = right,
              contr  = contr,
              trav   = trav,
              savn   = savn,
              actn   = actn,
              shpn   = shpn,
              hntn   = hntn,
              loc_label = loc_label,
              states    = states,
              health    = health,
              buttons   = buttons,
              travel_cb = travel_cb,
              shop_cb   = shop_cb,
              save_txt  = save_txt,
              load_cb   = load_cb)