local SAutoOperateNotify = class("SAutoOperateNotify")
SAutoOperateNotify.TYPEID = 12594192
function SAutoOperateNotify:ctor()
  self.id = 12594192
end
function SAutoOperateNotify:marshal(os)
end
function SAutoOperateNotify:unmarshal(os)
end
function SAutoOperateNotify:sizepolicy(size)
  return size <= 65535
end
return SAutoOperateNotify
