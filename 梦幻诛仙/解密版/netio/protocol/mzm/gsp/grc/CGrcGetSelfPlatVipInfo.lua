local CGrcGetSelfPlatVipInfo = class("CGrcGetSelfPlatVipInfo")
CGrcGetSelfPlatVipInfo.TYPEID = 12600326
function CGrcGetSelfPlatVipInfo:ctor()
  self.id = 12600326
end
function CGrcGetSelfPlatVipInfo:marshal(os)
end
function CGrcGetSelfPlatVipInfo:unmarshal(os)
end
function CGrcGetSelfPlatVipInfo:sizepolicy(size)
  return size <= 65535
end
return CGrcGetSelfPlatVipInfo
