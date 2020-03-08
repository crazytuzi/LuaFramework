local ErrorInfo = class("ErrorInfo")
ErrorInfo.TYPEID = 102
function ErrorInfo:ctor(errcode, info)
  self.id = 102
  self.errcode = errcode or nil
  self.info = info or nil
end
function ErrorInfo:marshal(os)
  os:marshalInt32(self.errcode)
  os:marshalOctets(self.info)
end
function ErrorInfo:unmarshal(os)
  self.errcode = os:unmarshalInt32()
  self.info = os:unmarshalOctets()
end
function ErrorInfo:sizepolicy(size)
  return size <= 256
end
return ErrorInfo
