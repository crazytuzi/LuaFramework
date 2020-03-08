local SRemoveTitleOrAppellation = class("SRemoveTitleOrAppellation")
SRemoveTitleOrAppellation.TYPEID = 12593930
function SRemoveTitleOrAppellation:ctor(changeId, changeType)
  self.id = 12593930
  self.changeId = changeId or nil
  self.changeType = changeType or nil
end
function SRemoveTitleOrAppellation:marshal(os)
  os:marshalInt32(self.changeId)
  os:marshalInt32(self.changeType)
end
function SRemoveTitleOrAppellation:unmarshal(os)
  self.changeId = os:unmarshalInt32()
  self.changeType = os:unmarshalInt32()
end
function SRemoveTitleOrAppellation:sizepolicy(size)
  return size <= 65535
end
return SRemoveTitleOrAppellation
