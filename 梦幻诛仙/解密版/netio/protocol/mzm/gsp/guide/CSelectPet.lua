local CSelectPet = class("CSelectPet")
CSelectPet.TYPEID = 12594950
function CSelectPet:ctor(guideid, petid)
  self.id = 12594950
  self.guideid = guideid or nil
  self.petid = petid or nil
end
function CSelectPet:marshal(os)
  os:marshalInt32(self.guideid)
  os:marshalInt32(self.petid)
end
function CSelectPet:unmarshal(os)
  self.guideid = os:unmarshalInt32()
  self.petid = os:unmarshalInt32()
end
function CSelectPet:sizepolicy(size)
  return size <= 65535
end
return CSelectPet
