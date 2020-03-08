local CObserveFightWithLeader = class("CObserveFightWithLeader")
CObserveFightWithLeader.TYPEID = 12594207
function CObserveFightWithLeader:ctor()
  self.id = 12594207
end
function CObserveFightWithLeader:marshal(os)
end
function CObserveFightWithLeader:unmarshal(os)
end
function CObserveFightWithLeader:sizepolicy(size)
  return size <= 65535
end
return CObserveFightWithLeader
