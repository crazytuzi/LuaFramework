local SSyncRewardInfoInfo = class("SSyncRewardInfoInfo")
SSyncRewardInfoInfo.TYPEID = 12623106
function SSyncRewardInfoInfo:ctor(activity_cfg_id, task_activity_id2reward_stages)
  self.id = 12623106
  self.activity_cfg_id = activity_cfg_id or nil
  self.task_activity_id2reward_stages = task_activity_id2reward_stages or {}
end
function SSyncRewardInfoInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  local _size_ = 0
  for _, _ in pairs(self.task_activity_id2reward_stages) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.task_activity_id2reward_stages) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSyncRewardInfoInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.birthdaypray.RewardStages")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.task_activity_id2reward_stages[k] = v
  end
end
function SSyncRewardInfoInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRewardInfoInfo
