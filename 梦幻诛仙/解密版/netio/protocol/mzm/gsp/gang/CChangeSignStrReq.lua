local CChangeSignStrReq = class("CChangeSignStrReq")
CChangeSignStrReq.TYPEID = 12589934
function CChangeSignStrReq:ctor(signStr)
  self.id = 12589934
  self.signStr = signStr or nil
end
function CChangeSignStrReq:marshal(os)
  os:marshalString(self.signStr)
end
function CChangeSignStrReq:unmarshal(os)
  self.signStr = os:unmarshalString()
end
function CChangeSignStrReq:sizepolicy(size)
  return size <= 65535
end
return CChangeSignStrReq
