local SAgreeOrRefuseDrawAndGuessFailRep = class("SAgreeOrRefuseDrawAndGuessFailRep")
SAgreeOrRefuseDrawAndGuessFailRep.TYPEID = 12617250
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_SYSTEM = -1
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_USERID = -2
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_CFG = -3
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_MEMBER_IN_DRAW_AND_GUESS = -4
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_LEADER_CANNOT_CHOOSE = -5
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -6
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_NOT_IN_TEAM = -7
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_TIME_OUT = -8
SAgreeOrRefuseDrawAndGuessFailRep.ERROR_CHOOSED_ALREADY = -9
function SAgreeOrRefuseDrawAndGuessFailRep:ctor(error_code, params)
  self.id = 12617250
  self.error_code = error_code or nil
  self.params = params or {}
end
function SAgreeOrRefuseDrawAndGuessFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SAgreeOrRefuseDrawAndGuessFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SAgreeOrRefuseDrawAndGuessFailRep:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseDrawAndGuessFailRep
