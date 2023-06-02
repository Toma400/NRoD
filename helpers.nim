import std/strutils
import gui

type
  AXES* = enum
    X, Y

# Returns pixels of specific % of screen passed
proc returnCell* (pos: int, axis: AXES): int =
  var svc: float
  if axis == AXES.X: svc = w_x / 100
  else:              svc = w_y / 100
  return (pos.float * svc).int

# Returns pixels of specific % of screen passed
proc returnCells* (pos_x: int, pos_y: int): seq[int] =
    return @[returnCell(pos_x, AXES.X),
             returnCell(pos_y, AXES.Y)]