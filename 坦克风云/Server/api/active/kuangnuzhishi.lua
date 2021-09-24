--
-- 狂怒之师
-- User: luoning
-- Date: 14-11-26
-- Time: 下午2:54
--
function api_active_kuangnuzhishi(request)

    local aname = 'kuangnuzhishi'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    local num = request.params.num
    local appid = tonumber(request.appid) or 0

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')

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

    if not mUseractive.info[aname].l then
        mUseractive.info[aname].l = 0
    end
    local rankKey = getActiveCacheKey(aname, "def.rank", mUseractive.info[aname].st)
    local redisInfoKey = getActiveCacheKey(aname, "def.info", mUseractive.info[aname].st)

    --flag true 增加数据 false 检查数据
    local setRankInfo = function(score, addscore)
        local redis = getRedis()
        if activeCfg.scoreLimit <= score then
            if redis:zrevrank(rankKey,uid) then
                redis:zincrby(rankKey, addscore,uid)
            else
                redis:zadd(rankKey, score, uid)
            end
            redis:hset(redisInfoKey, uid, json.encode({mUserinfo.nickname, mUserinfo.level}))
            redis:expireat(redisInfoKey, mUseractive.info[aname].et)
            redis:expireat(rankKey, mUseractive.info[aname].et)
        end
    end

    --客户端
    local serverToClient = function(type)
        local tmpData = type:split("_")
        local tmpType = tmpData[2]
        local tmpPrefix = string.sub(type, 1, 1)
        if tmpPrefix == 't' then tmpPrefix = 'o' end
        if tmpPrefix == 'a' then tmpPrefix = 'e' end
        return tmpPrefix, tmpType
    end

    if action == "getReward" then

        local nums = tonumber(num) or 0
        local weelTs = getWeeTs()
        if not (nums == 1 or nums == 10) then
            response.ret = -102
            return response
        end

        local getCostFlag = true
        if nums == 10 and mUseractive.info[aname].t < weelTs then
            response.ret = -1981
            return response
        end

        if mUseractive.info[aname].t < weelTs then
            getCostFlag = false
            nums = 1
        end

        local costGems,times = 0, 1
        if getCostFlag then
            if nums == 1 then
                costGems = activeCfg.cost
            else
                costGems,times = activeCfg.cost * activeCfg.mulc, activeCfg.mul
            end
        end

        local redis = getRedis()
        local checkKey = getActiveCacheKey(aname, "def.check", mUseractive.info[aname].st)
        local wholeNums = redis:get(checkKey)
        if not wholeNums then
            local freeData = getFreeData(aname..mUseractive.info[aname].st)
            if type(freeData) == "table"
                    and type(freeData.info) == "table"
                    and freeData.info.count
            then
               wholeNums = tonumber(freeData.info.count) or 0
               redis:set(checkKey, wholeNums)
            else
               redis:set(checkKey, 0)
            end
        end
        wholeNums = tonumber(wholeNums) or 0

        --格式化活动奖励
        local formatReward = function(reward)
            local clientReward, serverReward, score = {}, {}, 0
            for i, v in pairs(reward) do
                serverReward = {[i]=v[1] }
                setRandSeed()
                local rankNum = rand(v[2][1],v[2][2])
                score = rankNum
                local tmpPredix, tmpType = serverToClient(i)
                clientReward = {tmpPredix, tmpType, v[1], score}
            end
            return clientReward, serverReward, score
        end
        local clientAllReward = {}

        local checkFlag = false
        local addScore = 0
        for i=1, times do
            setRandSeed()
            local rankNum = rand(1,1000)
            --概率抽到电影票
            if  rankNum <= (activeCfg.serverreward.vate * 10)
                --电影票个人限制
                and mUseractive.info[aname].v < activeCfg.serverreward.aperson
                --电影票全服限制
                and wholeNums < activeCfg.limit
                --缓存key 防止并发
                and (not checkFlag)
                --是否在可以抽到电影票的渠道里
                and table.contains(activeCfg.serverreward.appid, appid)
            then
                local tmpwholeNums = wholeNums
                local wholeNums = redis:incr(checkKey)
                if not wholeNums then
                    return response
                end
                redis:expireat(checkKey, mUseractive.info[aname].et)
                if wholeNums <= activeCfg.limit and wholeNums <= 10 and tonumber(wholeNums) > tmpwholeNums then
                    local clientReward,serverreward,score  = formatReward(activeCfg.serverreward.movie)
                    table.insert(clientAllReward, clientReward)
                    if not takeReward(uid, serverreward) then
                        return response
                    end
                    mUseractive.info[aname].l = mUseractive.info[aname].l + score
                    addScore = addScore + score
                    getFreeData(aname..mUseractive.info[aname].st)
                    if not setFreeData(aname..mUseractive.info[aname].st, {count=wholeNums,time=mUseractive.info[aname].et}) then
                        return response
                    end
                    checkFlag = true
                    mUseractive.info[aname].v = mUseractive.info[aname].v + 1
                    writeLog(json.encode({name=mUserinfo.nickname,uid=uid,zoneid=getZoneId()}), aname)
                else
                    local tmpReward = getRewardByPool(activeCfg.serverreward.pool)
                    local clientReward,serverreward,score  = formatReward(tmpReward)
                    if not takeReward(uid, serverreward) then
                        return response
                    end
                    table.insert(clientAllReward, clientReward)
                    mUseractive.info[aname].l = mUseractive.info[aname].l + score
                    addScore = addScore + score
                end
            else
                local tmpReward = getRewardByPool(activeCfg.serverreward.pool)
                local clientReward,serverreward,score  = formatReward(tmpReward)
                if not takeReward(uid, serverreward) then
                    return response
                end
                table.insert(clientAllReward, clientReward)
                mUseractive.info[aname].l = mUseractive.info[aname].l + score
                addScore = addScore + score
            end
        end
        response.data[aname].clientReward = clientAllReward

        if getCostFlag then
            if costGems < activeCfg.cost or not mUserinfo.useGem(costGems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=48,item="",value=costGems,params={buyNum=nums,hasNum=clientAllReward}})
        else
            mUseractive.info[aname].t = weelTs
        end
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        --设置排名信息
        setRankInfo(mUseractive.info[aname].l, addScore)

        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = "Success"
        end

    elseif action == "getlist" then

        local redis = getRedis()
        local rank = redis:zrevrank(rankKey,uid)
        if activeCfg.scoreLimit <= mUseractive.info[aname].l
                and not rank then
            setRankInfo(mUseractive.info[aname].l, 0)
            rank = redis:zrevrank(rankKey,uid)
        end

        local result = redis:zrevrange(rankKey,0,(activeCfg.ranklimit -1),'withscores')
        local clientResult = {}
        local uids = {}
        if type(result) == 'table' and next(result) then
            for k,v in pairs(result) do
                table.insert(clientResult, {v[1], k, v[2]})
                table.insert(uids, v[1])
            end
            if not next(uids) then
                return  response
            end
            local uInfos = redis:hmget(redisInfoKey, uids)
            for k,v in pairs(clientResult) do
                if uInfos[k] then
                    uInfos[k] = json.decode(uInfos[k])
                    table.insert(clientResult[k], uInfos[k][1])
                    table.insert(clientResult[k], uInfos[k][2])
                end
            end
        end

        if rank  then
            local rank = rank + 1
            response.data[aname].rank = rank
        end
        response.data[aname].point = mUseractive.info[aname].l
        response.data[aname].clientReward = clientResult
        response.ret = 0
        response.msg = "Success"

    elseif action == "getRankReward" then
        local redis = getRedis()
        local rank = redis:zrevrank(rankKey,uid)
        if not rank  then
            response.ret = -1981
            return response
        end
        local rank = rank + 1
        local reward = {}
        local rankCfg = activeCfg.serverreward.rankReward
        for _, v in pairs(rankCfg) do
            if rank >= v[1][1] and rank <= v[1][2] then
                reward = v[2]
            end
        end
        if not next(reward) then
            response.ret = -1981
            return response
        end

        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = 0
        end
        if mUseractive.info[aname].m == 1 then
            response.ret = -401
            return response
        end
        mUseractive.info[aname].m = 1

        local mTroop = uobjs.getModel('troops')
        local maxTroops = mTroop.getMaxBattleTroops()
        local clientRankReward = {}
        for i,v in pairs(reward) do
            local tmpPrefix, tmpType = serverToClient(i)
            local tmpNums = math.ceil(maxTroops * v)
            table.insert(clientRankReward, {tmpPrefix, tmpType, tmpNums})
            reward[i] = tmpNums
        end
        response.data[aname].clientRankReward = clientRankReward
        if not takeReward(uid, reward) then
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    end

    return response
end

