# <--- Item --->
type Item* = object
  name*: string
  uid*:  string     # unique ID (used for saves)
  cost*: int
  att*:  int
  def*:  int
  eff*:  bool

# <--- Beast --->
type Beast* = object
  name*: string
  hp*:   int
  att*:  int
  def*:  int

# <--- Location --->
type Location* = object
  name*:    string
  uid*:     string      # unique ID (used for saves)
  is_shop*: bool

# <--- Player --->
type Player* = object
  hp*:    int
  money*: int
  inv*:   seq[Item]
  att*:   int
  def*:   int
  loc*:   Location