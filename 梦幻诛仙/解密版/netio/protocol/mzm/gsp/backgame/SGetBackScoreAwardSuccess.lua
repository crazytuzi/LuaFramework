local SGetBackScoreAwardSuccess = class("SGetBackScoreAwardSuccess")
SGetBackScoreAwardSuccess.TYPEID = 12604420
function SGetBackScoreAwardSuccess:ctor()
  self.id = 12604420
end
function SGetBackScoreAwardSuccess:marshal(os)
end
function SGetBackScoreAwardSuccess:unmarshal(os)
end
function SGetBackScoreAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBackScoreAwardSuccess
