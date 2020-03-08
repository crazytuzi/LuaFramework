local CMenPaiLevelUpAutoReq = class("CMenPaiLevelUpAutoReq")
CMenPaiLevelUpAutoReq.TYPEID = 12591617
function CMenPaiLevelUpAutoReq:ctor()
  self.id = 12591617
end
function CMenPaiLevelUpAutoReq:marshal(os)
end
function CMenPaiLevelUpAutoReq:unmarshal(os)
end
function CMenPaiLevelUpAutoReq:sizepolicy(size)
  return size <= 65535
end
return CMenPaiLevelUpAutoReq
