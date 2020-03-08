local CGetPetArenaInfo = class("CGetPetArenaInfo")
CGetPetArenaInfo.TYPEID = 12628237
function CGetPetArenaInfo:ctor()
  self.id = 12628237
end
function CGetPetArenaInfo:marshal(os)
end
function CGetPetArenaInfo:unmarshal(os)
end
function CGetPetArenaInfo:sizepolicy(size)
  return size <= 65535
end
return CGetPetArenaInfo
