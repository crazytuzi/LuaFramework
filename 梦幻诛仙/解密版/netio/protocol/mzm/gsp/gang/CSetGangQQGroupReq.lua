local CSetGangQQGroupReq = class("CSetGangQQGroupReq")
CSetGangQQGroupReq.TYPEID = 12589949
function CSetGangQQGroupReq:ctor(groupOpenId)
  self.id = 12589949
  self.groupOpenId = groupOpenId or nil
end
function CSetGangQQGroupReq:marshal(os)
  os:marshalString(self.groupOpenId)
end
function CSetGangQQGroupReq:unmarshal(os)
  self.groupOpenId = os:unmarshalString()
end
function CSetGangQQGroupReq:sizepolicy(size)
  return size <= 65535
end
return CSetGangQQGroupReq
