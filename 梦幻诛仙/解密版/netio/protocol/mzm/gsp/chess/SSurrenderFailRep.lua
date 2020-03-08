local SSurrenderFailRep = class("SSurrenderFailRep")
SSurrenderFailRep.TYPEID = 12619031
SSurrenderFailRep.NOT_IN_CHESS_GAME = -1
SSurrenderFailRep.NOT_SELF_ROUND = -2
SSurrenderFailRep.SURRENDER_ROUND_NOT_ENOUGH = -3
function SSurrenderFailRep:ctor(error_code, params)
  self.id = 12619031
  self.error_code = error_code or nil
  self.params = params or {}
end
function SSurrenderFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SSurrenderFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SSurrenderFailRep:sizepolicy(size)
  return size <= 65535
end
return SSurrenderFailRep
