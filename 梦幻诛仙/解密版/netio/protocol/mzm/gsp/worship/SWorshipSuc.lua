local SWorshipSuc = class("SWorshipSuc")
SWorshipSuc.TYPEID = 12612615
function SWorshipSuc:ctor(worshipId, goldNum)
  self.id = 12612615
  self.worshipId = worshipId or nil
  self.goldNum = goldNum or nil
end
function SWorshipSuc:marshal(os)
  os:marshalInt32(self.worshipId)
  os:marshalInt32(self.goldNum)
end
function SWorshipSuc:unmarshal(os)
  self.worshipId = os:unmarshalInt32()
  self.goldNum = os:unmarshalInt32()
end
function SWorshipSuc:sizepolicy(size)
  return size <= 65535
end
return SWorshipSuc
