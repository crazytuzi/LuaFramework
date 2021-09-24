-- 获取参赛者的花数
function api_crossserver_getuserbet(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local bid = request.params.bid
    if not bid then
        response.ret = -102 
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local datas = cross:getBattleDataByBid(bid)

    if not datas then
        response.err = 'can not get datas : bid - ' .. bid
        return response
    end

    local ret = {}
    for k, v in pairs(datas) do
        ret[k] = {}
        if v.bet and v.uid and v.zid then
            ret[k].uid = v.uid
            ret[k].zid = v.zid
            ret[k].bet = v.bet
        end
    end

    response.data.bet = ret
    response.ret = 0
    response.msg = 'Success'

    return response
end
