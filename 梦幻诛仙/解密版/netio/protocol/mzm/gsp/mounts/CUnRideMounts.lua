local CUnRideMounts = class("CUnRideMounts")
CUnRideMounts.TYPEID = 12606234
function CUnRideMounts:ctor()
  self.id = 12606234
end
function CUnRideMounts:marshal(os)
end
function CUnRideMounts:unmarshal(os)
end
function CUnRideMounts:sizepolicy(size)
  return size <= 65535
end
return CUnRideMounts
