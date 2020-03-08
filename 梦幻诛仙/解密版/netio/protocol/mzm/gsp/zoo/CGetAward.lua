local CGetAward = class("CGetAward")
CGetAward.TYPEID = 12615441
function CGetAward:ctor(animalid)
  self.id = 12615441
  self.animalid = animalid or nil
end
function CGetAward:marshal(os)
  os:marshalInt64(self.animalid)
end
function CGetAward:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function CGetAward:sizepolicy(size)
  return size <= 65535
end
return CGetAward
