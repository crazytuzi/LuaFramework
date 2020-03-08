local SPartnerNormalResult = class("SPartnerNormalResult")
SPartnerNormalResult.TYPEID = 12588038
SPartnerNormalResult.ALREADY_HAVE_PARTNER = 0
function SPartnerNormalResult:ctor(result, args)
  self.id = 12588038
  self.result = result or nil
  self.args = args or {}
end
function SPartnerNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SPartnerNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SPartnerNormalResult:sizepolicy(size)
  return size <= 65535
end
return SPartnerNormalResult
