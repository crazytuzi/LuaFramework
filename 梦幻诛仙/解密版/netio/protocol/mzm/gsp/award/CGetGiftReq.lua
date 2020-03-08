local CGetGiftReq = class("CGetGiftReq")
CGetGiftReq.TYPEID = 12583446
function CGetGiftReq:ctor(useType)
  self.id = 12583446
  self.useType = useType or nil
end
function CGetGiftReq:marshal(os)
  os:marshalInt32(self.useType)
end
function CGetGiftReq:unmarshal(os)
  self.useType = os:unmarshalInt32()
end
function CGetGiftReq:sizepolicy(size)
  return size <= 65535
end
return CGetGiftReq
