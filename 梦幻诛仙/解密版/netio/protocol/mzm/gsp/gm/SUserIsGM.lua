local SUserIsGM = class("SUserIsGM")
SUserIsGM.TYPEID = 12585732
function SUserIsGM:ctor()
  self.id = 12585732
end
function SUserIsGM:marshal(os)
end
function SUserIsGM:unmarshal(os)
end
function SUserIsGM:sizepolicy(size)
  return size <= 65535
end
return SUserIsGM
