-- 记录分组信息
function api_skyladder_getgroup(request)
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
    local config = getConfig("skyladderCfg")
    local gkey = request.params.gkey
    
    if not gkey then
        response.ret = -102
        return response
    end
    
    -- 天梯榜状态
    require "model.skyladder"
    local skyladder = model_skyladder()
    local base = skyladder.getBase() -- 阶段状态
    local group = skyladder.getGroup(base.cubid,gkey)

    response.ret = 0
    response.msg = 'Success'
    response.data.ladder = {group = group,id = tonumber(gkey)}

    return response
end