local SCommonErrorInfo = class("SCommonErrorInfo")
SCommonErrorInfo.TYPEID = 12607749
SCommonErrorInfo.NO_OCP = 1
function SCommonErrorInfo:ctor(errorCode)
  self.id = 12607749
  self.errorCode = errorCode or nil
end
function SCommonErrorInfo:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SCommonErrorInfo:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SCommonErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SCommonErrorInfo
