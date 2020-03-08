local OctetsStream = require("netio.OctetsStream")
local DrawAndGuessConst = class("DrawAndGuessConst")
DrawAndGuessConst.REFUSE = 0
DrawAndGuessConst.AGREE = 1
DrawAndGuessConst.WRONG = 0
DrawAndGuessConst.RIGHT = 1
DrawAndGuessConst.MAX_TOTAL_POINT = 40960
DrawAndGuessConst.MAX_CACHE_ANSWER = 30
DrawAndGuessConst.MAX_ANSWER_LENGTH = 40
DrawAndGuessConst.ANSWER_CD = 1
DrawAndGuessConst.LOGIN = 0
DrawAndGuessConst.NEW = 1
function DrawAndGuessConst:ctor()
end
function DrawAndGuessConst:marshal(os)
end
function DrawAndGuessConst:unmarshal(os)
end
return DrawAndGuessConst
