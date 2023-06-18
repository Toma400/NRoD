import "../../aspects"
import "../../registry"
import std/tables

proc ItemHeavyIronArmor* (): Item =
  return Item(name: "Heavy Iron Armor", uid: "nr:heavy_iron_armor", cost: 60, att: -3, def: 8, eff: {"": 0}.toTable)

registry.items.add(ItemHeavyIronArmor())
registry.location_market_shop.add(ItemHeavyIronArmor())