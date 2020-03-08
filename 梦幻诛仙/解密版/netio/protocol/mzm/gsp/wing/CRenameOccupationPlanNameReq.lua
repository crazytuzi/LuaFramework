local CRenameOccupationPlanNameReq = class("CRenameOccupationPlanNameReq")
CRenameOccupationPlanNameReq.TYPEID = 12596550
function CRenameOccupationPlanNameReq:ctor(occupationId, newName)
  self.id = 12596550
  self.occupationId = occupationId or nil
  self.newName = newName or nil
end
function CRenameOccupationPlanNameReq:marshal(os)
  os:marshalInt32(self.occupationId)
  os:marshalOctets(self.newName)
end
function CRenameOccupationPlanNameReq:unmarshal(os)
  self.occupationId = os:unmarshalInt32()
  self.newName = os:unmarshalOctets()
end
function CRenameOccupationPlanNameReq:sizepolicy(size)
  return size <= 65535
end
return CRenameOccupationPlanNameReq
