local SDismissAllBrd = class("SDismissAllBrd")
SDismissAllBrd.TYPEID = 12588325
function SDismissAllBrd:ctor()
  self.id = 12588325
end
function SDismissAllBrd:marshal(os)
end
function SDismissAllBrd:unmarshal(os)
end
function SDismissAllBrd:sizepolicy(size)
  return size <= 65535
end
return SDismissAllBrd
