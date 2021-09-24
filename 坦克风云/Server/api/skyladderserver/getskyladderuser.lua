-- 读取天梯
function api_skyladderserver_getskyladderuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local battleType = tonumber(request.params.battleType) or 1
    local num = tonumber(request.params.num) or 3
    local page = tonumber(request.params.page)
    local limit = tonumber(request.params.limit) or 100

    if not action then
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
    local rankList = across.getSkyladder(base.cubid,rtype,battleType,num,page,limit)

    response.ret = 0
    response.msg = 'Success'
    response.data.rankList = rankList

    return response
end