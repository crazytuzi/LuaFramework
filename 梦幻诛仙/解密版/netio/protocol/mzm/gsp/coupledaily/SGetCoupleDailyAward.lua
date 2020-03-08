local SGetCoupleDailyAward = class("SGetCoupleDailyAward")
SGetCoupleDailyAward.TYPEID = 12602369
function SGetCoupleDailyAward:ctor()
  self.id = 12602369
end
function SGetCoupleDailyAward:marshal(os)
end
function SGetCoupleDailyAward:unmarshal(os)
end
function SGetCoupleDailyAward:sizepolicy(size)
  return size <= 65535
end
return SGetCoupleDailyAward
