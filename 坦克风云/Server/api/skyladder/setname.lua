-- 记录分组信息
function api_skyladder_setname(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    if moduleIsEnabled('ladder') == 0 then
        response.ret = -19000
        return response
    end
    
    local ts = getClientTs()
    local action = request.params.action
    local zid = getZoneId()
    local id = tonumber(request.id)
    local name = request.params.name

    if not action or not name then
        response.ret = -102
        return response
    end
    
    -- 天梯榜状态
    require "model.skyladder"
    local skyladder = model_skyladder()
    local base = skyladder.getBase() -- 阶段状态
    local ret = skyladder.setName(base.cubid,action,zid,id,name)

    response.ret = 0
    response.msg = 'Success'

    return response
end