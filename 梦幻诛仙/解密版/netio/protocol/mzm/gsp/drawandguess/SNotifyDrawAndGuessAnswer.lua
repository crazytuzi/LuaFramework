local AnswerInfo = require("netio.protocol.mzm.gsp.drawandguess.AnswerInfo")
local SNotifyDrawAndGuessAnswer = class("SNotifyDrawAndGuessAnswer")
SNotifyDrawAndGuessAnswer.TYPEID = 12617243
function SNotifyDrawAndGuessAnswer:ctor(answerInfo)
  self.id = 12617243
  self.answerInfo = answerInfo or AnswerInfo.new()
end
function SNotifyDrawAndGuessAnswer:marshal(os)
  self.answerInfo:marshal(os)
end
function SNotifyDrawAndGuessAnswer:unmarshal(os)
  self.answerInfo = AnswerInfo.new()
  self.answerInfo:unmarshal(os)
end
function SNotifyDrawAndGuessAnswer:sizepolicy(size)
  return size <= 65535
end
return SNotifyDrawAndGuessAnswer
