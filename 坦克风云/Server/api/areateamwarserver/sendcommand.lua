--[[
    区域战，军团长发送指令

    说明：
        指令在整个战斗期间都存在
        同一军团最多两条指令
        同一据点最多一条指令
        同一据点发送指令时优先顶掉本据点的上一条指令
    
    如果当前区域战已经结束，不走其它逻辑，直接给前端一个战斗结束的状态码
]]
function api_areateamwarserver_sendcommand(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    local uid = request.uid
    local aid = request.params.aid
    local bid = request.params.bid
    local group = request.params.group
    local command = request.params.command
    local zid = getZoneId()

    if bid == nil or uid == nil or aid == nil or group == nil or type(command) ~= 'table' then
        response.ret = -102
        return response
    end

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    -- 游戏结束,结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {
                winner=overFlag,
                battlePointInfo=mAreaWar.getWarPointInfo(bid),
            }
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 军团长才有权限
    local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
    if not userinfo or tonumber(userinfo.role) ~= 2 then
        response.ret = -8008
        return response
    end

    -- 设置
    mAreaWar.setAllianceCommand(bid,zid,aid,command)

    -- 推送
    local members = mAreaWar.getAllianceMemUids(bid,aid,zid)
    for k,v in pairs(members) do
        local mid = tonumber(v)
        if mid then
            regSendMsg(mid,'areateamwarserver.battle.push',{areaWarserver={command=command}})
        end
    end

    response.ret = 0
    response.msg = 'Success'
    return response
end