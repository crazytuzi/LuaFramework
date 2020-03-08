local SChildrenSelectOccupationRes = class("SChildrenSelectOccupationRes")
SChildrenSelectOccupationRes.TYPEID = 12609371
function SChildrenSelectOccupationRes:ctor(childrenid, occupation)
  self.id = 12609371
  self.childrenid = childrenid or nil
  self.occupation = occupation or nil
end
function SChildrenSelectOccupationRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.occupation)
end
function SChildrenSelectOccupationRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
end
function SChildrenSelectOccupationRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenSelectOccupationRes
