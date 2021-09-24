-- 更新天梯榜中的用户名称
function api_skyladderserver_setname(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local cubid = request.params.cubid
    local action = request.params.action
    local zid = tonumber(request.params.zid)
    local id = tonumber(request.params.id)
    local name = request.params.name

    if not cubid or not action or not id then
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
    
    local data = skyladderserver.changeName(cubid,rtype,zid,id,name)

    if skyladderserver.commit() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end