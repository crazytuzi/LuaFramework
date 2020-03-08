local SZhenfaErrorInfo = class("SZhenfaErrorInfo")
SZhenfaErrorInfo.TYPEID = 12593155
SZhenfaErrorInfo.ZHENFA_BOOK_NOT_EXIST = 1
SZhenfaErrorInfo.ZHENFA_STUDY_ERROR = 2
SZhenfaErrorInfo.ZHENFA_ITEM_TYPE_ERROR = 3
SZhenfaErrorInfo.ZHENFA_DELETE_ITEM_ERROR = 4
function SZhenfaErrorInfo:ctor(resCode)
  self.id = 12593155
  self.resCode = resCode or nil
end
function SZhenfaErrorInfo:marshal(os)
  os:marshalInt32(self.resCode)
end
function SZhenfaErrorInfo:unmarshal(os)
  self.resCode = os:unmarshalInt32()
end
function SZhenfaErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SZhenfaErrorInfo
