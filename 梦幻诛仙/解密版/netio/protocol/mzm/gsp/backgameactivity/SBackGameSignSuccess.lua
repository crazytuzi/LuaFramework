local SBackGameSignSuccess = class("SBackGameSignSuccess")
SBackGameSignSuccess.TYPEID = 12620551
function SBackGameSignSuccess:ctor(index)
  self.id = 12620551
  self.index = index or nil
end
function SBackGameSignSuccess:marshal(os)
  os:marshalInt32(self.index)
end
function SBackGameSignSuccess:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function SBackGameSignSuccess:sizepolicy(size)
  return size <= 65535
end
return SBackGameSignSuccess
