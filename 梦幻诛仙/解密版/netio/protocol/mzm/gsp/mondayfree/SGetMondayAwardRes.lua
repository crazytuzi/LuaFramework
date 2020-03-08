local SGetMondayAwardRes = class("SGetMondayAwardRes")
SGetMondayAwardRes.TYPEID = 12626180
function SGetMondayAwardRes:ctor()
  self.id = 12626180
end
function SGetMondayAwardRes:marshal(os)
end
function SGetMondayAwardRes:unmarshal(os)
end
function SGetMondayAwardRes:sizepolicy(size)
  return size <= 65535
end
return SGetMondayAwardRes
