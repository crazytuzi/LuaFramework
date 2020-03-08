local CGetGiftAwardReq = class("CGetGiftAwardReq")
CGetGiftAwardReq.TYPEID = 12583445
function CGetGiftAwardReq:ctor(giftAwardCfgId)
  self.id = 12583445
  self.giftAwardCfgId = giftAwardCfgId or nil
end
function CGetGiftAwardReq:marshal(os)
  os:marshalInt32(self.giftAwardCfgId)
end
function CGetGiftAwardReq:unmarshal(os)
  self.giftAwardCfgId = os:unmarshalInt32()
end
function CGetGiftAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetGiftAwardReq
