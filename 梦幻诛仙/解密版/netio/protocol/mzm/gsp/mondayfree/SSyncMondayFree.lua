local SSyncMondayFree = class("SSyncMondayFree")
SSyncMondayFree.TYPEID = 12626184
function SSyncMondayFree:ctor(sunday_award_time, monday_award_time, finish_shimen_time, finish_baotu_time)
  self.id = 12626184
  self.sunday_award_time = sunday_award_time or nil
  self.monday_award_time = monday_award_time or nil
  self.finish_shimen_time = finish_shimen_time or nil
  self.finish_baotu_time = finish_baotu_time or nil
end
function SSyncMondayFree:marshal(os)
  os:marshalInt64(self.sunday_award_time)
  os:marshalInt64(self.monday_award_time)
  os:marshalInt64(self.finish_shimen_time)
  os:marshalInt64(self.finish_baotu_time)
end
function SSyncMondayFree:unmarshal(os)
  self.sunday_award_time = os:unmarshalInt64()
  self.monday_award_time = os:unmarshalInt64()
  self.finish_shimen_time = os:unmarshalInt64()
  self.finish_baotu_time = os:unmarshalInt64()
end
function SSyncMondayFree:sizepolicy(size)
  return size <= 65535
end
return SSyncMondayFree
