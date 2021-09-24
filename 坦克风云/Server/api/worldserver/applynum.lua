function api_worldserver_applynum(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local bid = request.params.bid
    local matchType = request.params.jointype

    if not bid or not matchType then
        response.ret = -102
        return response
    end

    local wcrossserver = require "model.worldserver"
    local wcross = wcrossserver.new()

    local num = wcross:getUserApplyNum(bid,matchType)

    response.data.applynum = num
    response.ret = 0
    response.msg = 'Success'

    return response
end