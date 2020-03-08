local SStartBreedBabyChildSuccess = class("SStartBreedBabyChildSuccess")
SStartBreedBabyChildSuccess.TYPEID = 12609312
function SStartBreedBabyChildSuccess:ctor(operator, child_id)
  self.id = 12609312
  self.operator = operator or nil
  self.child_id = child_id or nil
end
function SStartBreedBabyChildSuccess:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.child_id)
end
function SStartBreedBabyChildSuccess:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.child_id = os:unmarshalInt64()
end
function SStartBreedBabyChildSuccess:sizepolicy(size)
  return size <= 65535
end
return SStartBreedBabyChildSuccess
