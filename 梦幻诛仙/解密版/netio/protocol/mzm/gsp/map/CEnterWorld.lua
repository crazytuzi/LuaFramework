local CEnterWorld = class("CEnterWorld")
CEnterWorld.TYPEID = 12590869
function CEnterWorld:ctor()
  self.id = 12590869
end
function CEnterWorld:marshal(os)
end
function CEnterWorld:unmarshal(os)
end
function CEnterWorld:sizepolicy(size)
  return size <= 32
end
return CEnterWorld
