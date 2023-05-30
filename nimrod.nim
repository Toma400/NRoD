import std/random
import strutils
import os

#----------------------------------------------
# NIMROD game (Nim-Risk-of-Death)
# ---
# (c) 2023 Tomasz Stępień, All Rights Reserved
# ---
# You can freely append new elements through
# Nimrod expandable system via source code
# (items, mobs, locations). See notes below.
#
# *  means proc/function
# ** means object

# TODO
# - save system (.bat file passing args?)
# - getting loc list and item list by JSON/YAML?
#   - this'd allow for some getter of .nim files
#     outside of main one? (I hope)

echo "«¤÷==========÷¤.__.¤÷==========÷¤»"
args: seq[string] = commandLineParams()

# <--- Item --->
type Item = object
  name: string
  cost: int
  att:  int
  def:  int
#-----------------
# You can add new items here (used in *Shop in initial list of contents)
proc ItemSword(): Item =
  return Item(name: "sword", cost: 20, att: 5, def: 0)
proc ItemChestplate(): Item =
  return Item(name: "chestplate", cost: 30, att: 0, def: 3)

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
proc BeastForestSpirit(): Beast =
  return Beast(name: "Forest Spirit", hp: rand(20..35), att: rand(3..6), def: rand(5..9))

proc BeastCreeper(): Beast =
  return Beast(name: "Creeper", hp: rand(1..10), att: rand(0..50), def: 0)
proc BeastEnderman(): Beast =
  return Beast(name: "Enderman", hp: 15, att: rand(1..3), def: 20)
proc BeastZombie(): Beast =
  return Beast(name: "Zombie", hp: rand(30..35), att: rand(2..4), def: rand(0..2))
proc BeastSkeleton(): Beast =
  return Beast(name: "Skeleton", hp: rand(15..25), att: rand(8..12), def: rand(0..1))

# <--- Location --->
type Location = object
  name:   string
  beasts: seq[Beast]
#-----------------
# You can add new locations here (used in *Travel in initial destination list)
proc LocationBaedoor(): Location =
  return Location(name: "Baedoor", beasts: @[BeastGhoul()])
proc LocationHauntedForest(): Location =
  return Location(name: "Haunted Forest", beasts: @[BeastForestSpirit()])
proc LocationOverworld(): Location =
  return Location(name: "Overworld", beasts: @[BeastCreeper(), BeastEnderman(), BeastZombie(), BeastSkeleton()])

# <--- Player --->
type Player = object
  hp:    int
  money: int
  inv:   seq[string]
  att:   int
  def:   int
  loc:   Location
proc PlayerNew(): Player =
  return Player(hp: 100, money: 0, inv: @[], att: rand(1..3), def: 0, loc: LocationBaedoor())
proc addToInv(self: var Player, item: Item) =
  self.inv.add(item.name)
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
  let shop_contents = @[ItemSword(), ItemChestplate()] # add more contents for them to be visible in-game
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
  var monster = sample(player.loc.beasts)
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
  let destinations = @[LocationBaedoor(), LocationHauntedForest(), LocationOverworld()]  # add more locations for them to be visible in-game
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
      if intut >= destinations.len and player.loc != destinations[intut-1]:
        echo "Travelling to: ", destinations[intut-1].name
        player.loc = destinations[intut-1]
        break
      else: continue
    except: continue

#==============================
# SAVE
#==============================
proc save(player: var Player) =
  let name = ""
  let bat = &"""
  @echo off
  nimrod.exe {player.hp} {player.money} {player.att} {player.def}
  """ # no loc, because it's object (going back to default loc? or find_loc_by_id?)
  # inv also should be reworked ig

#==============================
# THE GAME CORE
#==============================
var player = PlayerNew()

while true:
  if player.hp <= 0: death()
  echo "--------------------------"
  echo ":: "&player.loc.name
  echo "--------------------------"
  echo "HP: ", $player.hp, " | $: ", $player.money
  echo "⚔︎: ", $player.att, " | ⛊: ", $player.def
  echo "--------------------------"
  echo "Press 1 to buy equipment"
  echo "Press 2 to search for beast"
  echo "Press 3 to travel"
  var input = readLine(stdin)
  if input == $1:
    shop(player)
  elif input == $2:
    hunt(player)
  elif input == $3:
    travel(player)
  elif input == "cheat":
    player.money += 30
  elif input == "x" or input == "X":
    break
  else:
    echo "This is not valid choice"
    sleep 2000
    echo "            v            "
    continue