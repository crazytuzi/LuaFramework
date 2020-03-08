local SChallengeSuc = class("SChallengeSuc")
SChallengeSuc.TYPEID = 12617739
function SChallengeSuc:ctor(activityId, floor, usedTime)
  self.id = 12617739
  self.activityId = activityId or nil
  self.floor = floor or nil
  self.usedTime = usedTime or nil
end
function SChallengeSuc:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
  os:marshalInt32(self.usedTime)
end
function SChallengeSuc:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
  self.usedTime = os:unmarshalInt32()
end
function SChallengeSuc:sizepolicy(size)
  return size <= 65535
end
return SChallengeSuc
