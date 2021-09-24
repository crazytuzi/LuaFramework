--[[
    服内区域战，获取当前剩余部队数
]]
function api_areawar_gettroops(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver={},
        },
    }

    -- bid 当日区域战的标识，由后端分配，所有的数据靠bid来关联
    -- aid 军团id
    local uid = tonumber(request.uid)
    local aid = tostring(request.params.aid)

    if  aid == nil or uid == nil then
        response.ret = -102
        return response
    end
    
    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()
    
    local userActionInfo=mAreaWar.getUserActionInfoFromCache(bid,uid,aid)
    if type(userActionInfo) == 'table' then
        response.data.areaWarserver.troops = userActionInfo.troops
        if type(userActionInfo.binfo[5])=="table" and userActionInfo.binfo[5][1] then
            response.data.areaWarserver.plane= userActionInfo.binfo[5][1]
        end
        local _,heros = mAreaWar.getTroopsByBinfo(userActionInfo.binfo)
        if type(heros) == 'table' then
            response.data.areaWarserver.heros = heros[1]
        end
		response.data.areaWarserver.equip= userActionInfo.binfo[4]
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
