import std/random
import strutils
import os

#----------------------------------------------
# NROD game (Near-Risk-of-Death)
# ---
# (c) 2023 Tomasz Stępień, All Rights Reserved
#----------------------------------------------
let nrod_v = "0.1" # version

# TODO:
# - making it post-apo
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

if not dirExists("saves"): createDir("saves")
echo "«¤÷==========÷¤.__.¤÷==========÷¤»"

# <--- Item --->
type Item = object
  name: string
  uid:  string     # unique ID (used for saves)
  cost: int
  att:  int
  def:  int
#-----------------
# You can add new items here (used in *Shop in initial list of contents)
proc ItemMachete(): Item =
  return Item(name: "Machete", uid: "nr_machete", cost: 20, att: 5, def: 0)
proc ItemSturdyTunic(): Item =
  return Item(name: "Sturdy Tunic", uid: "nr_sturdy_tunic", cost: 30, att: 0, def: 3)

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
proc LocationWastes(): Location = # non-accessible yet
  return Location(name: "Wastes",
                  uid: "nr_wastes",
                  is_shop: false)

# shops in locations
proc shop(loc: Location): seq[Item] =
  if loc.uid == LocationNomadCampMarket().uid: return @[ItemMachete(), ItemSturdyTunic()]
  else: return @[]

# travelling roads to locations
proc roads(loc: Location): seq[Location] =
  if   loc.uid == LocationNomadCamp().uid:       return @[LocationNomadCampMarket(), LocationWastes()]
  elif loc.uid == LocationNomadCampMarket().uid: return @[LocationNomadCamp()]
  elif loc.uid == LocationWastes().uid:          return @[LocationNomadCamp()]
  else: return @[]

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
proc PlayerNew(): Player =
  return Player(hp: 100, money: 0, inv: @[], att: rand(1..3), def: 0, loc: LocationNomadCamp())
proc addToInv(self: var Player, item: Item) =
  self.inv.add(item)
  self.att += item.att
  self.def += item.def

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
proc buy(player: var Player, item: Item) =
  if player.money >= item.cost:
    player.money -= item.cost
    addToInv(player, item)
    echo "Bought ", item.name, "!"
    sleep 2000
  else:
    echo "You don't have enough money for that!"

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
           buy(player, shop_contents[intut-1])
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
      if intut >= destinations.len:
        echo "Travelling to: ", destinations[intut-1].name
        player.loc = destinations[intut-1]
        break
      else: continue
    except: continue

#==============================
# SAVE
#==============================
proc save(save_name: string, player: var Player) =
  let exp_path = "saves/" & save_name & ".ns"
  let f = open(exp_path, fmWrite)
  block saves:
    f.writeLine($player.hp)
    f.writeLine($player.money)
    f.writeLine($player.att)
    f.writeLine($player.def)
    f.writeLine($player.loc.uid)
    for item in player.inv:
      f.writeLine(item.uid)
  f.close()
  echo "Successfully saved game as -" & save_name & "-"
  sleep(1000)

# proc load(ask: string): Player =
#   let path = "saves/" & ask & ".toml"

#==============================
# THE GAME CORE
#==============================
var player = PlayerNew()

while true:
  if player.hp <= 0: death()
  let can_shop   = player.loc.is_shop
  let can_travel = player.loc.roads().len > 0
  let can_hunt   = player.loc.beasts().len > 0

  echo "--------------------------"
  echo ":: "&player.loc.name
  echo "--------------------------"
  echo "HP: ", $player.hp, " | $: ", $player.money
  echo "§: ", $player.att, " | ¤: ", $player.def
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
  elif input == "x" or input == "X":
    break
  else:
    echo "This is not valid choice"
    sleep 2000
    echo "            v            "
    continue