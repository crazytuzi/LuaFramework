local CMassWeddingSignUpInfo = class("CMassWeddingSignUpInfo")
CMassWeddingSignUpInfo.TYPEID = 12604930
function CMassWeddingSignUpInfo:ctor()
  self.id = 12604930
end
function CMassWeddingSignUpInfo:marshal(os)
end
function CMassWeddingSignUpInfo:unmarshal(os)
end
function CMassWeddingSignUpInfo:sizepolicy(size)
  return size <= 65535
end
return CMassWeddingSignUpInfo
