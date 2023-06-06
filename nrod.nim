# import dir_crawler; loadResources()
# import dir_result
import std/options
import std/random
import std/tables
import strutils
# import aspects
import nigui
import gui
import os

#----------------------------------------------
# NROD game (Near-Risk-of-Death)
# ---
# (c) 2023 Tomasz Stępień, All Rights Reserved
#----------------------------------------------
let nrod_v   = "0.2" # version
#----------------------------------------------
let args     = os.commandLineParams()
var terminal = "-terminal" in args

# TODO:
# - making wider options for items?
#   - ranged, but has ammo which needs to be bought
#   - melee, just as it was
#   (pick is before attack, reload takes one turn)
#   - potions/food
# - pushing locations/items/creatures onto folders
#   (gathering .nim files by some crawler)
# - GUI
# - location images

# - collab with Kari? (rybiczki-mutanty)

#==============================
# INITIALISER
#==============================
if not dirExists("saves"): createDir("saves")
if terminal:
  echo "<-------=====-o.__.o-=====------->"
  echo "N R O D"
  echo "Near"
  echo "Risk of Death"
  echo "<-------=====--------=====------->"
  echo "TIP: Write -save [name]- to save, -load [name]- to load previously saved game"
  echo "TIP: Write -x- to exit the game"
  echo "------------------"
  echo "loading ..."
  # timer between this
  # loadResources()
  # import dir_result
  # and this (= performance of mods)
  sleep(2000)

#==============================

# <--- Item --->
type Item = object
  name: string
  uid:  string     # unique ID (used for saves)
  cost: int
  att:  int
  def:  int
  eff:  bool
#-----------------
# You can add new items here (used in *Shop in initial list of contents)
proc ItemMachete(): Item =
  return Item(name: "Machete", uid: "nr_machete", cost: 20, att: 5, def: 0, eff: false)
proc ItemSturdyTunic(): Item =
  return Item(name: "Sturdy Tunic", uid: "nr_sturdy_tunic", cost: 30, att: 0, def: 3, eff: false)
proc ItemSmallHealingPotion(): Item =
  return Item(name: "Small Healing Potion", uid: "nr_small_healing_potion", cost: 10, att: 0, def: 0, eff: true)

# item registry (should be filled for save system)
let items = @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion()]

# <--- Beast --->
type Beast = object
  name: string
  hp:   int
  att:  int
  def:  int
#-----------------
# You can add new beasts here (used in **Location in 'beasts' list)
proc BeastGhoul(): Beast =
  return Beast(name: "Ghoul", hp: rand(30..50), att: rand(1..5), def: rand(1..3))

# <--- Location --->
type Location = object
  name:    string
  uid:     string      # unique ID (used for saves)
  is_shop: bool
#-----------------
# You can add new locations here (used in *Travel in initial destination list)
proc LocationNomadCamp(): Location =
  return Location(name: "Nomad Camp",
                  uid: "nr_nomad_camp",
                  is_shop: false)
proc LocationNomadCampMarket(): Location =
  return Location(name: "Nomad Camp Market",
                  uid: "nr_nomad_camp_market",
                  is_shop: true)
proc LocationWastes(): Location =
  return Location(name: "Wastes",
                  uid: "nr_wastes",
                  is_shop: false)

# location registry (should be filled for save system)
let locations = @[LocationNomadCamp(), LocationNomadCampMarket(), LocationWastes()]

# shops in locations
proc shop(loc: Location): seq[Item] =
  if loc.uid == LocationNomadCampMarket().uid: return @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion()]
  else: return @[]

proc shopData(loc: Location): seq[seq[string]] =
  var it_uids: seq[string]
  var it_names: seq[string]
  for item in loc.shop():
    it_uids.add(item.uid)
    it_names.add(item.name & ": " & $item.cost)
  return @[it_uids, it_names]

# travelling roads to locations
proc roads(loc: Location): seq[Location] =
  if   loc.uid == LocationNomadCamp().uid:       return @[LocationNomadCampMarket(), LocationWastes()]
  elif loc.uid == LocationNomadCampMarket().uid: return @[LocationNomadCamp()]
  elif loc.uid == LocationWastes().uid:          return @[LocationNomadCamp()]
  else: return @[]

proc roadsData(loc: Location): seq[seq[string]] =
  var loc_uids: seq[string]
  var loc_names: seq[string]
  for locg in loc.roads():
    loc_uids.add(locg.uid)
    loc_names.add(locg.name)
  return @[loc_uids, loc_names]

proc roadsUid(loc: Location): seq[string] =
  var loc_seq: seq[string]
  for locg in loc.roads():
    loc_seq.add(locg.uid)
  return loc_seq

proc roadsNames(loc: Location): seq[string] =
  var loc_seq: seq[string]
  for locg in loc.roads():
    loc_seq.add(locg.name)
  return loc_seq

# list of beasts in locations
proc beasts(loc: Location): seq[Beast] =
  if loc.uid == LocationWastes().uid: return @[BeastGhoul()]
  else: return @[]

# <--- Player --->
type Player = object
  hp:    int
  money: int
  inv:   seq[Item]
  att:   int
  def:   int
  loc:   Location
  hunt:  bool
  crea:  Option[Beast]
proc playerNew(): Player =
  return Player(hp: 100, money: 0, inv: @[], att: rand(1..3), def: 0, loc: LocationNomadCamp(), hunt: false, crea: none(Beast))
proc addToInv(self: var Player, item: Item) =
  self.inv.add(item)
  self.att += item.att
  self.def += item.def
proc use(player: var Player, item: Item) =
  if item.eff:
    if item.uid == ItemSmallHealingPotion().uid: player.hp = player.hp + 15
  if player.hp > 100: player.hp = 100 # fixing overvaluing

#==============================
# HELPERS
#==============================
proc itemBrowse(suid: string): Item =
  for it in items:
    if it.uid == suid: return it

proc locationBrowse(suid: string): Location =
  for loc in locations:
    if loc.uid == suid: return loc
  return LocationNomadCamp()

proc saveBrowse(): seq[string] =
  var files: seq[string]
  for file in walkFiles("saves/*.ns"):
    files.add file.replace(r"saves\", "").replace(".ns", "")
  return files

proc returnCell (pos: int, axis: string): int =
  var svc: float
  if axis.toLower == "x": svc = w_x / 100
  else:                   svc = w_y / 100
  return (pos.float * svc).int

#==============================
# MAIN EVENTS
#==============================
proc death() =
  echo "Your journey has ended... you died! Better luck in afterlife!"
  var input = readLine(stdin)
  quit(0)

#==============================
# FUNCS
#==============================
# --- SHOP ---
type BuyResult = enum BUY_FAILED, BOUGHT

proc buy(player: var Player, item: Item): BuyResult =
  if player.money >= item.cost:
    player.money -= item.cost
    addToInv(player, item)
    if item.eff:
      player.use(item)
    return BOUGHT
  else:
    return BUY_FAILED

proc shop(player: var Player) =
  let shop_contents = player.loc.shop() # add more contents for them to be visible in-game
  while true:
    echo "--------------------------"
    for item in shop_contents:
      echo item.name, " | $: ", $item.cost
    echo "--------------------------"
    echo "Select item to buy"
    echo "Press 'x' to come back"
    var input = readLine(stdin)
    if input == "x" or input == "X":
      break
    try:
      var intut = parseInt(input)
      try:
        if intut <= shop_contents.len:
           if buy(player, shop_contents[intut-1]) == BOUGHT:
             echo "Bought ", shop_contents[intut-1].name, "!"
           else:
             echo "You don't have enough money for that!"
             sleep 2000
        else: continue
      except: continue
    except: continue

#==============================
# FIGHT
#==============================
proc hunt(player: var Player) =
  var monster = sample(player.loc.beasts())
  echo "You start the fight with: ", monster.name, ". Be ready!"
  echo "If you want to flee, use 'x' key"
  sleep 2000
  while true:
    echo "-----------///-----------"
    echo "[", monster.hp, "] /// [", player.hp, "]"
    echo "-----------***-----------"
    var mt = monster.att + rand(3..5)
    var pt = player.att + rand(3..5)
    echo "[",   mt, ">>>"
    echo "<<<", pt, "]"
    monster.hp -= (pt - player.def)
    player.hp  -= (mt - monster.def)

    if monster.hp <= 0:
      var money = rand(10..20)
      echo "You slayed that beast! You earn ", $money, "$ from it."
      player.money += money
      var fin = readLine(stdin)
      break
    elif player.hp <= 0:
      break
    var stop = readLine(stdin)
    if stop == "x" or stop == "X":
      break

#==============================
# FIGHT
#==============================
proc travel(player: var Player) =
  let destinations = player.loc.roads()  # add more locations for them to be visible in-game
  while true:
    echo "--------------------------"
    echo "You decided to travel:"
    echo "--------------------------"
    for i in destinations:
      echo i.name
    echo "--------------------------"
    var input = readLine(stdin)
    if input == "x" or input == "X":
      break
    try:
      var intut = parseInt(input)
      if intut <= destinations.len and intut > 0:
        echo "Travelling to: ", destinations[intut-1].name
        player.loc = destinations[intut-1]
        break
      else: continue
    except: continue

#==============================
# SAVE
#==============================
proc save(save_name: string, player: var Player) =
  try:
    let exp_path = "saves/" & save_name & ".ns"
    let f = open(exp_path, fmWrite)
    block saves:
      f.writeLine($player.hp)      # line 1 (i0)
      f.writeLine($player.money)   # line 2 (i1)
      f.writeLine($player.att)     # line 3 (i2)
      f.writeLine($player.def)     # line 4 (i3)
      f.writeLine($player.loc.uid) # line 5 (i4)
      for item in player.inv:      # lines 6+ (i5+)
        f.writeLine(item.uid)
    f.close()
    echo "Successfully saved game as -" & save_name & "-"
    sleep(1000)
  except:
    echo "Couldn't save the same"
    sleep(1000)

proc load(ask: string, cur_p: Player): Player =
  try:
    let imp_path = "saves/" & ask & ".ns"
    var p = playerNew()
    block loads:
      let lseq = readLines(imp_path, 5)
      p.hp    = parseInt(lseq[0])
      p.money = parseInt(lseq[1])
      p.att   = parseInt(lseq[2])
      p.def   = parseInt(lseq[3])
      p.loc   = locationBrowse(lseq[4])
      for ix, line in lseq:
        if ix > 4:
          let ir = itemBrowse(line)
          if ir of Item: p.inv.add(ir)

    echo "Successfully loaded game as -" & ask & "-"
    sleep(1000)
    return p
  except:
    echo "Couldn't load the game"
    sleep(1000)
    return cur_p

#==============================
# THE GAME CORE
#==============================
var player = playerNew()

# <--------------------- TERMINAL ----------------------->
if terminal:
  while true:
    if player.hp <= 0: death()
    let can_shop   = player.loc.is_shop
    let can_travel = player.loc.roads().len > 0
    let can_hunt   = player.loc.beasts().len > 0

    echo "--------------------------"
    echo ":: "&player.loc.name
    echo "--------------------------"
    echo "HP: ", $player.hp, " | $: ", $player.money
    echo "AT: ", $player.att, " | D: ", $player.def
    echo "--------------------------"
    if can_shop:   echo "Press 1 to buy equipment"
    if can_hunt:   echo "Press 2 to search for beast"
    if can_travel: echo "Press 3 to travel"
    #---------------------------
    var input = readLine(stdin)
    if input == $1 and player.loc.is_shop:
      shop(player)
    elif input == $2:
      hunt(player)
    elif input == $3 and can_travel:
      travel(player)
    elif input == "cheat":
      player.money += 30
    elif "save " in input:
      save(input.replace("save ", ""), player)
    elif "load " in input:
      player = load(input.replace("load ", ""), player)
    elif input == "x" or input == "X":
      break
    else:
      echo "This is not valid choice"
      sleep 2000
      echo "            v            "
      continue

# <----------------------- GUI ---------------------------->
else:
  app.init()

  var window = newWindow("Near Risk of Death")

  # Containers
  var main   = newLayoutContainer(Layout_Horizontal)
  var left   = newLayoutContainer(Layout_Vertical)
  var right  = newLayoutContainer(Layout_Vertical)
  var contr  = newLayoutContainer(Layout_Horizontal) # control container   | control info
  var cnt1   = newLayoutContainer(Layout_Horizontal)   # money
  var cnt2   = newLayoutContainer(Layout_Horizontal)   # attack
  var cnt3   = newLayoutContainer(Layout_Horizontal)   # defence
  var trav   = newLayoutContainer(Layout_Horizontal) # travel container    | travel buttons
  var savn   = newLayoutContainer(Layout_Horizontal) # save/load container | save/load system
  var actn   = newLayoutContainer(Layout_Horizontal) # action container    | processing events
  var shpn   = newLayoutContainer(Layout_Vertical)   # shop container
  var hntn   = newLayoutContainer(Layout_Vertical)   # hunt container
  var hntd   = newLayoutContainer(Layout_Horizontal) # hunt decisions
  var hnta   = newLayoutContainer(Layout_Horizontal) # hunt player
  var hntc   = newLayoutContainer(Layout_Horizontal) # hunt creature
  var hntb   = newLayoutContainer(Layout_Horizontal) # hunt beast info

  # Elements
  var loc_img = newImage()
  # --- prerendering of images ---
  var loc_imt = newOrderedTable[string, Image]()
  for loc in locations:
    var tmp_img = newImage()
    try:    tmp_img.loadFromFile("assets/" & loc.uid & ".png")
    except: tmp_img.loadFromFile("assets/q_mark.png")
    loc_imt[loc.uid] = tmp_img

  var loc_label = newLabel(player.loc.name)
  var states    = @[newLabel($player.money),
                    newLabel($player.att),
                    newLabel($player.def)]
  var health    = newProgressBar()
  var shop_bt   = newButton("Buy the item")
  var hunt_bt   = newButton("Hunt")
  var att_bt    = newButton("Attack")
  var flee_bt   = newButton("Flee")
  var travel_bt = newButton("Travel")
  var travel_cb = newComboBox(player.loc.roadsData()[1])
  var shop_cb   = newComboBox(player.loc.shopData()[1])
  var hnta_lab  = newLabel(" ")    # hunt section: attack (player)
  var hntc_lab  = newLabel(" ")                  # attack (creature)
  var hntb_lab  = newLabel(" ")                  # info   (beast name)
  var hntb_hp   = newProgressBar()               # health (beast)
  var save_txt  = newTextBox()
  var save_bt   = newButton("Save") # up to change when it's overwrite
  var load_bt   = newButton("Load")
  var load_cb   = newComboBox(saveBrowse())

  proc updateStates(mode: int = 0) =
      # MODES
      # 0 - general
      # 1 - shop
      # 2 - hunt
      # 3 - statistics
      if mode == 0 or mode == 1:
        if shop(player.loc).len > 0: shop_bt.enabled = true;  shop_bt.text = "Buy the item"
        else:                        shop_bt.enabled = false; shop_bt.text = "No shop in this location"
        if shop_cb.index >= 0:
          if itemBrowse(player.loc.shopData()[0][shop_cb.index]).cost > player.money:
            shop_bt.enabled = false
        else: shop_bt.enabled = false
      if mode == 0 or mode == 2:
        if player.loc.beasts().len > 0:
          if player.hunt: travel_bt.enabled = false; save_bt.enabled = false; flee_bt.enabled = true;  hunt_bt.enabled = false; att_bt.enabled = true
          else:           travel_bt.enabled = true;  save_bt.enabled = true;  flee_bt.enabled = false; hunt_bt.enabled = true;  att_bt.enabled = false
        else:
          travel_bt.enabled = true; save_bt.enabled = true; hunt_bt.enabled = false; flee_bt.enabled = false; att_bt.enabled = false
      if mode == 0 or mode == 3:
        states[0].text = $player.money
        states[1].text = $player.att
        states[2].text = $player.def

  proc updateWindowRef(mode: int = 1) = # put there to not clutter the code with all arguments over and over
      updateWindow(mode     = mode,       # 0 is initial, 1 is update (default), 2 is minor update
                   window   = window,
                   layouts  = {"money":  cnt1,
                               "att":    cnt2,
                               "def":    cnt3,
                               "hunt_d": hntd,
                               "hunt_p": hnta,
                               "hunt_c": hntc,
                               "hunt_b": hntb}.toOrderedTable,
                   labels   = {"hunt_p": hnta_lab,
                               "hunt_c": hntc_lab,
                               "hunt_b": hntb_lab}.toOrderedTable,
                   main     = main,
                   left     = left,
                   right    = right,
                   contr    = contr,
                   trav     = trav,
                   savn     = savn,
                   actn     = actn,
                   shpn     = shpn,
                   hntn     = hntn,
                   loc_img   = loc_img,
                   loc_imt   = loc_imt,
                   loc_uid   = player.loc.uid,
                   loc_label = loc_label,
                   loc_text  = player.loc.name,
                   states    = states,
                   health    = health,
                   hp        = player.hp,
                   buttons   = {"travel": travel_bt,
                                "shop":   shop_bt,
                                "hunt":   hunt_bt,
                                "att":    att_bt,
                                "flee":   flee_bt,
                                "save":   save_bt,
                                "load":   load_bt}.toOrderedTable,
                   travel_cb = travel_cb,
                   travel_dt = player.loc.roadsData()[1],
                   shop_cb   = shop_cb,
                   shop_dt   = player.loc.shopData()[1],
                   save_txt  = save_txt,
                   load_cb   = load_cb,
                   load_data = saveBrowse())
      updateStates(mode=0)

  updateWindowRef(mode=0)

  left.onDraw = proc (event: DrawEvent) =
    let canvas = event.control.canvas
    canvas.drawImage(loc_img, x=returnCell(0, "X"), #loc_imt[player.loc.uid]
                              y=returnCell(0, "Y"),
                              width=(w_x/2).int)

  travel_bt.onClick = proc (event: ClickEvent) =
    player.loc = locationBrowse(player.loc.roadsData()[0][travel_cb.index])
    updateWindowRef()

  shop_cb.onChange = proc (event: ComboBoxChangeEvent) =
    updateStates(mode=1)

  shop_bt.onClick = proc (event: ClickEvent) =
    if shop_cb.index >= 0:
      discard player.buy(itemBrowse(player.loc.shopData()[0][shop_cb.index]))
    updateStates(mode=1)

  hunt_bt.onClick = proc (event: ClickEvent) =
    player.crea = some(sample(player.loc.beasts()))
    player.hunt = true
    hntb_lab.text = player.crea.get.name
    updateStates(mode=2)

  flee_bt.onClick = proc (event: ClickEvent) =
    player.crea = none(Beast)
    player.hunt = false
    hntb_lab.text = " "
    updateStates(mode=2)

  save_txt.onTextChange = proc (event: TextChangeEvent) =
    if save_txt.text in saveBrowse(): save_bt.text = "Overwrite"
    else:                             save_bt.text = "Save"

  save_bt.onClick = proc (event: ClickEvent) =
    save(save_txt.text, player)
    save_bt.text = "Saved!"

  load_bt.onClick = proc (event: ClickEvent) =
    player = load(load_cb.value, player)
    updateWindowRef()

  window.show()
  app.run()