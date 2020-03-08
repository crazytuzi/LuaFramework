local SRpWingContentRep = class("SRpWingContentRep")
SRpWingContentRep.TYPEID = 12596539
function SRpWingContentRep:ctor(cfgId, resetType, curIds)
  self.id = 12596539
  self.cfgId = cfgId or nil
  self.resetType = resetType or nil
  self.curIds = curIds or {}
end
function SRpWingContentRep:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalUInt8(self.resetType)
  os:marshalCompactUInt32(table.getn(self.curIds))
  for _, v in ipairs(self.curIds) do
    os:marshalInt32(v)
  end
end
function SRpWingContentRep:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.resetType = os:unmarshalUInt8()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.curIds, v)
  end
end
function SRpWingContentRep:sizepolicy(size)
  return size <= 65535
end
return SRpWingContentRep
