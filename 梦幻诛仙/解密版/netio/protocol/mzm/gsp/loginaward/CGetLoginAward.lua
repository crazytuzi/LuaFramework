local CGetLoginAward = class("CGetLoginAward")
CGetLoginAward.TYPEID = 12604674
function CGetLoginAward:ctor(activityId, sortId)
  self.id = 12604674
  self.activityId = activityId or nil
  self.sortId = sortId or nil
end
function CGetLoginAward:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
end
function CGetLoginAward:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
end
function CGetLoginAward:sizepolicy(size)
  return size <= 65535
end
return CGetLoginAward
