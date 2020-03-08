local SRenewalFashionError = class("SRenewalFashionError")
SRenewalFashionError.TYPEID = 12609435
SRenewalFashionError.ITEM_NOT_EXIST = 1
SRenewalFashionError.FASHION_NOT_EXIST = 2
SRenewalFashionError.TYPE_NOT_MATCH = 3
SRenewalFashionError.NEVER_EXPIRE = 4
function SRenewalFashionError:ctor(errorCode, fashionCfgId)
  self.id = 12609435
  self.errorCode = errorCode or nil
  self.fashionCfgId = fashionCfgId or nil
end
function SRenewalFashionError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.fashionCfgId)
end
function SRenewalFashionError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.fashionCfgId = os:unmarshalInt32()
end
function SRenewalFashionError:sizepolicy(size)
  return size <= 65535
end
return SRenewalFashionError
