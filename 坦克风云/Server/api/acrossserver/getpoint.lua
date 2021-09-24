--[[
    跨服军团战，获取总积分对比
        
    以客户端为单元每10秒主动请求一次，无逻辑处理，只是返还总比分
    如果比赛结束，将结束标识返给前端
]]
function api_acrossserver_getpoint(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }
    
    local bid = request.params.bid
    local group = request.params.group
    local aid = request.params.aid
    local round = request.params.round
    local uid = request.uid
    local zid = request.zoneid

    if bid == nil or group == nil or not round or not uid then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    -- 如果游戏结束，将结束标识返给前端
    if across:getAllianceEndBattleFlag(bid,group) then        
        response.data.acrossserver.over =across:getOverData(bid,group,zid,aid,uid,round)
        response.data.acrossserver.points = response.data.acrossserver.over.points
    end
    
    -- 获取当前比分 
    if not response.data.acrossserver.points then
        local points = across:getPoint(bid,group)
        response.data.acrossserver.points = points
    end

    response.ret = 0
    response.msg = 'Success'       
    
    return response
end
