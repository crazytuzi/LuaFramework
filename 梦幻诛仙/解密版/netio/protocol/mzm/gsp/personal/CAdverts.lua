local CAdverts = class("CAdverts")
CAdverts.TYPEID = 12603658
function CAdverts:ctor()
  self.id = 12603658
end
function CAdverts:marshal(os)
end
function CAdverts:unmarshal(os)
end
function CAdverts:sizepolicy(size)
  return size <= 65535
end
return CAdverts
