local CChildrenChangeOccupationReq = class("CChildrenChangeOccupationReq")
CChildrenChangeOccupationReq.TYPEID = 12609411
function CChildrenChangeOccupationReq:ctor(childrenid, occupation)
  self.id = 12609411
  self.childrenid = childrenid or nil
  self.occupation = occupation or nil
end
function CChildrenChangeOccupationReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.occupation)
end
function CChildrenChangeOccupationReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
end
function CChildrenChangeOccupationReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenChangeOccupationReq
