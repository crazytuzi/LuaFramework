local CFlowerParadeJoinReq = class("CFlowerParadeJoinReq")
CFlowerParadeJoinReq.TYPEID = 12625676
function CFlowerParadeJoinReq:ctor(activityId)
  self.id = 12625676
  self.activityId = activityId or nil
end
function CFlowerParadeJoinReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CFlowerParadeJoinReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CFlowerParadeJoinReq:sizepolicy(size)
  return size <= 65535
end
return CFlowerParadeJoinReq
