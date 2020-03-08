local CGetBackScoreAwardInfo = class("CGetBackScoreAwardInfo")
CGetBackScoreAwardInfo.TYPEID = 12604424
function CGetBackScoreAwardInfo:ctor()
  self.id = 12604424
end
function CGetBackScoreAwardInfo:marshal(os)
end
function CGetBackScoreAwardInfo:unmarshal(os)
end
function CGetBackScoreAwardInfo:sizepolicy(size)
  return size <= 65535
end
return CGetBackScoreAwardInfo
