local SAppendLineInfoFailRep = class("SAppendLineInfoFailRep")
SAppendLineInfoFailRep.TYPEID = 12617240
SAppendLineInfoFailRep.ERROR_SYSTEM = -1
SAppendLineInfoFailRep.ERROR_USERID = -2
SAppendLineInfoFailRep.ERROR_CFG = -3
SAppendLineInfoFailRep.ERROR_ANSWERER_CANNOT_DRAW = -4
SAppendLineInfoFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -5
SAppendLineInfoFailRep.ERROR_NOT_IN_TEAM = -6
SAppendLineInfoFailRep.ERROR_TIME_OUT = -7
SAppendLineInfoFailRep.ERROR_POINTS_ILLEGAL = -8
SAppendLineInfoFailRep.ERROR_NOT_IN_GAME = -9
function SAppendLineInfoFailRep:ctor(error_code, params)
  self.id = 12617240
  self.error_code = error_code or nil
  self.params = params or {}
end
function SAppendLineInfoFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SAppendLineInfoFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SAppendLineInfoFailRep:sizepolicy(size)
  return size <= 65535
end
return SAppendLineInfoFailRep
