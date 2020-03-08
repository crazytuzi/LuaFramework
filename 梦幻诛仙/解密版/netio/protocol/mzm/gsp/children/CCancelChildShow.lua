local CCancelChildShow = class("CCancelChildShow")
CCancelChildShow.TYPEID = 12609324
function CCancelChildShow:ctor()
  self.id = 12609324
end
function CCancelChildShow:marshal(os)
end
function CCancelChildShow:unmarshal(os)
end
function CCancelChildShow:sizepolicy(size)
  return size <= 65535
end
return CCancelChildShow
