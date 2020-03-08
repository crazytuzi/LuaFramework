local SResetWingRep = class("SResetWingRep")
SResetWingRep.TYPEID = 12596524
function SResetWingRep:ctor(cfgId, resetType, reIds)
  self.id = 12596524
  self.cfgId = cfgId or nil
  self.resetType = resetType or nil
  self.reIds = reIds or {}
end
function SResetWingRep:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalUInt8(self.resetType)
  os:marshalCompactUInt32(table.getn(self.reIds))
  for _, v in ipairs(self.reIds) do
    os:marshalInt32(v)
  end
end
function SResetWingRep:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.resetType = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.reIds, v)
  end
end
function SResetWingRep:sizepolicy(size)
  return size <= 65535
end
return SResetWingRep
