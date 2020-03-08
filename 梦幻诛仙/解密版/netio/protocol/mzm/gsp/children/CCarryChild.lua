local CCarryChild = class("CCarryChild")
CCarryChild.TYPEID = 12609292
function CCarryChild:ctor(child_id)
  self.id = 12609292
  self.child_id = child_id or nil
end
function CCarryChild:marshal(os)
  os:marshalInt64(self.child_id)
end
function CCarryChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CCarryChild:sizepolicy(size)
  return size <= 65535
end
return CCarryChild
