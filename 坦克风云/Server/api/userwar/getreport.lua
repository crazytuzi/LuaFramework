-- 获取播放战报

function api_userwar_getreport(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local id  = request.params.id  
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end


    local userwarlogLib = require "lib.userwarlog"
    local report = userwarlogLib:userGet(id)
    if report then
        response.data.report = report
    end
    
    response.ret=0
    response.msg = 'Success' 
    return response
end