local CAgreeOrRefuseDrawAndGuessReq = class("CAgreeOrRefuseDrawAndGuessReq")
CAgreeOrRefuseDrawAndGuessReq.TYPEID = 12617235
function CAgreeOrRefuseDrawAndGuessReq:ctor(operator, sessionId)
  self.id = 12617235
  self.operator = operator or nil
  self.sessionId = sessionId or nil
end
function CAgreeOrRefuseDrawAndGuessReq:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionId)
end
function CAgreeOrRefuseDrawAndGuessReq:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function CAgreeOrRefuseDrawAndGuessReq:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseDrawAndGuessReq
