local CGetFiveFightRewardReq = class("CGetFiveFightRewardReq")
CGetFiveFightRewardReq.TYPEID = 12595718
function CGetFiveFightRewardReq:ctor()
  self.id = 12595718
end
function CGetFiveFightRewardReq:marshal(os)
end
function CGetFiveFightRewardReq:unmarshal(os)
end
function CGetFiveFightRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetFiveFightRewardReq
