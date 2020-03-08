local SMassWeddingReSignUpErrorRes = class("SMassWeddingReSignUpErrorRes")
SMassWeddingReSignUpErrorRes.TYPEID = 12604933
SMassWeddingReSignUpErrorRes.NOT_COUPLE = 1
SMassWeddingReSignUpErrorRes.MONEY_NOT_ENOUGH = 2
SMassWeddingReSignUpErrorRes.NEVER_SIGN_UP = 3
SMassWeddingReSignUpErrorRes.PRICE_NOT_ENOUGH = 4
function SMassWeddingReSignUpErrorRes:ctor(result, args)
  self.id = 12604933
  self.result = result or nil
  self.args = args or {}
end
function SMassWeddingReSignUpErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SMassWeddingReSignUpErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SMassWeddingReSignUpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingReSignUpErrorRes
