function api_military_delete(request)
    local response = {
        data = {},
    }

    local uid = request.uid
    local messageid = request.params.eid
    
    local battlelogLib=require "lib.battlelog"    
    local ret = battlelogLib:logDel(uid,messageid)

    if ret then 
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
