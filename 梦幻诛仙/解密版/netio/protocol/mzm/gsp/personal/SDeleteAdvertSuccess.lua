local SDeleteAdvertSuccess = class("SDeleteAdvertSuccess")
SDeleteAdvertSuccess.TYPEID = 12603665
function SDeleteAdvertSuccess:ctor(advertType)
  self.id = 12603665
  self.advertType = advertType or nil
end
function SDeleteAdvertSuccess:marshal(os)
  os:marshalInt32(self.advertType)
end
function SDeleteAdvertSuccess:unmarshal(os)
  self.advertType = os:unmarshalInt32()
end
function SDeleteAdvertSuccess:sizepolicy(size)
  return size <= 65535
end
return SDeleteAdvertSuccess
