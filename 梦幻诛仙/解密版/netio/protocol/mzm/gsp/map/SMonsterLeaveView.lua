local SMonsterLeaveView = class("SMonsterLeaveView")
SMonsterLeaveView.TYPEID = 12590880
function SMonsterLeaveView:ctor(monsterInstanceId)
  self.id = 12590880
  self.monsterInstanceId = monsterInstanceId or nil
end
function SMonsterLeaveView:marshal(os)
  os:marshalInt32(self.monsterInstanceId)
end
function SMonsterLeaveView:unmarshal(os)
  self.monsterInstanceId = os:unmarshalInt32()
end
function SMonsterLeaveView:sizepolicy(size)
  return size <= 65535
end
return SMonsterLeaveView
