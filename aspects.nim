import std/options
import std/tables

# <--- Item --->
type Item* = object
  name*: string
  uid*:  string     # unique ID (used for saves)
  cost*: int
  att*:  int
  def*:  int
  eff*:  Table[string, int]

# <--- Beast --->
type Beast* = object
  name*: string
  hp*:   int
  att*:  int
  def*:  int
  rew*:  int

# <--- Location --->
type Location* = object
  name*:    string
  uid*:     string      # unique ID (used for saves)

# <--- Player --->
type Player* = object
  hp*:    int
  money*: int
  inv*:   seq[Item]
  att*:   int
  def*:   int
  loc*:   Location
  hunt*:  bool
  crea*:  Option[Beast]
  crew*:  int