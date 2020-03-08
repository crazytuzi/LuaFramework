local CGetBackScoreAward = class("CGetBackScoreAward")
CGetBackScoreAward.TYPEID = 12604417
function CGetBackScoreAward:ctor()
  self.id = 12604417
end
function CGetBackScoreAward:marshal(os)
end
function CGetBackScoreAward:unmarshal(os)
end
function CGetBackScoreAward:sizepolicy(size)
  return size <= 65535
end
return CGetBackScoreAward
