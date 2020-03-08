local SChangeSignStrReq = class("SChangeSignStrReq")
SChangeSignStrReq.TYPEID = 12589942
function SChangeSignStrReq:ctor(result, signStr)
  self.id = 12589942
  self.result = result or nil
  self.signStr = signStr or nil
end
function SChangeSignStrReq:marshal(os)
  os:marshalInt32(self.result)
  os:marshalString(self.signStr)
end
function SChangeSignStrReq:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.signStr = os:unmarshalString()
end
function SChangeSignStrReq:sizepolicy(size)
  return size <= 65535
end
return SChangeSignStrReq
