local CGetRedgiftActivityRewardReq = class("CGetRedgiftActivityRewardReq")
CGetRedgiftActivityRewardReq.TYPEID = 12587590
function CGetRedgiftActivityRewardReq:ctor()
  self.id = 12587590
end
function CGetRedgiftActivityRewardReq:marshal(os)
end
function CGetRedgiftActivityRewardReq:unmarshal(os)
end
function CGetRedgiftActivityRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetRedgiftActivityRewardReq
