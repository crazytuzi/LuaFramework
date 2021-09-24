--[[
    跨服军团战，获取每场的积分击杀等信息
        
    以客户端为单元每10秒主动请求一次，无逻辑处理，只是返还总比分
    如果比赛结束，将结束标识返给前端
]]
function api_acrossserver_roundinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }
    
    local bid = request.params.bid
    local group = request.params.group
    local zid = request.zoneid
    local aid = request.params.aid
    local uid = request.uid
    local round = request.params.round
    local action = request.params.action or 1

    if bid == nil or group == nil or round == nil then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)
    
    if action == 1 then
        response.data = across:getAllianceRoundInfo(bid,group,zid,round)
    else
        response.data = across:getMemberRoundInfo(bid,group,zid,aid,uid,round)
    end
    
    response.ret = 0
    response.msg = 'Success'       
    
    return response
end
