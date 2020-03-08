local SMassWeddingSignUpInfo = class("SMassWeddingSignUpInfo")
SMassWeddingSignUpInfo.TYPEID = 12604934
function SMassWeddingSignUpInfo:ctor(signUpInfos, myPrice, rank)
  self.id = 12604934
  self.signUpInfos = signUpInfos or {}
  self.myPrice = myPrice or nil
  self.rank = rank or nil
end
function SMassWeddingSignUpInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.signUpInfos))
  for _, v in ipairs(self.signUpInfos) do
    v:marshal(os)
  end
  os:marshalInt32(self.myPrice)
  os:marshalInt32(self.rank)
end
function SMassWeddingSignUpInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.masswedding.SignUpInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.signUpInfos, v)
  end
  self.myPrice = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
end
function SMassWeddingSignUpInfo:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingSignUpInfo
