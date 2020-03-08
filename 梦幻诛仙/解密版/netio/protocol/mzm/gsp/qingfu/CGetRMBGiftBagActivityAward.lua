local CGetRMBGiftBagActivityAward = class("CGetRMBGiftBagActivityAward")
CGetRMBGiftBagActivityAward.TYPEID = 12588833
function CGetRMBGiftBagActivityAward:ctor(activity_cfgid, tier)
  self.id = 12588833
  self.activity_cfgid = activity_cfgid or nil
  self.tier = tier or nil
end
function CGetRMBGiftBagActivityAward:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.tier)
end
function CGetRMBGiftBagActivityAward:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.tier = os:unmarshalInt32()
end
function CGetRMBGiftBagActivityAward:sizepolicy(size)
  return size <= 65535
end
return CGetRMBGiftBagActivityAward
