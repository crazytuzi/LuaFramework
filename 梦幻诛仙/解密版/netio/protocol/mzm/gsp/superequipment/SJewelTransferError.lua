local SJewelTransferError = class("SJewelTransferError")
SJewelTransferError.TYPEID = 12618781
SJewelTransferError.TRANSFER_COUNT_ERROR = 1
SJewelTransferError.JEWEL_LEVEL_ERROR = 2
SJewelTransferError.GOLD_TO_MAX = 3
SJewelTransferError.GOLD_NOT_ENOUGH = 4
function SJewelTransferError:ctor(errorCode)
  self.id = 12618781
  self.errorCode = errorCode or nil
end
function SJewelTransferError:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SJewelTransferError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SJewelTransferError:sizepolicy(size)
  return size <= 65535
end
return SJewelTransferError
