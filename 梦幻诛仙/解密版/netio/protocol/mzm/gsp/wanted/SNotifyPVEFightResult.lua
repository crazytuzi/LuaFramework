local SNotifyPVEFightResult = class("SNotifyPVEFightResult")
SNotifyPVEFightResult.TYPEID = 12620291
SNotifyPVEFightResult.SUCCESS = 1
SNotifyPVEFightResult.FAIL = 2
function SNotifyPVEFightResult:ctor(result, passiveNameList, fightCount)
  self.id = 12620291
  self.result = result or nil
  self.passiveNameList = passiveNameList or {}
  self.fightCount = fightCount or nil
end
function SNotifyPVEFightResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.passiveNameList))
  for _, v in ipairs(self.passiveNameList) do
    os:marshalOctets(v)
  end
  os:marshalInt32(self.fightCount)
end
function SNotifyPVEFightResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.passiveNameList, v)
  end
  self.fightCount = os:unmarshalInt32()
end
function SNotifyPVEFightResult:sizepolicy(size)
  return size <= 65535
end
return SNotifyPVEFightResult
