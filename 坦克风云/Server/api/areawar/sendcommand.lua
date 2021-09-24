--[[
    区域战，军团长发送指令

    说明：
        指令在整个战斗期间都存在
        同一军团最多两条指令
        同一据点最多一条指令
        同一据点发送指令时优先顶掉本据点的上一条指令
    
    如果当前区域战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_areawar_sendcommand(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    local uid = request.uid
    local aid = request.params.aid
    local command = request.params.command

    if uid == nil or aid == nil or type(command) ~= 'table' then
        response.ret = -102
        return response
    end
    
    local ts = getClientTs()

    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()

    -- 如果游戏结束，将结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {winner=overFlag}
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 军团已被消灭
    if mAreaWar.getAllianceDieFlag(bid,aid) then
        response.ret = -4202
        return response
    end

    -- 军团长才有权限
    local userinfo = mAreaWar.getUserData(bid,uid,aid)
    if userinfo and tonumber(userinfo.role) ~= 2 then
        response.ret = -8008
        return response
    end

    local areaWarCfg = getConfig('areaWarCfg')
    local localWarMapCfg = getConfig('localWarMapCfg')

    mAreaWar.setAllianceCommand(bid,aid,command)
    
    -- 挨个推送吧
    local members = mAreaWar.getAllianceMemUids(bid,aid)

    for k,v in pairs(members) do
        local mid = tonumber(v)
        if mid then
            regSendMsg(mid,'areawarserver.battle.push',{areaWarserver={command=command}})
        end
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end