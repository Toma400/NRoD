import "../../aspects"
import "../../registry"
import std/tables

proc ItemIronArmor* (): Item =
  return Item(name: "Iron Armor", uid: "nr:iron_armor", cost: 40, att: -1, def: 5, eff: {}.toTable)

registry.items.add(ItemIronArmor())
registry.location_market_shop.add(ItemIronArmor())