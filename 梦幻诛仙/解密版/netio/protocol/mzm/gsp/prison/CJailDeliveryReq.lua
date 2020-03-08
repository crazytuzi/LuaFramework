local CJailDeliveryReq = class("CJailDeliveryReq")
CJailDeliveryReq.TYPEID = 12620034
function CJailDeliveryReq:ctor(roleId)
  self.id = 12620034
  self.roleId = roleId or nil
end
function CJailDeliveryReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CJailDeliveryReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CJailDeliveryReq:sizepolicy(size)
  return size <= 65535
end
return CJailDeliveryReq
