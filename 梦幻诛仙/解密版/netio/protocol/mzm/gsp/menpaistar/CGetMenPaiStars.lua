local CGetMenPaiStars = class("CGetMenPaiStars")
CGetMenPaiStars.TYPEID = 12612384
function CGetMenPaiStars:ctor()
  self.id = 12612384
end
function CGetMenPaiStars:marshal(os)
end
function CGetMenPaiStars:unmarshal(os)
end
function CGetMenPaiStars:sizepolicy(size)
  return size <= 65535
end
return CGetMenPaiStars
