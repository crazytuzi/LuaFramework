function api_skyladderserver_remalliance(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local zid = tonumber(request.params.zid)
    local id = tonumber(request.params.id)

    if not zid or not id then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()

    local base = skyladderserver.getStatus()
    local status = skyladderserver.delAllianceInfo(base.cubid,zid,id)
    
    if status then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end