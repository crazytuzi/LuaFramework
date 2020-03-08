local SGetAwardRes = class("SGetAwardRes")
SGetAwardRes.TYPEID = 12627461
function SGetAwardRes:ctor(activityid, left_times)
  self.id = 12627461
  self.activityid = activityid or nil
  self.left_times = left_times or nil
end
function SGetAwardRes:marshal(os)
  os:marshalInt32(self.activityid)
  os:marshalInt32(self.left_times)
end
function SGetAwardRes:unmarshal(os)
  self.activityid = os:unmarshalInt32()
  self.left_times = os:unmarshalInt32()
end
function SGetAwardRes:sizepolicy(size)
  return size <= 65535
end
return SGetAwardRes
