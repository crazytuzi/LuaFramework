local SMultiOccupationNormalResult = class("SMultiOccupationNormalResult")
SMultiOccupationNormalResult.TYPEID = 12606983
SMultiOccupationNormalResult.ACTIVATE__LEVEL_LIMIT = 1
SMultiOccupationNormalResult.ACTIVATE__LACK_YUANBAO = 2
SMultiOccupationNormalResult.ACTIVATE__IN_TEAM = 3
SMultiOccupationNormalResult.ACTIVATE__COOL_DOWN = 4
SMultiOccupationNormalResult.ACTIVATE__LACK_GOLD = 5
SMultiOccupationNormalResult.SWITCH__LACK_GOLD = 11
SMultiOccupationNormalResult.SWITCH__IN_TEAM = 12
SMultiOccupationNormalResult.SWITCH__COOL_DOWN = 13
function SMultiOccupationNormalResult:ctor(result)
  self.id = 12606983
  self.result = result or nil
end
function SMultiOccupationNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SMultiOccupationNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SMultiOccupationNormalResult:sizepolicy(size)
  return size <= 65535
end
return SMultiOccupationNormalResult
