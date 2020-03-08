local SSyncScheduleInfo = class("SSyncScheduleInfo")
SSyncScheduleInfo.TYPEID = 12623108
function SSyncScheduleInfo:ctor(activity_cfg_id, task_activity_id2times)
  self.id = 12623108
  self.activity_cfg_id = activity_cfg_id or nil
  self.task_activity_id2times = task_activity_id2times or {}
end
function SSyncScheduleInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  local _size_ = 0
  for _, _ in pairs(self.task_activity_id2times) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.task_activity_id2times) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncScheduleInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.task_activity_id2times[k] = v
  end
end
function SSyncScheduleInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncScheduleInfo
