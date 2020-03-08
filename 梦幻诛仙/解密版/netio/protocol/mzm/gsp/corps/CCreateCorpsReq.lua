local CCreateCorpsReq = class("CCreateCorpsReq")
CCreateCorpsReq.TYPEID = 12617480
function CCreateCorpsReq:ctor(name, declaration, corpsBadgeId)
  self.id = 12617480
  self.name = name or nil
  self.declaration = declaration or nil
  self.corpsBadgeId = corpsBadgeId or nil
end
function CCreateCorpsReq:marshal(os)
  os:marshalOctets(self.name)
  os:marshalOctets(self.declaration)
  os:marshalInt32(self.corpsBadgeId)
end
function CCreateCorpsReq:unmarshal(os)
  self.name = os:unmarshalOctets()
  self.declaration = os:unmarshalOctets()
  self.corpsBadgeId = os:unmarshalInt32()
end
function CCreateCorpsReq:sizepolicy(size)
  return size <= 65535
end
return CCreateCorpsReq
