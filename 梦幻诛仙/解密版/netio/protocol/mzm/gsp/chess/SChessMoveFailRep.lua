local SChessMoveFailRep = class("SChessMoveFailRep")
SChessMoveFailRep.TYPEID = 12619029
SChessMoveFailRep.NOT_IN_CHESS_GAME = -1
SChessMoveFailRep.NOT_SELF_ROUND = -2
SChessMoveFailRep.MOVE_FROM_CELL_NOT_EXIST = -3
SChessMoveFailRep.MOVE_FROM_CELL_EMPTY = -4
SChessMoveFailRep.MOVE_FROM_CELL_IS_ENEMY = -5
SChessMoveFailRep.MOVE_FROM_CELL_NOT_VISIBLE = -6
SChessMoveFailRep.MOVE_TO_CELL_NOT_EXIST = -7
SChessMoveFailRep.MOVE_TO_CELL_UNREACHABLE = -8
SChessMoveFailRep.MOVE_TO_CELL_NOT_ENEMY = -9
SChessMoveFailRep.MOVE_TO_CELL_ENEMY_TOO_STRONG = -10
SChessMoveFailRep.OPERATE_TOO_FAST = -11
function SChessMoveFailRep:ctor(error_code, params)
  self.id = 12619029
  self.error_code = error_code or nil
  self.params = params or {}
end
function SChessMoveFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SChessMoveFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SChessMoveFailRep:sizepolicy(size)
  return size <= 65535
end
return SChessMoveFailRep
