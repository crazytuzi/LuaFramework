local OctetsStream = require("netio.OctetsStream")
local CrossFieldMatchProcess = class("CrossFieldMatchProcess")
CrossFieldMatchProcess.PROCESS_MATCHING = 0
CrossFieldMatchProcess.PROCESS_MATCHED = 1
CrossFieldMatchProcess.PROCESS_GEN_TOKEN_SUC = 2
CrossFieldMatchProcess.PROCESS_TRANSFOR_DATA_SUC = 3
CrossFieldMatchProcess.PROCESS_ROAM_LOGIN = 4
function CrossFieldMatchProcess:ctor()
end
function CrossFieldMatchProcess:marshal(os)
end
function CrossFieldMatchProcess:unmarshal(os)
end
return CrossFieldMatchProcess
