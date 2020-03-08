local SMakeUpTurnOver = class("SMakeUpTurnOver")
SMakeUpTurnOver.TYPEID = 12625924
function SMakeUpTurnOver:ctor(activityId, turn, rightNum)
  self.id = 12625924
  self.activityId = activityId or nil
  self.turn = turn or nil
  self.rightNum = rightNum or nil
end
function SMakeUpTurnOver:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.rightNum)
end
function SMakeUpTurnOver:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.rightNum = os:unmarshalInt32()
end
function SMakeUpTurnOver:sizepolicy(size)
  return size <= 65535
end
return SMakeUpTurnOver
