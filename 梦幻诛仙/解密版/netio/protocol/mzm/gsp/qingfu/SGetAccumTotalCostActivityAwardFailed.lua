local SGetAccumTotalCostActivityAwardFailed = class("SGetAccumTotalCostActivityAwardFailed")
SGetAccumTotalCostActivityAwardFailed.TYPEID = 12588821
SGetAccumTotalCostActivityAwardFailed.ERROR_ACTVITY_NOT_OPEN = -1
SGetAccumTotalCostActivityAwardFailed.ERROR_ACCUM_TOTAL_COST_NOT_MEET = -2
SGetAccumTotalCostActivityAwardFailed.ERROR_ALREADY_GET_AWARD = -3
function SGetAccumTotalCostActivityAwardFailed:ctor(activity_cfgid, sortid, retcode)
  self.id = 12588821
  self.activity_cfgid = activity_cfgid or nil
  self.sortid = sortid or nil
  self.retcode = retcode or nil
end
function SGetAccumTotalCostActivityAwardFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.retcode)
end
function SGetAccumTotalCostActivityAwardFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetAccumTotalCostActivityAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetAccumTotalCostActivityAwardFailed
