local SFloorConfirmDesc = class("SFloorConfirmDesc")
SFloorConfirmDesc.TYPEID = 12617748
function SFloorConfirmDesc:ctor(activityId, floor)
  self.id = 12617748
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function SFloorConfirmDesc:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function SFloorConfirmDesc:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function SFloorConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SFloorConfirmDesc
