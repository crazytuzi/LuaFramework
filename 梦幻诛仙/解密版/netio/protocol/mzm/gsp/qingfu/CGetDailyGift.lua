local CGetDailyGift = class("CGetDailyGift")
CGetDailyGift.TYPEID = 12588834
function CGetDailyGift:ctor()
  self.id = 12588834
end
function CGetDailyGift:marshal(os)
end
function CGetDailyGift:unmarshal(os)
end
function CGetDailyGift:sizepolicy(size)
  return size <= 65535
end
return CGetDailyGift
