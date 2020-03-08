local CConstellationReq = class("CConstellationReq")
CConstellationReq.TYPEID = 12612106
function CConstellationReq:ctor()
  self.id = 12612106
end
function CConstellationReq:marshal(os)
end
function CConstellationReq:unmarshal(os)
end
function CConstellationReq:sizepolicy(size)
  return size <= 65535
end
return CConstellationReq
