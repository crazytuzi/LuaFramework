local OctetsStream = require("netio.OctetsStream")
local MemoryCompetitionConst = class("MemoryCompetitionConst")
MemoryCompetitionConst.ANSWER_WERONG = 0
MemoryCompetitionConst.ANSWER_RIGHT = 1
function MemoryCompetitionConst:ctor()
end
function MemoryCompetitionConst:marshal(os)
end
function MemoryCompetitionConst:unmarshal(os)
end
return MemoryCompetitionConst
