local SynActivityStart = class("SynActivityStart")
SynActivityStart.TYPEID = 12587529
function SynActivityStart:ctor(activityid)
  self.id = 12587529
  self.activityid = activityid or nil
end
function SynActivityStart:marshal(os)
  os:marshalInt32(self.activityid)
end
function SynActivityStart:unmarshal(os)
  self.activityid = os:unmarshalInt32()
end
function SynActivityStart:sizepolicy(size)
  return size <= 65535
end
return SynActivityStart
