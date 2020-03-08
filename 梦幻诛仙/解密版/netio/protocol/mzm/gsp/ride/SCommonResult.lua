local SCommonResult = class("SCommonResult")
SCommonResult.TYPEID = 797959
SCommonResult.USE_DYE_ITEM_SUCCESS = 0
function SCommonResult:ctor(result)
  self.id = 797959
  self.result = result or nil
end
function SCommonResult:marshal(os)
  os:marshalInt32(self.result)
end
function SCommonResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SCommonResult:sizepolicy(size)
  return size <= 65535
end
return SCommonResult
