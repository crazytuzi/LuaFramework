local CGetLoginSumSignAward = class("CGetLoginSumSignAward")
CGetLoginSumSignAward.TYPEID = 12604677
function CGetLoginSumSignAward:ctor(activityId, sortId)
  self.id = 12604677
  self.activityId = activityId or nil
  self.sortId = sortId or nil
end
function CGetLoginSumSignAward:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
end
function CGetLoginSumSignAward:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
end
function CGetLoginSumSignAward:sizepolicy(size)
  return size <= 65535
end
return CGetLoginSumSignAward
