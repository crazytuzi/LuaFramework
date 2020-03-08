local SBridalChamberErrorRes = class("SBridalChamberErrorRes")
SBridalChamberErrorRes.TYPEID = 12604955
SBridalChamberErrorRes.ALREDY_SUPPORTED = 1
SBridalChamberErrorRes.ALREDY_END = 2
function SBridalChamberErrorRes:ctor(result, args)
  self.id = 12604955
  self.result = result or nil
  self.args = args or {}
end
function SBridalChamberErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SBridalChamberErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SBridalChamberErrorRes:sizepolicy(size)
  return size <= 65535
end
return SBridalChamberErrorRes
