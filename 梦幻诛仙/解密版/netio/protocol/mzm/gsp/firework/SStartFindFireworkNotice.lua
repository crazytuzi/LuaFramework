local SStartFindFireworkNotice = class("SStartFindFireworkNotice")
SStartFindFireworkNotice.TYPEID = 12625155
function SStartFindFireworkNotice:ctor(activityId)
  self.id = 12625155
  self.activityId = activityId or nil
end
function SStartFindFireworkNotice:marshal(os)
  os:marshalInt32(self.activityId)
end
function SStartFindFireworkNotice:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function SStartFindFireworkNotice:sizepolicy(size)
  return size <= 65535
end
return SStartFindFireworkNotice
