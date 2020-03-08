local OctetsStream = require("netio.OctetsStream")
local QuestionVoiceConst = class("QuestionVoiceConst")
QuestionVoiceConst.WRONG = 0
QuestionVoiceConst.RIGHT = 1
function QuestionVoiceConst:ctor()
end
function QuestionVoiceConst:marshal(os)
end
function QuestionVoiceConst:unmarshal(os)
end
return QuestionVoiceConst
