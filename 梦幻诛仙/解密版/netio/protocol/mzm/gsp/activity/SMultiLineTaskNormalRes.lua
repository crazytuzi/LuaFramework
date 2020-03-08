local SMultiLineTaskNormalRes = class("SMultiLineTaskNormalRes")
SMultiLineTaskNormalRes.TYPEID = 12587607
SMultiLineTaskNormalRes.ALREADY_OWN_GRAPH = 1
function SMultiLineTaskNormalRes:ctor(result, args)
  self.id = 12587607
  self.result = result or nil
  self.args = args or {}
end
function SMultiLineTaskNormalRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SMultiLineTaskNormalRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SMultiLineTaskNormalRes:sizepolicy(size)
  return size <= 65535
end
return SMultiLineTaskNormalRes
