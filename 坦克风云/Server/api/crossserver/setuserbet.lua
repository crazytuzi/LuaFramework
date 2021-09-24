-- 设置参赛者的花数
function api_crossserver_setuserbet(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if not request.params.detailId or not request.params.zid or not request.params.uid or not request.params.bid then
        response.ret = -102 
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local userdata = cross:getUserBattleData(request.params.zid, request.params.bid, request.params.uid)

    if not userdata then
        response.err = 'can not update userdata : user not found '
        return response
    end
    local bet = json.decode(userdata.bet) or {}
    bet[request.params.detailId] = (bet[request.params.detailId] or 0) + (tonumber(request.params.flowerNum) or 1)

    local ret = nil
    if userdata then
        ret = cross:updateUserBattleData(userdata.id, {bet=bet})
    end

    if not ret then
        response.err = cross.db:getError()
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
