local CTakeCoupleDailyTask = class("CTakeCoupleDailyTask")
CTakeCoupleDailyTask.TYPEID = 12602378
function CTakeCoupleDailyTask:ctor(index)
  self.id = 12602378
  self.index = index or nil
end
function CTakeCoupleDailyTask:marshal(os)
  os:marshalInt32(self.index)
end
function CTakeCoupleDailyTask:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CTakeCoupleDailyTask:sizepolicy(size)
  return size <= 65535
end
return CTakeCoupleDailyTask
