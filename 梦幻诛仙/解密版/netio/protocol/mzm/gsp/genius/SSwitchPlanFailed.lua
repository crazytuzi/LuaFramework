local SSwitchPlanFailed = class("SSwitchPlanFailed")
SSwitchPlanFailed.TYPEID = 12613892
SSwitchPlanFailed.ERROR_GOLD_NOT_ENOUGH = -1
function SSwitchPlanFailed:ctor(genius_series_id, retcode)
  self.id = 12613892
  self.genius_series_id = genius_series_id or nil
  self.retcode = retcode or nil
end
function SSwitchPlanFailed:marshal(os)
  os:marshalInt32(self.genius_series_id)
  os:marshalInt32(self.retcode)
end
function SSwitchPlanFailed:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SSwitchPlanFailed:sizepolicy(size)
  return size <= 65535
end
return SSwitchPlanFailed
