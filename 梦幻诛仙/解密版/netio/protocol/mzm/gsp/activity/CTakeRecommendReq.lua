local CTakeRecommendReq = class("CTakeRecommendReq")
CTakeRecommendReq.TYPEID = 12587530
function CTakeRecommendReq:ctor(activityId)
  self.id = 12587530
  self.activityId = activityId or nil
end
function CTakeRecommendReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CTakeRecommendReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CTakeRecommendReq:sizepolicy(size)
  return size <= 65535
end
return CTakeRecommendReq
