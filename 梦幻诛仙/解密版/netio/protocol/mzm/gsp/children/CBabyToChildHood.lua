local CBabyToChildHood = class("CBabyToChildHood")
CBabyToChildHood.TYPEID = 12609338
function CBabyToChildHood:ctor(child_id)
  self.id = 12609338
  self.child_id = child_id or nil
end
function CBabyToChildHood:marshal(os)
  os:marshalInt64(self.child_id)
end
function CBabyToChildHood:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CBabyToChildHood:sizepolicy(size)
  return size <= 65535
end
return CBabyToChildHood
