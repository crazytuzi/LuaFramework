local SNotifyPVPFightTip = class("SNotifyPVPFightTip")
SNotifyPVPFightTip.TYPEID = 12620289
function SNotifyPVPFightTip:ctor(activeNameList, passiveNameList)
  self.id = 12620289
  self.activeNameList = activeNameList or {}
  self.passiveNameList = passiveNameList or {}
end
function SNotifyPVPFightTip:marshal(os)
  os:marshalCompactUInt32(table.getn(self.activeNameList))
  for _, v in ipairs(self.activeNameList) do
    os:marshalOctets(v)
  end
  os:marshalCompactUInt32(table.getn(self.passiveNameList))
  for _, v in ipairs(self.passiveNameList) do
    os:marshalOctets(v)
  end
end
function SNotifyPVPFightTip:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.activeNameList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.passiveNameList, v)
  end
end
function SNotifyPVPFightTip:sizepolicy(size)
  return size <= 65535
end
return SNotifyPVPFightTip
