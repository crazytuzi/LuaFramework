local SErrorInfo = class("SErrorInfo")
SErrorInfo.TYPEID = 12610306
SErrorInfo.ROLE_OFF_LINE = 1
SErrorInfo.DOING_GRAPH = 2
SErrorInfo.GRAPH_DONE = 3
SErrorInfo.GIVE_BIRTH_DAILED = 4
function SErrorInfo:ctor(errorCode, typeid)
  self.id = 12610306
  self.errorCode = errorCode or nil
  self.typeid = typeid or nil
end
function SErrorInfo:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.typeid)
end
function SErrorInfo:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.typeid = os:unmarshalInt32()
end
function SErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SErrorInfo
