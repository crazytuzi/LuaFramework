local SMassWeddingReSignUpRes = class("SMassWeddingReSignUpRes")
SMassWeddingReSignUpRes.TYPEID = 12604964
function SMassWeddingReSignUpRes:ctor(addPrice)
  self.id = 12604964
  self.addPrice = addPrice or nil
end
function SMassWeddingReSignUpRes:marshal(os)
  os:marshalInt32(self.addPrice)
end
function SMassWeddingReSignUpRes:unmarshal(os)
  self.addPrice = os:unmarshalInt32()
end
function SMassWeddingReSignUpRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingReSignUpRes
