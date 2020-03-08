local SBandstandAnswerSuccess = class("SBandstandAnswerSuccess")
SBandstandAnswerSuccess.TYPEID = 12627972
function SBandstandAnswerSuccess:ctor(result, answer_index, get_reward)
  self.id = 12627972
  self.result = result or nil
  self.answer_index = answer_index or nil
  self.get_reward = get_reward or nil
end
function SBandstandAnswerSuccess:marshal(os)
  os:marshalUInt8(self.result)
  os:marshalInt32(self.answer_index)
  os:marshalUInt8(self.get_reward)
end
function SBandstandAnswerSuccess:unmarshal(os)
  self.result = os:unmarshalUInt8()
  self.answer_index = os:unmarshalInt32()
  self.get_reward = os:unmarshalUInt8()
end
function SBandstandAnswerSuccess:sizepolicy(size)
  return size <= 65535
end
return SBandstandAnswerSuccess
