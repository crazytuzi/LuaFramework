local CGetOnlineBoxRewardReq = class("CGetOnlineBoxRewardReq")
CGetOnlineBoxRewardReq.TYPEID = 12587600
function CGetOnlineBoxRewardReq:ctor()
  self.id = 12587600
end
function CGetOnlineBoxRewardReq:marshal(os)
end
function CGetOnlineBoxRewardReq:unmarshal(os)
end
function CGetOnlineBoxRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetOnlineBoxRewardReq
