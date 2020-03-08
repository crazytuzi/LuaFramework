local SStartWatchmoonSuccessRes = class("SStartWatchmoonSuccessRes")
SStartWatchmoonSuccessRes.TYPEID = 12600840
function SStartWatchmoonSuccessRes:ctor()
  self.id = 12600840
end
function SStartWatchmoonSuccessRes:marshal(os)
end
function SStartWatchmoonSuccessRes:unmarshal(os)
end
function SStartWatchmoonSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SStartWatchmoonSuccessRes
