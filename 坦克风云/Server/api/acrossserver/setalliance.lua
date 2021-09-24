--[[
    跨服军团战，设置军团数据
    
    检测：
        TODO 所属军团是否已经报名了军团战，暂时不做，服内做验证吧
        TODO 当前时间是否还允许设置部队，暂时不做，服内做这个验证    
]]
function api_acrossserver_setalliance(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local data = request.params.data
    local action = request.params.action or 'apply'

    if not data then
        response.ret = -102 
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(data.bid)

    local ret, err, errcode

    -- 如果是报名，需要验证所属军团是否已经报名
    if action == 'apply' then
        ret,err = across:setAllianceData(data)
        if not ret then
            ret = across:getAllianceApplyData(data.bid,data.zid,data.aid)
        end
        errcode = ret or -21005
    elseif action == 'update' then
        ret,err = across:updateAllianceData(data)
        errcode = ret or -21014
    end

    if not ret then
        response.err = err
        response.ret = errcode
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
