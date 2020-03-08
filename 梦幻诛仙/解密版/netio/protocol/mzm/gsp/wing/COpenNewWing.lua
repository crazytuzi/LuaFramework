local COpenNewWing = class("COpenNewWing")
COpenNewWing.TYPEID = 12596491
function COpenNewWing:ctor()
  self.id = 12596491
end
function COpenNewWing:marshal(os)
end
function COpenNewWing:unmarshal(os)
end
function COpenNewWing:sizepolicy(size)
  return size <= 65535
end
return COpenNewWing
