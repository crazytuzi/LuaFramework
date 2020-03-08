local CChangePartner = class("CChangePartner")
CChangePartner.TYPEID = 12605717
function CChangePartner:ctor()
  self.id = 12605717
end
function CChangePartner:marshal(os)
end
function CChangePartner:unmarshal(os)
end
function CChangePartner:sizepolicy(size)
  return size <= 65535
end
return CChangePartner
