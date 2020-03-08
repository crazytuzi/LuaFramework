local SCancelInvite = class("SCancelInvite")
SCancelInvite.TYPEID = 12592148
function SCancelInvite:ctor()
  self.id = 12592148
end
function SCancelInvite:marshal(os)
end
function SCancelInvite:unmarshal(os)
end
function SCancelInvite:sizepolicy(size)
  return size <= 65535
end
return SCancelInvite
