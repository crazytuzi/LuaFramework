local OctetsStream = require("netio.OctetsStream")
local RewardStages = class("RewardStages")
function RewardStages:ctor(rewarded_stages)
  self.rewarded_stages = rewarded_stages or {}
end
function RewardStages:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rewarded_stages))
  for _, v in ipairs(self.rewarded_stages) do
    os:marshalInt32(v)
  end
end
function RewardStages:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.rewarded_stages, v)
  end
end
return RewardStages
