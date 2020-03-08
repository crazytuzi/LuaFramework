local CAnswerMakeUpQuestion = class("CAnswerMakeUpQuestion")
CAnswerMakeUpQuestion.TYPEID = 12625922
function CAnswerMakeUpQuestion:ctor(activityId, optionId)
  self.id = 12625922
  self.activityId = activityId or nil
  self.optionId = optionId or nil
end
function CAnswerMakeUpQuestion:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.optionId)
end
function CAnswerMakeUpQuestion:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.optionId = os:unmarshalInt32()
end
function CAnswerMakeUpQuestion:sizepolicy(size)
  return size <= 65535
end
return CAnswerMakeUpQuestion
