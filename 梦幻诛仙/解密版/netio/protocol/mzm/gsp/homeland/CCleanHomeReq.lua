local CCleanHomeReq = class("CCleanHomeReq")
CCleanHomeReq.TYPEID = 12605480
function CCleanHomeReq:ctor(area)
  self.id = 12605480
  self.area = area or nil
end
function CCleanHomeReq:marshal(os)
  os:marshalInt32(self.area)
end
function CCleanHomeReq:unmarshal(os)
  self.area = os:unmarshalInt32()
end
function CCleanHomeReq:sizepolicy(size)
  return size <= 65535
end
return CCleanHomeReq
