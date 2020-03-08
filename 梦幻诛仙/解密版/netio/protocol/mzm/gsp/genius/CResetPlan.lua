local CResetPlan = class("CResetPlan")
CResetPlan.TYPEID = 12613896
function CResetPlan:ctor(genius_series_id)
  self.id = 12613896
  self.genius_series_id = genius_series_id or nil
end
function CResetPlan:marshal(os)
  os:marshalInt32(self.genius_series_id)
end
function CResetPlan:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
end
function CResetPlan:sizepolicy(size)
  return size <= 65535
end
return CResetPlan
