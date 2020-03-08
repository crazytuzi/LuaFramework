local SSendCardFail = class("SSendCardFail")
SSendCardFail.TYPEID = 12616451
SSendCardFail.WRONG_TYPE = 1
SSendCardFail.NOT_EXISTS = 2
SSendCardFail.WRONG_CHANNEL = 3
SSendCardFail.NOT_IN_GANG = 4
function SSendCardFail:ctor(retcode, item_key)
  self.id = 12616451
  self.retcode = retcode or nil
  self.item_key = item_key or nil
end
function SSendCardFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.item_key)
end
function SSendCardFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.item_key = os:unmarshalInt32()
end
function SSendCardFail:sizepolicy(size)
  return size <= 65535
end
return SSendCardFail
