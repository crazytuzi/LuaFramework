local SGrcSendGiftResp = class("SGrcSendGiftResp")
SGrcSendGiftResp.TYPEID = 12600334
function SGrcSendGiftResp:ctor(retcode, gift_type, to)
  self.id = 12600334
  self.retcode = retcode or nil
  self.gift_type = gift_type or nil
  self.to = to or nil
end
function SGrcSendGiftResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.gift_type)
  os:marshalOctets(self.to)
end
function SGrcSendGiftResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.gift_type = os:unmarshalInt32()
  self.to = os:unmarshalOctets()
end
function SGrcSendGiftResp:sizepolicy(size)
  return size <= 65535
end
return SGrcSendGiftResp
