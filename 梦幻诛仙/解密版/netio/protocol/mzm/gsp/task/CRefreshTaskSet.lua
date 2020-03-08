local CRefreshTaskSet = class("CRefreshTaskSet")
CRefreshTaskSet.TYPEID = 12592133
function CRefreshTaskSet:ctor(npcId)
  self.id = 12592133
  self.npcId = npcId or nil
end
function CRefreshTaskSet:marshal(os)
  os:marshalInt32(self.npcId)
end
function CRefreshTaskSet:unmarshal(os)
  self.npcId = os:unmarshalInt32()
end
function CRefreshTaskSet:sizepolicy(size)
  return size <= 65535
end
return CRefreshTaskSet
