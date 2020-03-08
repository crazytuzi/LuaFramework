local SMassWeddingSignUpErrorRes = class("SMassWeddingSignUpErrorRes")
SMassWeddingSignUpErrorRes.TYPEID = 12604932
SMassWeddingSignUpErrorRes.IN_FROCE_DIVORCE = 1
SMassWeddingSignUpErrorRes.NOT_COUPLE = 2
SMassWeddingSignUpErrorRes.MONEY_NOT_ENOUGH = 3
SMassWeddingSignUpErrorRes.ALREADY_SIGN_UP = 4
SMassWeddingSignUpErrorRes.PRICE_NOT_ENOUGH = 5
function SMassWeddingSignUpErrorRes:ctor(result, args)
  self.id = 12604932
  self.result = result or nil
  self.args = args or {}
end
function SMassWeddingSignUpErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SMassWeddingSignUpErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SMassWeddingSignUpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingSignUpErrorRes
