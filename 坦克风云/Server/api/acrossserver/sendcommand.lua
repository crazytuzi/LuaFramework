--[[
    军团长发送指令

    说明：
        指令在整个战斗期间都存在
        同一军团最多两条指令
        同一据点最多一条指令
        同一据点发送指令时优先顶掉本据点的上一条指令
]]
function api_acrossserver_sendcommand(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }

    local uid = tonumber(request.uid)
    local zid = request.zoneid
    local bid = request.params.bid
    local aid = request.params.aid
    local group = request.params.group
    local round = request.params.round
    local command = request.params.command

    if bid == nil or aid == nil or uid == nil or group == nil or type(command) ~= 'table' then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    -- 如果游戏结束，将结束标识返给前端
    if across:getAllianceEndBattleFlag(bid,group) then        
        response.data.acrossserver.over =across:getOverData(bid,group,zid,aid,uid,round)
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置
    across:setAllianceCommand(bid,group,zid,aid,command)

    -- 推送
    local usersActionInfo = across:getUsersActionInfo(bid,group)
    for _,v in pairs(usersActionInfo or {}) do
        if tonumber(v.aid) == tonumber(aid) then
            local mid = tonumber(v.uid)
            if mid then
                regSendMsg(mid,'acrossserver.battle.push',{acrossserver={command=command}})
            end
        end
    end

    response.ret = 0
    response.msg = 'Success'
    return response
end
