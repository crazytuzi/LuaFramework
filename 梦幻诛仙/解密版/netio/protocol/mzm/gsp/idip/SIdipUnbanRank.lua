local SIdipUnbanRank = class("SIdipUnbanRank")
SIdipUnbanRank.TYPEID = 12601097
function SIdipUnbanRank:ctor(rankType)
  self.id = 12601097
  self.rankType = rankType or nil
end
function SIdipUnbanRank:marshal(os)
  os:marshalInt32(self.rankType)
end
function SIdipUnbanRank:unmarshal(os)
  self.rankType = os:unmarshalInt32()
end
function SIdipUnbanRank:sizepolicy(size)
  return size <= 65535
end
return SIdipUnbanRank
