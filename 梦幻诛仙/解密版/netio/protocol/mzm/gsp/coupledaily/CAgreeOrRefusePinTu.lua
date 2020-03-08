local CAgreeOrRefusePinTu = class("CAgreeOrRefusePinTu")
CAgreeOrRefusePinTu.TYPEID = 12602384
function CAgreeOrRefusePinTu:ctor(operator, sessionId)
  self.id = 12602384
  self.operator = operator or nil
  self.sessionId = sessionId or nil
end
function CAgreeOrRefusePinTu:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionId)
end
function CAgreeOrRefusePinTu:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function CAgreeOrRefusePinTu:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefusePinTu
