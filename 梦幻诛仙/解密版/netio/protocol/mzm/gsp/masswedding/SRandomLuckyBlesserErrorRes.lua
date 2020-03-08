local SRandomLuckyBlesserErrorRes = class("SRandomLuckyBlesserErrorRes")
SRandomLuckyBlesserErrorRes.TYPEID = 12604957
SRandomLuckyBlesserErrorRes.NOT_HAS_BLESSED_ROLE = 1
SRandomLuckyBlesserErrorRes.ALREADY_BLESSED = 2
function SRandomLuckyBlesserErrorRes:ctor(result, args)
  self.id = 12604957
  self.result = result or nil
  self.args = args or {}
end
function SRandomLuckyBlesserErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SRandomLuckyBlesserErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SRandomLuckyBlesserErrorRes:sizepolicy(size)
  return size <= 65535
end
return SRandomLuckyBlesserErrorRes
