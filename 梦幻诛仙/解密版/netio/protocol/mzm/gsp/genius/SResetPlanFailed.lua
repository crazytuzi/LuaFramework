local SResetPlanFailed = class("SResetPlanFailed")
SResetPlanFailed.TYPEID = 12613895
SResetPlanFailed.ERROR_GOLD_NOT_ENOUGH = -1
function SResetPlanFailed:ctor(genius_series_id, retcode)
  self.id = 12613895
  self.genius_series_id = genius_series_id or nil
  self.retcode = retcode or nil
end
function SResetPlanFailed:marshal(os)
  os:marshalInt32(self.genius_series_id)
  os:marshalInt32(self.retcode)
end
function SResetPlanFailed:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SResetPlanFailed:sizepolicy(size)
  return size <= 65535
end
return SResetPlanFailed
