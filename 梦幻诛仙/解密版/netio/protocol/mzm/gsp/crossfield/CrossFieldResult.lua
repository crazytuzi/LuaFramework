local OctetsStream = require("netio.OctetsStream")
local CrossFieldResult = class("CrossFieldResult")
CrossFieldResult.RESULT_WIN = 0
CrossFieldResult.RESULT_LOSE = 1
CrossFieldResult.RESULT_TIE = 2
function CrossFieldResult:ctor()
end
function CrossFieldResult:marshal(os)
end
function CrossFieldResult:unmarshal(os)
end
return CrossFieldResult
