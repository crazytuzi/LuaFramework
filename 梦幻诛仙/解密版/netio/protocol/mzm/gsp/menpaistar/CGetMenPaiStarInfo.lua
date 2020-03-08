local CGetMenPaiStarInfo = class("CGetMenPaiStarInfo")
CGetMenPaiStarInfo.TYPEID = 12612378
function CGetMenPaiStarInfo:ctor()
  self.id = 12612378
end
function CGetMenPaiStarInfo:marshal(os)
end
function CGetMenPaiStarInfo:unmarshal(os)
end
function CGetMenPaiStarInfo:sizepolicy(size)
  return size <= 65535
end
return CGetMenPaiStarInfo
