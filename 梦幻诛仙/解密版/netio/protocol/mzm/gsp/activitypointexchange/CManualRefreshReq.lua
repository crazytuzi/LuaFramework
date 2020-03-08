local CManualRefreshReq = class("CManualRefreshReq")
CManualRefreshReq.TYPEID = 12624897
function CManualRefreshReq:ctor(activityId, refreshCount, clientYuanBaoCount)
  self.id = 12624897
  self.activityId = activityId or nil
  self.refreshCount = refreshCount or nil
  self.clientYuanBaoCount = clientYuanBaoCount or nil
end
function CManualRefreshReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.refreshCount)
  os:marshalInt64(self.clientYuanBaoCount)
end
function CManualRefreshReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.refreshCount = os:unmarshalInt32()
  self.clientYuanBaoCount = os:unmarshalInt64()
end
function CManualRefreshReq:sizepolicy(size)
  return size <= 65535
end
return CManualRefreshReq
