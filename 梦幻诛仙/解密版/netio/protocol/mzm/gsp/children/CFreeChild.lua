local CFreeChild = class("CFreeChild")
CFreeChild.TYPEID = 12609335
function CFreeChild:ctor(child_id)
  self.id = 12609335
  self.child_id = child_id or nil
end
function CFreeChild:marshal(os)
  os:marshalInt64(self.child_id)
end
function CFreeChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CFreeChild:sizepolicy(size)
  return size <= 65535
end
return CFreeChild
