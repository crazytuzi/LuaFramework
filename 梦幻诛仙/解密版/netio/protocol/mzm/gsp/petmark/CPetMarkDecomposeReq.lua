local CPetMarkDecomposeReq = class("CPetMarkDecomposeReq")
CPetMarkDecomposeReq.TYPEID = 12628512
function CPetMarkDecomposeReq:ctor(pet_mark_id)
  self.id = 12628512
  self.pet_mark_id = pet_mark_id or nil
end
function CPetMarkDecomposeReq:marshal(os)
  os:marshalInt64(self.pet_mark_id)
end
function CPetMarkDecomposeReq:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
end
function CPetMarkDecomposeReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkDecomposeReq
