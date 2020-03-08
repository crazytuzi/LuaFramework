local SSyncQuestionNormalResult = class("SSyncQuestionNormalResult")
SSyncQuestionNormalResult.TYPEID = 12594699
SSyncQuestionNormalResult.HELP_ANSWER_LH_QUESTION_INVALID = 0
SSyncQuestionNormalResult.HELP_QYXT_ALEARDY_ANSWER = 1
SSyncQuestionNormalResult.HELP_QYXT_ALEARDY_HELP = 2
SSyncQuestionNormalResult.HELP_QYXT_NOT_IN_GANG = 3
SSyncQuestionNormalResult.HELP_QYXT_GANG_CHANGE = 4
function SSyncQuestionNormalResult:ctor(result)
  self.id = 12594699
  self.result = result or nil
end
function SSyncQuestionNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SSyncQuestionNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SSyncQuestionNormalResult:sizepolicy(size)
  return size <= 65535
end
return SSyncQuestionNormalResult
