local SRoleDyeResult = class("SRoleDyeResult")
SRoleDyeResult.TYPEID = 12597256
SRoleDyeResult.ERROR_UNKNOWN = 0
SRoleDyeResult.ERROR_DEL_CLOTH_ID = 1
SRoleDyeResult.ERROR_DEL_DEFAULT_ID = 2
SRoleDyeResult.ERROR_DEL_CUR_ID = 3
SRoleDyeResult.ERROR_USE_CLOTH_ID = 4
SRoleDyeResult.ERROR_ADD_OVER_MAX = 5
SRoleDyeResult.ERROR_ADD_COLOR_ID = 6
SRoleDyeResult.ERROR_ADD_NO_ENOUTH = 7
SRoleDyeResult.ERROR_ADD_OVERLAP = 8
SRoleDyeResult.ERROR_YUANBAO_NOT_ENOUGH = 9
function SRoleDyeResult:ctor(resultcode)
  self.id = 12597256
  self.resultcode = resultcode or nil
end
function SRoleDyeResult:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SRoleDyeResult:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SRoleDyeResult:sizepolicy(size)
  return size <= 65535
end
return SRoleDyeResult
