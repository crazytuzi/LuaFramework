local SChessTurnOverFailRep = class("SChessTurnOverFailRep")
SChessTurnOverFailRep.TYPEID = 12619034
SChessTurnOverFailRep.NOT_IN_CHESS_GAME = -1
SChessTurnOverFailRep.NOT_SELF_ROUND = -2
SChessTurnOverFailRep.TURN_OVER_CELL_NOT_EXIST = -3
SChessTurnOverFailRep.TURN_OVER_CELL_EMPTY = -4
SChessTurnOverFailRep.TURN_OVER_CHESS_ALREADY_VISIBLE = -5
SChessTurnOverFailRep.OPERATE_TOO_FAST = -6
function SChessTurnOverFailRep:ctor(error_code, params)
  self.id = 12619034
  self.error_code = error_code or nil
  self.params = params or {}
end
function SChessTurnOverFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SChessTurnOverFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SChessTurnOverFailRep:sizepolicy(size)
  return size <= 65535
end
return SChessTurnOverFailRep
