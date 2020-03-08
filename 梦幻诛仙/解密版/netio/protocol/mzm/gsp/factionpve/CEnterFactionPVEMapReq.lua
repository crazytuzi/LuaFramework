local CEnterFactionPVEMapReq = class("CEnterFactionPVEMapReq")
CEnterFactionPVEMapReq.TYPEID = 12613635
function CEnterFactionPVEMapReq:ctor()
  self.id = 12613635
end
function CEnterFactionPVEMapReq:marshal(os)
end
function CEnterFactionPVEMapReq:unmarshal(os)
end
function CEnterFactionPVEMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterFactionPVEMapReq
