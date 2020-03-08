local SResetPlanSuccess = class("SResetPlanSuccess")
SResetPlanSuccess.TYPEID = 12613894
function SResetPlanSuccess:ctor(genius_series_id)
  self.id = 12613894
  self.genius_series_id = genius_series_id or nil
end
function SResetPlanSuccess:marshal(os)
  os:marshalInt32(self.genius_series_id)
end
function SResetPlanSuccess:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
end
function SResetPlanSuccess:sizepolicy(size)
  return size <= 65535
end
return SResetPlanSuccess
