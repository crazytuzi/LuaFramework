local SSynDrawAndGuessNoReward = class("SSynDrawAndGuessNoReward")
SSynDrawAndGuessNoReward.TYPEID = 12617258
function SSynDrawAndGuessNoReward:ctor()
  self.id = 12617258
end
function SSynDrawAndGuessNoReward:marshal(os)
end
function SSynDrawAndGuessNoReward:unmarshal(os)
end
function SSynDrawAndGuessNoReward:sizepolicy(size)
  return size <= 65535
end
return SSynDrawAndGuessNoReward
