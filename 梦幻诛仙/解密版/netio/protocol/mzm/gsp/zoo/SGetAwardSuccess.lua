local SGetAwardSuccess = class("SGetAwardSuccess")
SGetAwardSuccess.TYPEID = 12615442
function SGetAwardSuccess:ctor(animalid)
  self.id = 12615442
  self.animalid = animalid or nil
end
function SGetAwardSuccess:marshal(os)
  os:marshalInt64(self.animalid)
end
function SGetAwardSuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function SGetAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAwardSuccess
