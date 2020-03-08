local OctetsStream = require("netio.OctetsStream")
local AccumTotalCostActivityInfo = class("AccumTotalCostActivityInfo")
function AccumTotalCostActivityInfo:ctor(base_accum_total_cost, sortid)
  self.base_accum_total_cost = base_accum_total_cost or nil
  self.sortid = sortid or nil
end
function AccumTotalCostActivityInfo:marshal(os)
  os:marshalInt64(self.base_accum_total_cost)
  os:marshalInt32(self.sortid)
end
function AccumTotalCostActivityInfo:unmarshal(os)
  self.base_accum_total_cost = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
end
return AccumTotalCostActivityInfo
