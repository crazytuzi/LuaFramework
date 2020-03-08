local CStartBreedBabyChild = class("CStartBreedBabyChild")
CStartBreedBabyChild.TYPEID = 12609318
function CStartBreedBabyChild:ctor(operator, child_id)
  self.id = 12609318
  self.operator = operator or nil
  self.child_id = child_id or nil
end
function CStartBreedBabyChild:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.child_id)
end
function CStartBreedBabyChild:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.child_id = os:unmarshalInt64()
end
function CStartBreedBabyChild:sizepolicy(size)
  return size <= 65535
end
return CStartBreedBabyChild
