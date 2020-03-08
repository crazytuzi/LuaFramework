local CRenameCropsReq = class("CRenameCropsReq")
CRenameCropsReq.TYPEID = 12617487
function CRenameCropsReq:ctor(name)
  self.id = 12617487
  self.name = name or nil
end
function CRenameCropsReq:marshal(os)
  os:marshalOctets(self.name)
end
function CRenameCropsReq:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function CRenameCropsReq:sizepolicy(size)
  return size <= 65535
end
return CRenameCropsReq
