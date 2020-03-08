local CSetQilinModeReq = class("CSetQilinModeReq")
CSetQilinModeReq.TYPEID = 12584851
function CSetQilinModeReq:ctor(mode)
  self.id = 12584851
  self.mode = mode or nil
end
function CSetQilinModeReq:marshal(os)
  os:marshalInt32(self.mode)
end
function CSetQilinModeReq:unmarshal(os)
  self.mode = os:unmarshalInt32()
end
function CSetQilinModeReq:sizepolicy(size)
  return size <= 65535
end
return CSetQilinModeReq
