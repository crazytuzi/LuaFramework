local SBackGameExpTaskFinish = class("SBackGameExpTaskFinish")
SBackGameExpTaskFinish.TYPEID = 12620564
function SBackGameExpTaskFinish:ctor(task_finish_time)
  self.id = 12620564
  self.task_finish_time = task_finish_time or nil
end
function SBackGameExpTaskFinish:marshal(os)
  os:marshalInt64(self.task_finish_time)
end
function SBackGameExpTaskFinish:unmarshal(os)
  self.task_finish_time = os:unmarshalInt64()
end
function SBackGameExpTaskFinish:sizepolicy(size)
  return size <= 65535
end
return SBackGameExpTaskFinish
