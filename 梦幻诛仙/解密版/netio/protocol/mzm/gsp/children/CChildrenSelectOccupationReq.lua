local CChildrenSelectOccupationReq = class("CChildrenSelectOccupationReq")
CChildrenSelectOccupationReq.TYPEID = 12609370
function CChildrenSelectOccupationReq:ctor(childrenid, occupation)
  self.id = 12609370
  self.childrenid = childrenid or nil
  self.occupation = occupation or nil
end
function CChildrenSelectOccupationReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.occupation)
end
function CChildrenSelectOccupationReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
end
function CChildrenSelectOccupationReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenSelectOccupationReq
