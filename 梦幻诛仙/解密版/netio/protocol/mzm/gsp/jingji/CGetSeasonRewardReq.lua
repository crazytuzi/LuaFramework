local CGetSeasonRewardReq = class("CGetSeasonRewardReq")
CGetSeasonRewardReq.TYPEID = 12595719
function CGetSeasonRewardReq:ctor()
  self.id = 12595719
end
function CGetSeasonRewardReq:marshal(os)
end
function CGetSeasonRewardReq:unmarshal(os)
end
function CGetSeasonRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetSeasonRewardReq
