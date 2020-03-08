local OctetsStream = require("netio.OctetsStream")
local ShiTuTaskInfo = class("ShiTuTaskInfo")
ShiTuTaskInfo.NO_PUBLISHED = 0
ShiTuTaskInfo.YES_PUBLISHED = 1
ShiTuTaskInfo.APPRENTICE_RECEIVED = 2
ShiTuTaskInfo.RECEIVE_MAX_LEVEL = 3
ShiTuTaskInfo.RECEIVE_MAX_TIMES = 4
ShiTuTaskInfo.LEAVE_MASTER_TODAY = 5
ShiTuTaskInfo.CHU_SHI = 6
ShiTuTaskInfo.MAX_PUBLISH_TIMES = 7
function ShiTuTaskInfo:ctor(role_id, publish_state, refresh_times, shitu_task_count, task_infos)
  self.role_id = role_id or nil
  self.publish_state = publish_state or nil
  self.refresh_times = refresh_times or nil
  self.shitu_task_count = shitu_task_count or nil
  self.task_infos = task_infos or {}
end
function ShiTuTaskInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.publish_state)
  os:marshalInt32(self.refresh_times)
  os:marshalInt32(self.shitu_task_count)
  local _size_ = 0
  for _, _ in pairs(self.task_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.task_infos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function ShiTuTaskInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.publish_state = os:unmarshalInt32()
  self.refresh_times = os:unmarshalInt32()
  self.shitu_task_count = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuTask")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.task_infos[k] = v
  end
end
return ShiTuTaskInfo
