local SNotifyPVPFightResult = class("SNotifyPVPFightResult")
SNotifyPVPFightResult.TYPEID = 12620298
SNotifyPVPFightResult.SUCCESS = 1
SNotifyPVPFightResult.FAIL = 2
function SNotifyPVPFightResult:ctor(result, activeNameList, passiveNameList)
  self.id = 12620298
  self.result = result or nil
  self.activeNameList = activeNameList or {}
  self.passiveNameList = passiveNameList or {}
end
function SNotifyPVPFightResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.activeNameList))
  for _, v in ipairs(self.activeNameList) do
    os:marshalOctets(v)
  end
  os:marshalCompactUInt32(table.getn(self.passiveNameList))
  for _, v in ipairs(self.passiveNameList) do
    os:marshalOctets(v)
  end
end
function SNotifyPVPFightResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.activeNameList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.passiveNameList, v)
  end
end
function SNotifyPVPFightResult:sizepolicy(size)
  return size <= 65535
end
return SNotifyPVPFightResult
