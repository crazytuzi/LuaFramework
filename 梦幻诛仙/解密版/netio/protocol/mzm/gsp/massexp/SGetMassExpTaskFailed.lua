local SGetMassExpTaskFailed = class("SGetMassExpTaskFailed")
SGetMassExpTaskFailed.TYPEID = 12608261
SGetMassExpTaskFailed.ERROR_ACTIVITY_NOT_OPEN = -1
SGetMassExpTaskFailed.ERROR_LEVEL_LIMIT = -2
SGetMassExpTaskFailed.ERROR_TASK_RECEIVED = -3
function SGetMassExpTaskFailed:ctor(retcode)
  self.id = 12608261
  self.retcode = retcode or nil
end
function SGetMassExpTaskFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetMassExpTaskFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetMassExpTaskFailed:sizepolicy(size)
  return size <= 65535
end
return SGetMassExpTaskFailed
