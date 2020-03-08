local SUpdateRelationValue = class("SUpdateRelationValue")
SUpdateRelationValue.TYPEID = 12587010
function SUpdateRelationValue:ctor(friendId, relationValue)
  self.id = 12587010
  self.friendId = friendId or nil
  self.relationValue = relationValue or nil
end
function SUpdateRelationValue:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.relationValue)
end
function SUpdateRelationValue:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.relationValue = os:unmarshalInt32()
end
function SUpdateRelationValue:sizepolicy(size)
  return size <= 65535
end
return SUpdateRelationValue
