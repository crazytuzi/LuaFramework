local CSwitchPlan = class("CSwitchPlan")
CSwitchPlan.TYPEID = 12613899
function CSwitchPlan:ctor(genius_series_id)
  self.id = 12613899
  self.genius_series_id = genius_series_id or nil
end
function CSwitchPlan:marshal(os)
  os:marshalInt32(self.genius_series_id)
end
function CSwitchPlan:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
end
function CSwitchPlan:sizepolicy(size)
  return size <= 65535
end
return CSwitchPlan
