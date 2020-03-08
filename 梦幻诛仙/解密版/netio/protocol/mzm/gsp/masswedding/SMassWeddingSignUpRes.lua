local SMassWeddingSignUpRes = class("SMassWeddingSignUpRes")
SMassWeddingSignUpRes.TYPEID = 12604963
function SMassWeddingSignUpRes:ctor(myPrice)
  self.id = 12604963
  self.myPrice = myPrice or nil
end
function SMassWeddingSignUpRes:marshal(os)
  os:marshalInt32(self.myPrice)
end
function SMassWeddingSignUpRes:unmarshal(os)
  self.myPrice = os:unmarshalInt32()
end
function SMassWeddingSignUpRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingSignUpRes
