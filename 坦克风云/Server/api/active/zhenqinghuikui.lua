--
-- 飞流_真情回馈
-- User: luoning
-- Date: 14-12-2
-- Time: 下午9:44
--

function api_active_zhenqinghuikui(request)

    local aname = 'zhenqinghuikui'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    local item = request.params.item

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    require "model.active"
    local mActive = model_active()
    --自定义配置文件
    local activeCfg = mActive.selfCfg(aname)
    local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)

    --每日重置领奖次数 v
    if not mUseractive.info[aname].q then
        mUseractive.info[aname].q = 0
    end

    --每日已经抽奖的次数
    if not mUseractive.info[aname].k then
        mUseractive.info[aname].k = 0
    end

    local weelTs = getWeeTs()
    if mUseractive.info[aname].q < weelTs then
        mUseractive.info[aname].q = weelTs
        mUseractive.info[aname].v = 0
        mUseractive.info[aname].k = 0
        mUseractive.info[aname].p = 0
    end

    --抽取奖励
    if action == "reward" then

        local num = request.params.num
        if mUseractive.info[aname].v < num then
            response.ret = -1981
            return response
        end
        local rewardTimes = 1
        if num == 1 then
            rewardTimes = 1
        elseif num == 10 then
            rewardTimes = 10
        else
            return response
        end

        local checkRewardUid = function(uid, location)

            if type(activeCfg.userlist) ~= "table" then
                return false
            end
            for i,v in pairs(activeCfg.userlist) do
                if tonumber(v[1]) == uid and tonumber(location) < tonumber(i) then
                    return {tonumber(v[2]), tonumber(i)}
                end
            end
            return false
        end

        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end

        local clientReward = {}
        local bigRewardFlag = false
        for i=1, rewardTimes do

            setRandSeed()
            local randNum = rand(1,100)
            local tmpInfo = checkRewardUid(uid, mUseractive.info[aname].t)
            if not bigRewardFlag and tmpInfo and randNum <= activeCfg.serverreward.vate then
                local rewardType = tmpInfo[1]
                table.insert(clientReward, {"mm", "m"..rewardType, 1})
                mUseractive.info[aname].t = tmpInfo[2]
                local redis = getRedis()
                redis:lpush(redisKey, json.encode({uid, mUserinfo.nickname, mUserinfo.level, rewardType}))
                redis:expireat(redisKey, mUseractive.info[aname].et)
                writeLog(json.encode({name=mUserinfo.nickname,uid=uid,zoneid=getZoneId()}), aname)
                bigRewardFlag = true
            else

                local reward = getRewardByPool(activeCfg.serverreward.pool)
                for mType, mNum in pairs(reward) do
                    local tmpPrefix, tmpType = serverToClient(mType)
                    table.insert(clientReward, {tmpPrefix, tmpType, mNum})
                end
                if not takeReward(uid, reward) then
                    return response
                end
            end
        end

        mUseractive.info[aname].k = mUseractive.info[aname].k + rewardTimes
        mUseractive.info[aname].v = mUseractive.info[aname].v - rewardTimes
        response.data[aname].clientReward = clientReward

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --刷新每日次数
    elseif action == "refresh" then

        if type(mUseractive.info[aname].m) ~= "table" then
            mUseractive.info[aname].m = {0,0}
        end

        local clientTs = getClientTs()
        local timeCfg = activeCfg.startTime
        local mFlag
        for i,v in pairs(timeCfg) do
            local startTime = weelTs + v[1][1] * 3600 + v[1][2] * 60
            local endTime = weelTs + v[2][1] * 3600 + v[2][2] * 60
            if startTime <= clientTs and endTime >= clientTs and mUseractive.info[aname].m[i] < weelTs then
                mFlag = i
            end
        end

        if not mFlag then
            response.ret = -1981
            return response
        end

        mUseractive.info[aname].m[mFlag] = weelTs
        mUseractive.info[aname].v = mUseractive.info[aname].v + 1

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --获取奖励列表
    elseif action == "list" then

        local redis = getRedis()
        local res = redis:lrange(redisKey, 0, -1)
        local clientReward = {}
        if type(res) == "table" and next(res) then
            for i,v in pairs(res) do
                table.insert(clientReward, json.decode(v))
            end
        end
        response.data[aname].list = clientReward
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

