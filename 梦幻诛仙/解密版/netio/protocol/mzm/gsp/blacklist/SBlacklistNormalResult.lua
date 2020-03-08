local SBlacklistNormalResult = class("SBlacklistNormalResult")
SBlacklistNormalResult.TYPEID = 12588550
SBlacklistNormalResult.ADD_BLACK_ROLE__FRIEND = 1
SBlacklistNormalResult.ADD_BLACK_ROLE__FULL = 2
SBlacklistNormalResult.ADD_BLACK_ROLE__ALREADY = 3
SBlacklistNormalResult.DEL_BLACK_ROLE__ALREADY = 11
function SBlacklistNormalResult:ctor(result)
  self.id = 12588550
  self.result = result or nil
end
function SBlacklistNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SBlacklistNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SBlacklistNormalResult:sizepolicy(size)
  return size <= 65535
end
return SBlacklistNormalResult
