--[[
    获取当前用户的行动部队
]]
function api_acrossserver_getactiontroops(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver={},
        },
    }

    -- bid 当日区域战的标识，由后端分配，所有的数据靠bid来关联
    -- aid 军团id
    local uid = tonumber(request.uid)
    local aid = tostring(request.params.aid)
    local bid = request.params.bid
    local group = request.params.group
    local round = request.params.round

    if aid == nil or uid == nil or bid == nil or group == nil then
        response.ret = -102
        return response
    end

    local zid = getZoneId()
    
    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    local userActionInfo = across:getUserActionInfo(bid,group,zid,aid,uid)
    if type(userActionInfo) == 'table' then
        local userinfo = across:getUserData(bid,zid,aid,uid)
        local snTroops,snHeros,equip = across.getTroopsByBinfo(userinfo.binfo)
        if userActionInfo.troops and next(userActionInfo.troops) then
            response.data.acrossserver.troops = userActionInfo.troops
        else
            response.data.acrossserver.troops = snTroops[1]
        end

        response.data.acrossserver.hero = snHeros[1]
        response.data.acrossserver.equip = equip

    end

    response.ret = 0
    response.msg = 'Success'
    return response
end
