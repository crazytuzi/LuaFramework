local SWuShiError = class("SWuShiError")
SWuShiError.TYPEID = 12618773
SWuShiError.CFG_NOT_EXIST = 1
SWuShiError.WUSHI_NOT_EXIST = 2
SWuShiError.ITEM_NOT_EXIST = 3
SWuShiError.CROSS_NOT_SUPPORTED = 4
SWuShiError.WEAPON_ERROR = 5
SWuShiError.ITEM_ERROR = 6
SWuShiError.MAX_LEVEL = 7
function SWuShiError:ctor(errorCode)
  self.id = 12618773
  self.errorCode = errorCode or nil
end
function SWuShiError:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SWuShiError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SWuShiError:sizepolicy(size)
  return size <= 65535
end
return SWuShiError
