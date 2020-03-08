local CMassWeddingReSignUpReq = class("CMassWeddingReSignUpReq")
CMassWeddingReSignUpReq.TYPEID = 12604929
function CMassWeddingReSignUpReq:ctor(addPrice)
  self.id = 12604929
  self.addPrice = addPrice or nil
end
function CMassWeddingReSignUpReq:marshal(os)
  os:marshalInt32(self.addPrice)
end
function CMassWeddingReSignUpReq:unmarshal(os)
  self.addPrice = os:unmarshalInt32()
end
function CMassWeddingReSignUpReq:sizepolicy(size)
  return size <= 65535
end
return CMassWeddingReSignUpReq
