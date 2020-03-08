local SEnablePKFail = class("SEnablePKFail")
SEnablePKFail.TYPEID = 12619790
SEnablePKFail.LEVEL_TOO_LOW = 1
SEnablePKFail.MORAL_VALUE_TOO_LOW = 2
SEnablePKFail.INSUFFICIENT_MONEY = 3
SEnablePKFail.MONEY_NUM_NOT_MATCHED = 4
function SEnablePKFail:ctor(retcode)
  self.id = 12619790
  self.retcode = retcode or nil
end
function SEnablePKFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SEnablePKFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SEnablePKFail:sizepolicy(size)
  return size <= 65535
end
return SEnablePKFail
