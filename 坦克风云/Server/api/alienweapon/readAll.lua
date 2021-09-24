-- 读取过自己的战报
function api_alienweapon_readAll(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local log_type = tonumber(request.params.log_type)
    local battlelogLib=require "lib.battlelog"
    local msg = battlelogLib:logAweaponReadAll(uid, log_type)
    
    if msg then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = ''
    end

    return response
end
