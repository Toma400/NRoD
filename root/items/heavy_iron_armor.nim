import "../../aspects"
import "../../registry"
import std/tables

# such system would allow us to modify statistics from outside sources (other files)
  # those could be later included in `proc`, but be still modified
  # this may be how location shop contents could be handled, with possibility to append from item registry
      # var cost* = 60
      # var att*  = -3
      # var def*  = 8
      # var eff*  = {"": 0}.toTable

proc ItemHeavyIronArmor* (): Item =
  return Item(name: "Heavy Iron Armor", uid: "nr:heavy_iron_armor", cost: 60, att: -3, def: 8, eff: {"": 0}.toTable)

registry.items.add(ItemHeavyIronArmor())
registry.location_market_shop.add(ItemHeavyIronArmor())