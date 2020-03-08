local CChallengeTeamInstanceReq = class("CChallengeTeamInstanceReq")
CChallengeTeamInstanceReq.TYPEID = 12591378
function CChallengeTeamInstanceReq:ctor(instanceCfgid)
  self.id = 12591378
  self.instanceCfgid = instanceCfgid or nil
end
function CChallengeTeamInstanceReq:marshal(os)
  os:marshalInt32(self.instanceCfgid)
end
function CChallengeTeamInstanceReq:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
end
function CChallengeTeamInstanceReq:sizepolicy(size)
  return size <= 65535
end
return CChallengeTeamInstanceReq
