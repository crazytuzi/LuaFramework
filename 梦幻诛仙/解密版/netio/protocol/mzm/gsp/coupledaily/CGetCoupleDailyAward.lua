local CGetCoupleDailyAward = class("CGetCoupleDailyAward")
CGetCoupleDailyAward.TYPEID = 12602375
function CGetCoupleDailyAward:ctor()
  self.id = 12602375
end
function CGetCoupleDailyAward:marshal(os)
end
function CGetCoupleDailyAward:unmarshal(os)
end
function CGetCoupleDailyAward:sizepolicy(size)
  return size <= 65535
end
return CGetCoupleDailyAward
