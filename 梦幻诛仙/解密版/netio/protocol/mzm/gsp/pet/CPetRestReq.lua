local CPetRestReq = class("CPetRestReq")
CPetRestReq.TYPEID = 12590595
function CPetRestReq:ctor(petId)
  self.id = 12590595
  self.petId = petId or nil
end
function CPetRestReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CPetRestReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CPetRestReq:sizepolicy(size)
  return size <= 65535
end
return CPetRestReq
