--删除个人远征军的战报

function api_expedition_delete(request)
    local response = {
        data = {},
    }

    local uid = request.uid
    local messageid = request.params.id
    
    local battlelogLib=require "lib.battlelog"    
    local ret = battlelogLib:logExpeditionDel(uid,messageid)

    if ret then 
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
