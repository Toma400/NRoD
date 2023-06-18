# Modding Resources for NRoD
NRoD is modular game, meaning you can easily append more elements to it.
Let's look closer how can we do it.

## Items
Creating items is done via .nim files put in `res/items/` folder. Each .nim file
has such structure:
```nim
import "../../aspects"
import "../../registry"
import std/tables

proc [0]* (): Item =
  return Item(name: "[1]", uid: "[2]", cost: [3], att: [4], def: [5], eff: [6])
  
registry.items.add([0]())
```
First three lines you can just copy-paste, as those are required imports that you
need to make whenever you add new item. Let's explain next parts of the code.

### 1. Item element
Two next lines, being `proc` block, is where you create your item. It has several
elements you can change:
- [0] - class name for your item. Usually named `ItemYourItemName`,
- [1] - description name of your item. This will appear in game,
- [2] - unique ID of item. Usually follows `[mod_id]_[your_item_name_without_spaces]`,
- [3] - cost of the item in shop. Ranges from 0 to any integer-long number,
- [4] - attack value of item. Usually with positive value,
- [5] - defence value of item. Usually with positive value,
- [6] - table of item effects. Uses `{...}.toTable` table system (see section 3).

You can get better idea of how you can fill those informations by looking at example:
```nim
proc ItemHeavyIronArmor* (): Item =
  return Item(name: "Heavy Iron Armor", uid: "nr:heavy_iron_armor", cost: 60, att: -3, def: 8, eff: {}.toTable)
```
### 2. Registry
Once we are done with creating our item element, we need to add it to registry:
```nim
registry.items.add(...())
```
...where `...` is our item name. So in case of our previous example, we can register
the armor like that:
```nim
registry.items.add(ItemHeavyIronArmor())
```

### 3. Statistics

### 4. Shop registry