local SGetAccumTotalCostActivityAwardSuccess = class("SGetAccumTotalCostActivityAwardSuccess")
SGetAccumTotalCostActivityAwardSuccess.TYPEID = 12588824
function SGetAccumTotalCostActivityAwardSuccess:ctor(activity_cfgid, sort_id)
  self.id = 12588824
  self.activity_cfgid = activity_cfgid or nil
  self.sort_id = sort_id or nil
end
function SGetAccumTotalCostActivityAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sort_id)
end
function SGetAccumTotalCostActivityAwardSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
end
function SGetAccumTotalCostActivityAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAccumTotalCostActivityAwardSuccess
