local CMultiOccupationReq = class("CMultiOccupationReq")
CMultiOccupationReq.TYPEID = 12606984
function CMultiOccupationReq:ctor()
  self.id = 12606984
end
function CMultiOccupationReq:marshal(os)
end
function CMultiOccupationReq:unmarshal(os)
end
function CMultiOccupationReq:sizepolicy(size)
  return size <= 65535
end
return CMultiOccupationReq
