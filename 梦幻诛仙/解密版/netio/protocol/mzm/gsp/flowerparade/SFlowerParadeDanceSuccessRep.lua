local SFlowerParadeDanceSuccessRep = class("SFlowerParadeDanceSuccessRep")
SFlowerParadeDanceSuccessRep.TYPEID = 12625671
function SFlowerParadeDanceSuccessRep:ctor(activityId, doneTime, maxTime)
  self.id = 12625671
  self.activityId = activityId or nil
  self.doneTime = doneTime or nil
  self.maxTime = maxTime or nil
end
function SFlowerParadeDanceSuccessRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.doneTime)
  os:marshalInt32(self.maxTime)
end
function SFlowerParadeDanceSuccessRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.doneTime = os:unmarshalInt32()
  self.maxTime = os:unmarshalInt32()
end
function SFlowerParadeDanceSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeDanceSuccessRep
