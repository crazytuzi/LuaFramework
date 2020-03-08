local STeamInstanceCurProcess = class("STeamInstanceCurProcess")
STeamInstanceCurProcess.TYPEID = 12591384
function STeamInstanceCurProcess:ctor(curProcess)
  self.id = 12591384
  self.curProcess = curProcess or nil
end
function STeamInstanceCurProcess:marshal(os)
  os:marshalInt32(self.curProcess)
end
function STeamInstanceCurProcess:unmarshal(os)
  self.curProcess = os:unmarshalInt32()
end
function STeamInstanceCurProcess:sizepolicy(size)
  return size <= 65535
end
return STeamInstanceCurProcess
