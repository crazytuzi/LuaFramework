local SBaoTuNormalResult = class("SBaoTuNormalResult")
SBaoTuNormalResult.TYPEID = 12583685
SBaoTuNormalResult.ERR_BAG_IS_FULL = 0
function SBaoTuNormalResult:ctor(result)
  self.id = 12583685
  self.result = result or nil
end
function SBaoTuNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SBaoTuNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SBaoTuNormalResult:sizepolicy(size)
  return size <= 65535
end
return SBaoTuNormalResult
