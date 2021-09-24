-- 获取战报
function api_areawar_report(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid=tonumber(request.uid)
    local battlelogLib=require "lib.battlelog"
    local id = tonumber(request.params.id) or 0
    if id<=0 then
        response.ret=-102
        return response
    end
    local list =battlelogLib:areaLogGet(id)
    response.ret = 0
    if list.report~=nil then
        response.data.report=json.decode(list.report)
    end
    response.msg = 'Success'

    return response
end
