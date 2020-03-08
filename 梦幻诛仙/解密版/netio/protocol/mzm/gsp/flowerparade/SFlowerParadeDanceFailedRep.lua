local SFlowerParadeDanceFailedRep = class("SFlowerParadeDanceFailedRep")
SFlowerParadeDanceFailedRep.TYPEID = 12625666
SFlowerParadeDanceFailedRep.MAX_COUNT = 1
SFlowerParadeDanceFailedRep.ACTION_WRONG = 2
SFlowerParadeDanceFailedRep.FAR_AWARY = 3
SFlowerParadeDanceFailedRep.POS_ALREADY_TAKEN = 4
SFlowerParadeDanceFailedRep.ROLE_LEVEL_ERROR = 5
function SFlowerParadeDanceFailedRep:ctor(activityId, code)
  self.id = 12625666
  self.activityId = activityId or nil
  self.code = code or nil
end
function SFlowerParadeDanceFailedRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.code)
end
function SFlowerParadeDanceFailedRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.code = os:unmarshalInt32()
end
function SFlowerParadeDanceFailedRep:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeDanceFailedRep
