local SGetLoginAwardSuccess = class("SGetLoginAwardSuccess")
SGetLoginAwardSuccess.TYPEID = 12604676
function SGetLoginAwardSuccess:ctor(activityId, sortId)
  self.id = 12604676
  self.activityId = activityId or nil
  self.sortId = sortId or nil
end
function SGetLoginAwardSuccess:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
end
function SGetLoginAwardSuccess:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
end
function SGetLoginAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetLoginAwardSuccess
