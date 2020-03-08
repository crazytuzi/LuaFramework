local SSynAnswerDrawAndGuessFinished = class("SSynAnswerDrawAndGuessFinished")
SSynAnswerDrawAndGuessFinished.TYPEID = 12617257
function SSynAnswerDrawAndGuessFinished:ctor(rightAnswer)
  self.id = 12617257
  self.rightAnswer = rightAnswer or nil
end
function SSynAnswerDrawAndGuessFinished:marshal(os)
  os:marshalString(self.rightAnswer)
end
function SSynAnswerDrawAndGuessFinished:unmarshal(os)
  self.rightAnswer = os:unmarshalString()
end
function SSynAnswerDrawAndGuessFinished:sizepolicy(size)
  return size <= 65535
end
return SSynAnswerDrawAndGuessFinished
