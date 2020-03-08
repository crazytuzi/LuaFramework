local SNotifyTreasureHuntProcess = class("SNotifyTreasureHuntProcess")
SNotifyTreasureHuntProcess.TYPEID = 12633095
function SNotifyTreasureHuntProcess:ctor(process, total)
  self.id = 12633095
  self.process = process or nil
  self.total = total or nil
end
function SNotifyTreasureHuntProcess:marshal(os)
  os:marshalInt32(self.process)
  os:marshalInt32(self.total)
end
function SNotifyTreasureHuntProcess:unmarshal(os)
  self.process = os:unmarshalInt32()
  self.total = os:unmarshalInt32()
end
function SNotifyTreasureHuntProcess:sizepolicy(size)
  return size <= 65535
end
return SNotifyTreasureHuntProcess
