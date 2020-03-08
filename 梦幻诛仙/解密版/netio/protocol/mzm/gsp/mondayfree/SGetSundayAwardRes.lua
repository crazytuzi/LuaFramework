local SGetSundayAwardRes = class("SGetSundayAwardRes")
SGetSundayAwardRes.TYPEID = 12626177
function SGetSundayAwardRes:ctor()
  self.id = 12626177
end
function SGetSundayAwardRes:marshal(os)
end
function SGetSundayAwardRes:unmarshal(os)
end
function SGetSundayAwardRes:sizepolicy(size)
  return size <= 65535
end
return SGetSundayAwardRes
