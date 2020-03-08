local SJewelError = class("SJewelError")
SJewelError.TYPEID = 12618762
SJewelError.MATERIAL_NOT_ENOUGH = 1
SJewelError.LEVEL_NOT_MATCH = 2
SJewelError.BAG_ERROR = 5
SJewelError.ITEM_NOT_EXIST = 7
SJewelError.BAG_FULL = 8
SJewelError.MONEY_NOT_ENOUGH = 9
SJewelError.ITEM_NOT_ENOUGH = 10
SJewelError.MONEY_ENOUGH_NO_NEED_YUAN_BAO_MAKE_UP = 11
SJewelError.ADD_COMPOSED_JEWEL_FAIL = 12
function SJewelError:ctor(errorCode)
  self.id = 12618762
  self.errorCode = errorCode or nil
end
function SJewelError:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SJewelError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SJewelError:sizepolicy(size)
  return size <= 65535
end
return SJewelError
