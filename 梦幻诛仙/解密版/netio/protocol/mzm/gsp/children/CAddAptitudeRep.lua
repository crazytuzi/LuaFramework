local CAddAptitudeRep = class("CAddAptitudeRep")
CAddAptitudeRep.TYPEID = 12609373
function CAddAptitudeRep:ctor(childrenid, aptType, itemId)
  self.id = 12609373
  self.childrenid = childrenid or nil
  self.aptType = aptType or nil
  self.itemId = itemId or nil
end
function CAddAptitudeRep:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.aptType)
  os:marshalInt32(self.itemId)
end
function CAddAptitudeRep:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.aptType = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
end
function CAddAptitudeRep:sizepolicy(size)
  return size <= 65535
end
return CAddAptitudeRep
