local CChangeOccWingPlanReq = class("CChangeOccWingPlanReq")
CChangeOccWingPlanReq.TYPEID = 12596548
function CChangeOccWingPlanReq:ctor(occupationId)
  self.id = 12596548
  self.occupationId = occupationId or nil
end
function CChangeOccWingPlanReq:marshal(os)
  os:marshalInt32(self.occupationId)
end
function CChangeOccWingPlanReq:unmarshal(os)
  self.occupationId = os:unmarshalInt32()
end
function CChangeOccWingPlanReq:sizepolicy(size)
  return size <= 65535
end
return CChangeOccWingPlanReq
