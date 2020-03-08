local SGrcReceiveGiftResp = class("SGrcReceiveGiftResp")
SGrcReceiveGiftResp.TYPEID = 12600324
function SGrcReceiveGiftResp:ctor(retcode, gift_type, serialid)
  self.id = 12600324
  self.retcode = retcode or nil
  self.gift_type = gift_type or nil
  self.serialid = serialid or nil
end
function SGrcReceiveGiftResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.gift_type)
  os:marshalInt64(self.serialid)
end
function SGrcReceiveGiftResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.gift_type = os:unmarshalInt32()
  self.serialid = os:unmarshalInt64()
end
function SGrcReceiveGiftResp:sizepolicy(size)
  return size <= 65535
end
return SGrcReceiveGiftResp
