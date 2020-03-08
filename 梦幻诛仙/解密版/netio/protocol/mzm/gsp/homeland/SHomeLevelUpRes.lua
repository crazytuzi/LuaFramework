local SHomeLevelUpRes = class("SHomeLevelUpRes")
SHomeLevelUpRes.TYPEID = 12605471
function SHomeLevelUpRes:ctor(homeLevel)
  self.id = 12605471
  self.homeLevel = homeLevel or nil
end
function SHomeLevelUpRes:marshal(os)
  os:marshalInt32(self.homeLevel)
end
function SHomeLevelUpRes:unmarshal(os)
  self.homeLevel = os:unmarshalInt32()
end
function SHomeLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SHomeLevelUpRes
