local SConfirmErrBro = class("SConfirmErrBro")
SConfirmErrBro.TYPEID = 12617986
function SConfirmErrBro:ctor(confirmType)
  self.id = 12617986
  self.confirmType = confirmType or nil
end
function SConfirmErrBro:marshal(os)
  os:marshalInt32(self.confirmType)
end
function SConfirmErrBro:unmarshal(os)
  self.confirmType = os:unmarshalInt32()
end
function SConfirmErrBro:sizepolicy(size)
  return size <= 65535
end
return SConfirmErrBro
