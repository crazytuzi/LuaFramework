local CJoinScoChallengeReq = class("CJoinScoChallengeReq")
CJoinScoChallengeReq.TYPEID = 12587521
function CJoinScoChallengeReq:ctor()
  self.id = 12587521
end
function CJoinScoChallengeReq:marshal(os)
end
function CJoinScoChallengeReq:unmarshal(os)
end
function CJoinScoChallengeReq:sizepolicy(size)
  return size <= 65535
end
return CJoinScoChallengeReq
