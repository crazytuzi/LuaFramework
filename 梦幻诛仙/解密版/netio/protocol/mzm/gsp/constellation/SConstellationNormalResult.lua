local SConstellationNormalResult = class("SConstellationNormalResult")
SConstellationNormalResult.TYPEID = 12612098
SConstellationNormalResult.CHOOSE_CARD__ALREADY = 1
SConstellationNormalResult.CONSTELLATION__NOT_OPEN = 2
function SConstellationNormalResult:ctor(result)
  self.id = 12612098
  self.result = result or nil
end
function SConstellationNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SConstellationNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SConstellationNormalResult:sizepolicy(size)
  return size <= 65535
end
return SConstellationNormalResult
