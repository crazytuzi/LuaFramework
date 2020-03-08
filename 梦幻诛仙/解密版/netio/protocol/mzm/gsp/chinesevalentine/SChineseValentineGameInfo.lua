local SChineseValentineGameInfo = class("SChineseValentineGameInfo")
SChineseValentineGameInfo.TYPEID = 12622086
function SChineseValentineGameInfo:ctor(roleIdList, roundNumber, rightCount, wrongCount)
  self.id = 12622086
  self.roleIdList = roleIdList or {}
  self.roundNumber = roundNumber or nil
  self.rightCount = rightCount or nil
  self.wrongCount = wrongCount or nil
end
function SChineseValentineGameInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.roleIdList))
  for _, v in ipairs(self.roleIdList) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.roundNumber)
  os:marshalInt32(self.rightCount)
  os:marshalInt32(self.wrongCount)
end
function SChineseValentineGameInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.roleIdList, v)
  end
  self.roundNumber = os:unmarshalInt32()
  self.rightCount = os:unmarshalInt32()
  self.wrongCount = os:unmarshalInt32()
end
function SChineseValentineGameInfo:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineGameInfo
