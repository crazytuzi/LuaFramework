local SJailDeliveryConfirmDesc = class("SJailDeliveryConfirmDesc")
SJailDeliveryConfirmDesc.TYPEID = 12620043
function SJailDeliveryConfirmDesc:ctor(name)
  self.id = 12620043
  self.name = name or nil
end
function SJailDeliveryConfirmDesc:marshal(os)
  os:marshalOctets(self.name)
end
function SJailDeliveryConfirmDesc:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SJailDeliveryConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SJailDeliveryConfirmDesc
