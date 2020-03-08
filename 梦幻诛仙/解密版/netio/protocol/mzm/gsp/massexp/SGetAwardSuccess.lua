local SGetAwardSuccess = class("SGetAwardSuccess")
SGetAwardSuccess.TYPEID = 12608263
function SGetAwardSuccess:ctor(status)
  self.id = 12608263
  self.status = status or nil
end
function SGetAwardSuccess:marshal(os)
  os:marshalInt32(self.status)
end
function SGetAwardSuccess:unmarshal(os)
  self.status = os:unmarshalInt32()
end
function SGetAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAwardSuccess
