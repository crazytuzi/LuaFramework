local SSwitchPlanSuccess = class("SSwitchPlanSuccess")
SSwitchPlanSuccess.TYPEID = 12613897
function SSwitchPlanSuccess:ctor(genius_series_id)
  self.id = 12613897
  self.genius_series_id = genius_series_id or nil
end
function SSwitchPlanSuccess:marshal(os)
  os:marshalInt32(self.genius_series_id)
end
function SSwitchPlanSuccess:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
end
function SSwitchPlanSuccess:sizepolicy(size)
  return size <= 65535
end
return SSwitchPlanSuccess
