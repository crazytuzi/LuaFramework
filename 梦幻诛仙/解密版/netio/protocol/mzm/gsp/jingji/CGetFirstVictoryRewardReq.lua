local CGetFirstVictoryRewardReq = class("CGetFirstVictoryRewardReq")
CGetFirstVictoryRewardReq.TYPEID = 12595715
function CGetFirstVictoryRewardReq:ctor()
  self.id = 12595715
end
function CGetFirstVictoryRewardReq:marshal(os)
end
function CGetFirstVictoryRewardReq:unmarshal(os)
end
function CGetFirstVictoryRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetFirstVictoryRewardReq
