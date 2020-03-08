local SRmGangHelpCache = class("SRmGangHelpCache")
SRmGangHelpCache.TYPEID = 12584468
function SRmGangHelpCache:ctor()
  self.id = 12584468
end
function SRmGangHelpCache:marshal(os)
end
function SRmGangHelpCache:unmarshal(os)
end
function SRmGangHelpCache:sizepolicy(size)
  return size <= 65535
end
return SRmGangHelpCache
