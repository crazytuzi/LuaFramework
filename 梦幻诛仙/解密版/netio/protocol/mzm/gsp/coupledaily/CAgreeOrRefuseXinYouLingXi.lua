local CAgreeOrRefuseXinYouLingXi = class("CAgreeOrRefuseXinYouLingXi")
CAgreeOrRefuseXinYouLingXi.TYPEID = 12602379
function CAgreeOrRefuseXinYouLingXi:ctor(operator, sessionId)
  self.id = 12602379
  self.operator = operator or nil
  self.sessionId = sessionId or nil
end
function CAgreeOrRefuseXinYouLingXi:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionId)
end
function CAgreeOrRefuseXinYouLingXi:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionId = os:unmarshalInt64()
end
function CAgreeOrRefuseXinYouLingXi:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseXinYouLingXi
