function api_skyladderserver_getmyrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local zid = tonumber(request.params.zid)
    local id = tonumber(request.params.id)
    local page = tonumber(request.params.page) or 1

    if not action or not id then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local across = model_skyladderserver()

    local rtype
    if action == 1 then
        rtype = 'person'
    elseif action == 2 then
        rtype = 'alliance'
    else
        response.ret = -102
        return response
    end
    
    local base = across.getStatus()
    local myrank = across.getRank(base.cubid,rtype,zid,id) or 0
    local data = across.getRankData(base.cubid,rtype,zid,id) or {}
    local cfg = getConfig("skyladderCfg")
    local countField = cfg[rtype..'CountField']
    local detail = {}
    local score = 0
    for i,v in pairs(countField) do
        detail[tostring(v)] = tonumber(data[i]) or 0
        score = score + (tonumber(data[i]) or 0)
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.myrank = myrank
    response.data.score = score
    response.data.detail = detail

    if ts > tonumber(base.overtime) or tonumber(base.over) == 1 then
        response.data.over = 1
    end

    return response
end