local SLoginQueueInfo = class("SLoginQueueInfo")
SLoginQueueInfo.TYPEID = 12590084
function SLoginQueueInfo:ctor(waitNum, offlineNum, totalNum)
  self.id = 12590084
  self.waitNum = waitNum or nil
  self.offlineNum = offlineNum or nil
  self.totalNum = totalNum or nil
end
function SLoginQueueInfo:marshal(os)
  os:marshalInt32(self.waitNum)
  os:marshalInt32(self.offlineNum)
  os:marshalInt32(self.totalNum)
end
function SLoginQueueInfo:unmarshal(os)
  self.waitNum = os:unmarshalInt32()
  self.offlineNum = os:unmarshalInt32()
  self.totalNum = os:unmarshalInt32()
end
function SLoginQueueInfo:sizepolicy(size)
  return size <= 10240
end
return SLoginQueueInfo
