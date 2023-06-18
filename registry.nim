import std/options
import std/random
import std/tables
import aspects
##########################################################################################################
# ITEMS #
##########################################################################################################
# - create procedure
# - add into 'items' registry seq
# - add into 'shop' registry seq if required
# - add into 'use' if item has special effects
#=========================================================================================================
# Procedure Builders
proc ItemMachete*(): Item =
  return Item(name: "Machete",               uid: "nr:machete",               cost: 20, att: 5, def: 0, eff: {}.toTable)
proc ItemSturdyTunic*(): Item =
  return Item(name: "Sturdy Tunic",          uid: "nr:sturdy_tunic",          cost: 30, att: 0, def: 3, eff: {}.toTable)
proc ItemSmallHealingPotion*(): Item =
  return Item(name: "Small Healing Potion",  uid: "nr:small_healing_potion",  cost: 9,  att: 0, def: 0, eff: {"heal": 15}.toTable)
proc ItemMediumHealingPotion*(): Item =
  return Item(name: "Medium Healing Potion", uid: "nr:medium_healing_potion", cost: 15, att: 0, def: 0, eff: {"heal": 30}.toTable)
proc ItemLargeHealingPotion*(): Item =
  return Item(name: "Large Healing Potion",  uid: "nr:large_healing_potion",  cost: 27, att: 0, def: 0, eff: {"heal": 60}.toTable)

# Item Registry
var items* = @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion(), ItemMediumHealingPotion(), ItemLargeHealingPotion()]

##########################################################################################################
# BEASTS #
##########################################################################################################
# - create procedure
# - add into 'beasts' registry seq to fill location
#=========================================================================================================
# Procedure Builders
proc BeastGhoul*(): Beast =
  return Beast(name: "Ghoul", hp: rand(30..50), att: rand(1..5), def: rand(1..3), rew: rand(10..20))
proc BeastIrradiatedRat*(): Beast =
  return Beast(name: "Irradiated Rat", hp: rand(10..20), att: rand(1..3), def: rand(2..4), rew: rand(5..10))
proc BeastRatKing*(): Beast =
  return Beast(name: "Rat King", hp: rand(70..80), att: rand(1..9), def: rand(2..4), rew: rand(40..90))

##########################################################################################################
# LOCATIONS #
##########################################################################################################
# - create procedure
# - add into 'locations' registry seq
# - add into 'roads' registry seq to make respective connections
#=========================================================================================================
# Procedure Builders
proc LocationNomadCamp*(): Location =
  return Location(name: "Nomad Camp",
                  uid: "nr:nomad_camp")
proc LocationNomadCampMarket*(): Location =
  return Location(name: "Nomad Camp Market",
                  uid: "nr:nomad_camp_market")
proc LocationWastes*(): Location =
  return Location(name: "Wastes",
                  uid: "nr:wastes")
proc LocationNomadCampRoad*(): Location =
  return Location(name: "Nomad Camp Road",
                  uid:  "nr:nomad_camp_road")

# Location Registry
let locations* = @[LocationNomadCamp(), LocationNomadCampMarket(), LocationWastes(), LocationNomadCampRoad()]
# TODO:
var location_market_shop* = @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion(), ItemMediumHealingPotion(), ItemLargeHealingPotion()]

##########################################################################################################
# PROCEDURES #
##########################################################################################################
# Shop Item Choice Registry
proc shop*(loc: Location): seq[Item] =
  if loc.uid == LocationNomadCampMarket().uid: return location_market_shop
  else: return @[]

# Location Connections Registry
proc roads*(loc: Location): seq[Location] =
  if   loc.uid == LocationNomadCamp().uid:       return @[LocationNomadCampMarket(), LocationNomadCampRoad()]
  elif loc.uid == LocationNomadCampRoad().uid:   return @[LocationWastes(), LocationNomadCamp()]
  elif loc.uid == LocationNomadCampMarket().uid: return @[LocationNomadCamp()]
  elif loc.uid == LocationWastes().uid:          return @[LocationNomadCampRoad()]
  else: return @[]

# Distribution helper for Beasts Fill Registry
proc ampl(bt: Table[Beast, int]): seq[Beast] =
  var ret = newSeq[Beast](0)
  for b, n in bt.pairs:
    for _ in 0..n-1:
      ret.add(b)
  echo $ret
  return ret

# Beasts Fill Registry
proc beasts*(loc: Location): seq[Beast] =
  if   loc.uid == LocationWastes().uid:        return ampl({BeastGhoul(): 1}.toTable)
  elif loc.uid == LocationNomadCampRoad().uid: return ampl({BeastIrradiatedRat(): 50, BeastRatKing(): 1}.toTable)
  else: return @[]

# Item Effects Registry
proc use*(player: var Player, item: Item) =
  if "heal" in item.eff.keys:
    player.hp += item.eff["heal"]
    if player.hp > 100:
      player.hp = 100 # fixing overvaluing

##########################################################################################################
# BUILDERS & UTILS #
##########################################################################################################
proc playerNew*(): Player =
  return Player(hp: 100, money: 0, inv: @[], att: rand(1..3), def: 0, loc: LocationNomadCamp(), hunt: false, crea: none(Beast), crew: 0)
proc addToInv*(self: var Player, item: Item) =
  self.inv.add(item)
  self.att += item.att
  self.def += item.def