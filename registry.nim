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
  return Item(name: "Machete",               uid: "nr_machete",               cost: 20, att: 5, def: 0, eff: false)
proc ItemSturdyTunic*(): Item =
  return Item(name: "Sturdy Tunic",          uid: "nr_sturdy_tunic",          cost: 30, att: 0, def: 3, eff: false)
proc ItemSmallHealingPotion*(): Item =
  return Item(name: "Small Healing Potion",  uid: "nr_small_healing_potion",  cost: 9,  att: 0, def: 0, eff: true)
proc ItemMediumHealingPotion*(): Item =
  return Item(name: "Medium Healing Potion", uid: "nr_medium_healing_potion", cost: 15, att: 0, def: 0, eff: true)

# Item Registry
let items* = @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion(), ItemMediumHealingPotion()]

##########################################################################################################
# BEASTS #
##########################################################################################################
# - create procedure
# - add into 'beasts' registry seq to fill location
#=========================================================================================================
# Procedure Builders
proc BeastGhoul*(): Beast =
  return Beast(name: "Ghoul", hp: rand(30..50), att: rand(1..5), def: rand(1..3))

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
                  uid: "nr_nomad_camp",
                  is_shop: false)
proc LocationNomadCampMarket*(): Location =
  return Location(name: "Nomad Camp Market",
                  uid: "nr_nomad_camp_market",
                  is_shop: true)
proc LocationWastes*(): Location =
  return Location(name: "Wastes",
                  uid: "nr_wastes",
                  is_shop: false)

# Location Registry
let locations* = @[LocationNomadCamp(), LocationNomadCampMarket(), LocationWastes()]

# Shop Item Choice Registry
proc shop*(loc: Location): seq[Item] =
  if loc.uid == LocationNomadCampMarket().uid: return @[ItemMachete(), ItemSturdyTunic(), ItemSmallHealingPotion(), ItemMediumHealingPotion()]
  else: return @[]

# Location Connections Registry
proc roads*(loc: Location): seq[Location] =
  if   loc.uid == LocationNomadCamp().uid:       return @[LocationNomadCampMarket(), LocationWastes()]
  elif loc.uid == LocationNomadCampMarket().uid: return @[LocationNomadCamp()]
  elif loc.uid == LocationWastes().uid:          return @[LocationNomadCamp()]
  else: return @[]

# Beasts Fill Registry
proc beasts*(loc: Location): seq[Beast] =
  if loc.uid == LocationWastes().uid: return @[BeastGhoul()]
  else: return @[]

# Item Effects Registry
proc use*(player: var Player, item: Item) =
  if item.eff:
    if   item.uid == ItemSmallHealingPotion().uid:  player.hp = player.hp + 15
    elif item.uid == ItemMediumHealingPotion().uid: player.hp = player.hp + 30
  if player.hp > 100: player.hp = 100 # fixing overvaluing