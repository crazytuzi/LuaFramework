local SAnswerMakeUpRep = class("SAnswerMakeUpRep")
SAnswerMakeUpRep.TYPEID = 12625925
SAnswerMakeUpRep.ANSWER_RIGHT = 1
SAnswerMakeUpRep.ANSWER_WRONG = 2
function SAnswerMakeUpRep:ctor(activityId, optionId, res)
  self.id = 12625925
  self.activityId = activityId or nil
  self.optionId = optionId or nil
  self.res = res or nil
end
function SAnswerMakeUpRep:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.optionId)
  os:marshalInt32(self.res)
end
function SAnswerMakeUpRep:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.optionId = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SAnswerMakeUpRep:sizepolicy(size)
  return size <= 65535
end
return SAnswerMakeUpRep
