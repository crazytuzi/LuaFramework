local CMassWeddingSignUpReq = class("CMassWeddingSignUpReq")
CMassWeddingSignUpReq.TYPEID = 12604931
function CMassWeddingSignUpReq:ctor(myPrice)
  self.id = 12604931
  self.myPrice = myPrice or nil
end
function CMassWeddingSignUpReq:marshal(os)
  os:marshalInt32(self.myPrice)
end
function CMassWeddingSignUpReq:unmarshal(os)
  self.myPrice = os:unmarshalInt32()
end
function CMassWeddingSignUpReq:sizepolicy(size)
  return size <= 65535
end
return CMassWeddingSignUpReq
