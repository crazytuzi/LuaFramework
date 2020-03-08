local CGetAccumTotalCostActivityAward = class("CGetAccumTotalCostActivityAward")
CGetAccumTotalCostActivityAward.TYPEID = 12588823
function CGetAccumTotalCostActivityAward:ctor(activity_cfgid, sortid)
  self.id = 12588823
  self.activity_cfgid = activity_cfgid or nil
  self.sortid = sortid or nil
end
function CGetAccumTotalCostActivityAward:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sortid)
end
function CGetAccumTotalCostActivityAward:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CGetAccumTotalCostActivityAward:sizepolicy(size)
  return size <= 65535
end
return CGetAccumTotalCostActivityAward
