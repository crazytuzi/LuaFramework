local OctetsStream = require("netio.OctetsStream")
local ShiTuTask = class("ShiTuTask")
ShiTuTask.UN_ACCEPTED = 0
ShiTuTask.ALREADY_ACCEPTED = 1
ShiTuTask.FINISHED = 2
ShiTuTask.GIVE_UP = 3
ShiTuTask.MASTER_REWARDED = 4
function ShiTuTask:ctor(task_id, task_state)
  self.task_id = task_id or nil
  self.task_state = task_state or nil
end
function ShiTuTask:marshal(os)
  os:marshalInt32(self.task_id)
  os:marshalInt32(self.task_state)
end
function ShiTuTask:unmarshal(os)
  self.task_id = os:unmarshalInt32()
  self.task_state = os:unmarshalInt32()
end
return ShiTuTask
