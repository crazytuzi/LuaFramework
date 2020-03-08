local CManualRefreshCountInfoReq = class("CManualRefreshCountInfoReq")
CManualRefreshCountInfoReq.TYPEID = 12624899
function CManualRefreshCountInfoReq:ctor(activityId)
  self.id = 12624899
  self.activityId = activityId or nil
end
function CManualRefreshCountInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CManualRefreshCountInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CManualRefreshCountInfoReq:sizepolicy(size)
  return size <= 65535
end
return CManualRefreshCountInfoReq
