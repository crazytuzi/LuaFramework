local SJailDeliveryError = class("SJailDeliveryError")
SJailDeliveryError.TYPEID = 12620038
function SJailDeliveryError:ctor(errorCode, savedName)
  self.id = 12620038
  self.errorCode = errorCode or nil
  self.savedName = savedName or nil
end
function SJailDeliveryError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalOctets(self.savedName)
end
function SJailDeliveryError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.savedName = os:unmarshalOctets()
end
function SJailDeliveryError:sizepolicy(size)
  return size <= 65535
end
return SJailDeliveryError
