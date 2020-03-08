local SClearLineInfoFailRep = class("SClearLineInfoFailRep")
SClearLineInfoFailRep.TYPEID = 12617254
SClearLineInfoFailRep.ERROR_SYSTEM = -1
SClearLineInfoFailRep.ERROR_USERID = -2
SClearLineInfoFailRep.ERROR_CFG = -3
SClearLineInfoFailRep.ERROR_ANSWERER_CANNOT_CLEAR = -4
SClearLineInfoFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -5
SClearLineInfoFailRep.ERROR_NOT_IN_TEAM = -6
SClearLineInfoFailRep.ERROR_TIME_OUT = -7
SClearLineInfoFailRep.ERROR_NOT_IN_GAME = -8
function SClearLineInfoFailRep:ctor(error_code, params)
  self.id = 12617254
  self.error_code = error_code or nil
  self.params = params or {}
end
function SClearLineInfoFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SClearLineInfoFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SClearLineInfoFailRep:sizepolicy(size)
  return size <= 65535
end
return SClearLineInfoFailRep
