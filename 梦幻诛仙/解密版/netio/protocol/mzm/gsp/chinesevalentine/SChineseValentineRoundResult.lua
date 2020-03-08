local SChineseValentineRoundResult = class("SChineseValentineRoundResult")
SChineseValentineRoundResult.TYPEID = 12622091
SChineseValentineRoundResult.SUCCESS = 1
SChineseValentineRoundResult.FAILED = 2
function SChineseValentineRoundResult:ctor(code, roundNumber)
  self.id = 12622091
  self.code = code or nil
  self.roundNumber = roundNumber or nil
end
function SChineseValentineRoundResult:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.roundNumber)
end
function SChineseValentineRoundResult:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.roundNumber = os:unmarshalInt32()
end
function SChineseValentineRoundResult:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineRoundResult
