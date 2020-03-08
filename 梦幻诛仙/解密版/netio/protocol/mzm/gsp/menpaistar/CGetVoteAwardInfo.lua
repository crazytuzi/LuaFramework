local CGetVoteAwardInfo = class("CGetVoteAwardInfo")
CGetVoteAwardInfo.TYPEID = 12612380
function CGetVoteAwardInfo:ctor()
  self.id = 12612380
end
function CGetVoteAwardInfo:marshal(os)
end
function CGetVoteAwardInfo:unmarshal(os)
end
function CGetVoteAwardInfo:sizepolicy(size)
  return size <= 65535
end
return CGetVoteAwardInfo
