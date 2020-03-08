local CPetSoulInitPropReq = class("CPetSoulInitPropReq")
CPetSoulInitPropReq.TYPEID = 12590672
function CPetSoulInitPropReq:ctor(petId, pos, propIndex)
  self.id = 12590672
  self.petId = petId or nil
  self.pos = pos or nil
  self.propIndex = propIndex or nil
end
function CPetSoulInitPropReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.propIndex)
end
function CPetSoulInitPropReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.propIndex = os:unmarshalInt32()
end
function CPetSoulInitPropReq:sizepolicy(size)
  return size <= 65535
end
return CPetSoulInitPropReq
