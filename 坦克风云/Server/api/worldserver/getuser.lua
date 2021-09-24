function api_worldserver_getuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local bid = request.params.bid
    local uid = request.params.uid
    local zid = request.params.zid
    local round = request.params.round
    local matchType = request.params.jointype

    if not bid or not uid or not zid or not matchType then
        response.ret = -102
        return response
    end

    local wcrossserver = require "model.worldserver"
    local wcross = wcrossserver.new()

    local userData = wcross:getUserApplyData(bid,zid,uid,matchType)
    userData.userrank = wcross:getPointMatchRanking(bid,round,uid,matchType)

    -- 过滤掉不用的数据
    userData.binfo = nil
    userData.heroAccessoryInfo = nil
    userData.updated_at = nil
    userData.eliminateFlag = nil
    userData.battle_at = nil
    userData.aname = nil
    userData.strategy = nil
    userData.nickname = nil
    userData.apply_at = nil
    userData.sround = nil
    userData.status = nil
    userData.level=nil
    userData.pic = nil
    userData.round = nil

    response.data.userinfo = userData
    response.ret = 0
    response.msg = 'Success'

    return response



end