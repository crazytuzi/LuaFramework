local SGetRMBGiftBagActivityAwardSuccess = class("SGetRMBGiftBagActivityAwardSuccess")
SGetRMBGiftBagActivityAwardSuccess.TYPEID = 12588831
function SGetRMBGiftBagActivityAwardSuccess:ctor(activity_cfgid, tier)
  self.id = 12588831
  self.activity_cfgid = activity_cfgid or nil
  self.tier = tier or nil
end
function SGetRMBGiftBagActivityAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.tier)
end
function SGetRMBGiftBagActivityAwardSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.tier = os:unmarshalInt32()
end
function SGetRMBGiftBagActivityAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRMBGiftBagActivityAwardSuccess
