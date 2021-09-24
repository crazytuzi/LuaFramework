function api_skyladderserver_clearlog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = tonumber(request.params.action)
    local stype = tonumber(request.params.stype)

    if not action or not stype then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()

    local rtype
    if action == 1 then
        rtype = 'person'
    elseif action == 2 then
        rtype = 'alliance'
    else
        response.ret = -102
        return response
    end
    
    local base = skyladderserver.getStatus()
    print(rtype,stype)
    skyladderserver.clearSkyladderLog(base.cubid,rtype,stype)
    
    if skyladderserver.commit() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end