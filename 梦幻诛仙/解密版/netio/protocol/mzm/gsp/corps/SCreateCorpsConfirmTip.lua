local SCreateCorpsConfirmTip = class("SCreateCorpsConfirmTip")
SCreateCorpsConfirmTip.TYPEID = 12617500
function SCreateCorpsConfirmTip:ctor(creatorId, name, declaration, corpsBadgeId, sessionid)
  self.id = 12617500
  self.creatorId = creatorId or nil
  self.name = name or nil
  self.declaration = declaration or nil
  self.corpsBadgeId = corpsBadgeId or nil
  self.sessionid = sessionid or nil
end
function SCreateCorpsConfirmTip:marshal(os)
  os:marshalInt64(self.creatorId)
  os:marshalOctets(self.name)
  os:marshalOctets(self.declaration)
  os:marshalInt32(self.corpsBadgeId)
  os:marshalInt64(self.sessionid)
end
function SCreateCorpsConfirmTip:unmarshal(os)
  self.creatorId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.declaration = os:unmarshalOctets()
  self.corpsBadgeId = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function SCreateCorpsConfirmTip:sizepolicy(size)
  return size <= 65535
end
return SCreateCorpsConfirmTip
