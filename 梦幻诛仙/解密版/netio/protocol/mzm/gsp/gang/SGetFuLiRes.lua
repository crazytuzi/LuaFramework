local SGetFuLiRes = class("SGetFuLiRes")
SGetFuLiRes.TYPEID = 12589946
function SGetFuLiRes:ctor()
  self.id = 12589946
end
function SGetFuLiRes:marshal(os)
end
function SGetFuLiRes:unmarshal(os)
end
function SGetFuLiRes:sizepolicy(size)
  return size <= 65535
end
return SGetFuLiRes
