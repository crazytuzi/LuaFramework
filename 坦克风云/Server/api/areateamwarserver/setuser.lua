--[[
    跨服军团战，设置用户数据
    
    检测：
        TODO 所属军团是否已经报名了军团战，暂时不做，服内做验证吧
        TODO 当前时间是否还允许设置部队，暂时不做，服内做这个验证    
]]
function api_areateamwarserver_setuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local data = request.params.data
    local action = request.params.action or 'apply'
    local group = request.params.group

    if not data then
        response.ret = -102
        return response
    end

    if request.params.sn and not group then
        response.ret = -102
        return response
    end

    local addgems = tonumber(data.addgems) or 0

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,data.bid)

    local ret, err

    -- 如果是报名，需要验证所属军团是否已经报名
    if action == 'apply' then
        if addgems>0 then
            data.gems=addgems
            data.carrygems=carrygems
            data.addgems = nil
        end
        ret,err = mAreaWar.setUserBattleData(data)
        if not ret then
            ret = mAreaWar.getUserDataFromDb(data.bid,data.zid,data.aid,data.uid)
            if ret then 
                ret,err = mAreaWar.updateUserBattleData(data,request.params.sn)
            end
        end
    elseif action == 'update' then
        if addgems > 0 then
            local userData = mAreaWar.getUserDataFromDb(data.bid,data.zid,data.aid,data.uid)
            if type(userData) == 'table' and userData.carrygems and userData.gems then
                data.gems = (tonumber(userData.gems) or 0) + addgems
                data.carrygems = (tonumber(userData.carrygems) or 0) + addgems
                data.addgems = nil
            end
        end

        ret,err = mAreaWar.updateUserBattleData(data,request.params.sn)
    end

    if not ret then
        response.err = err
        response.ret = -21012
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
