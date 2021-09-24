-- 读取过自己的战报
function api_military_readAll(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local battlelogLib=require "lib.battlelog"
    local msg = battlelogLib:logReadAll(uid)
    
    if msg then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = ''
    end

    return response
end
