-- 设置用户
function api_crossserver_setuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if not request.params.udata or not request.params.udata[1] then
        response.ret = -102 
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local params = cross.formatServerUserData(request.params.udata[1])

    if params.zid == nil or params.bid == nil or params.uid == nil then
        response.ret = -102 
        return response
    end

    if type(params.binfo) ~= 'table' then
        return response
    end

    for i=1,3 do
        if not params.binfo[2][i] or not cross.formatTroops(params.binfo[1],params.binfo[2][i]) then
            response.err = 'can not update userdata : user troops invalid'
            return response
        end
    end

    local userdata = cross:getUserBattleData(params.zid,params.bid,params.uid)

    if not userdata then
        response.err = 'can not update userdata : user not found '
        return response
    end

    -- 优化,给军团加天梯分只会按报名时的军团加
    -- 抓名单时会把用户的军团ID和军团名带过来
    -- 设置部队时只会带军团名,不会带军团ID(原因不明)
    -- 战斗中如果用户切换军团后设置部队，军团ID(是老的)和军团名(新的)就对不上了，会影响天梯榜显示
    if params.aname then
        params.aname = nil
    end

    local ret = nil
    if userdata then
        ret = cross:updateUserBattleData(userdata.id,params)
    -- else
    --     ret = cross:setUserBattleData(params)
    end

    if not ret then
        response.err = cross.db:getError()
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
