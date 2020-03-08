local SynActivityEnd = class("SynActivityEnd")
SynActivityEnd.TYPEID = 12587532
function SynActivityEnd:ctor(activityid)
  self.id = 12587532
  self.activityid = activityid or nil
end
function SynActivityEnd:marshal(os)
  os:marshalInt32(self.activityid)
end
function SynActivityEnd:unmarshal(os)
  self.activityid = os:unmarshalInt32()
end
function SynActivityEnd:sizepolicy(size)
  return size <= 65535
end
return SynActivityEnd
