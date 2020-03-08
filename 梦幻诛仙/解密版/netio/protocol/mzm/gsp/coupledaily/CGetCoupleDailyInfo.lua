local CGetCoupleDailyInfo = class("CGetCoupleDailyInfo")
CGetCoupleDailyInfo.TYPEID = 12602385
function CGetCoupleDailyInfo:ctor()
  self.id = 12602385
end
function CGetCoupleDailyInfo:marshal(os)
end
function CGetCoupleDailyInfo:unmarshal(os)
end
function CGetCoupleDailyInfo:sizepolicy(size)
  return size <= 65535
end
return CGetCoupleDailyInfo
