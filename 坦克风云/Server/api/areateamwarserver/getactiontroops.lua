--[[
    获取当前用户的行动部队
]]
function api_areateamwarserver_getactiontroops(request)
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
    local init = request.params.init
    local bid = request.params.bid
    local group = request.params.group
    local init = request.params.init

    if aid == nil or uid == nil or bid == nil or group == nil then
        response.ret = -102
        return response
    end

    local zid = getZoneId()
    
    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
    if not userinfo then
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    response.data.areaWarserver.troops = {}
    response.data.areaWarserver.hero = {}
    response.data.areaWarserver.equip = {}
    response.data.areaWarserver.plane ={}

    if userinfo and userinfo.binfo then
        local userActionInfo = mAreaWar.getUserActionInfo(bid,uid,aid,zid)
        if type(userActionInfo) == 'table' then
            for k,v in pairs(userActionInfo) do
                if type(v.binfo) == 'table' then
                    local snTroops,snHeros,snSuperEquip,splane = mAreaWar.getTroopsByBinfo(v.binfo)
                    if v.troops then
                        response.data.areaWarserver.troops[tostring(v.sn)] = v.troops
                    else
                        response.data.areaWarserver.troops[tostring(v.sn)] = snTroops[tonumber(v.sn)]
                    end
                    response.data.areaWarserver.hero[tostring(v.sn)] = snHeros[tonumber(v.sn)]
                    response.data.areaWarserver.equip[tostring(v.sn)] = snSuperEquip[tonumber(v.sn)] or 0
                    if type(splane[tonumber(v.sn)])=="table" and next(splane[tonumber(v.sn)]) then
                        response.data.areaWarserver.plane[tostring(v.sn)] = splane[tonumber(v.sn)][1] or 0
                    end
                    
                end
            end
        end
    end

    -- local troops,heros = mAreaWar.getTroopsByBinfo(userinfo.binfo)
    -- if type(troops) == 'table' then 
    --     for k,v in pairs(troops) do
    --         if not response.data.areaWarserver.troops[tostring(k)] then
    --             response.data.areaWarserver.troops[tostring(k)] = v
    --         end
    --     end
    -- end

    -- response.data.areaWarserver.hero = heros

    response.ret = 0
    response.msg = 'Success'
    return response
end
