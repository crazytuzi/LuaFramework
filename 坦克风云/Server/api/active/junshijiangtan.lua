--
-- 军事讲坛活动
-- User: luoning
-- Date: 15-3-4
-- Time: 下午3:20
--
function api_active_junshijiangtan(request)

    -- 活动名称
    local aname = 'junshijiangtan'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local rankKey = getActiveCacheKey(aname, "def.rank", mUseractive.info[aname].st)
    local redisInfoKey = getActiveCacheKey(aname, "def.info", mUseractive.info[aname].st)

    --flag true 增加数据 false 检查数据
    local setRankInfo = function(score, addscore, maxTroops)
        local redis = getRedis()
        if redis:zrevrank(rankKey,uid) then
            redis:zincrby(rankKey, addscore,uid)
        else
            redis:zadd(rankKey, score, uid)
        end
        redis:hset(redisInfoKey, uid, json.encode({mUserinfo.nickname, mUserinfo.level, maxTroops}))
        redis:expireat(redisInfoKey, mUseractive.info[aname].et + 172800)
        redis:expireat(rankKey, mUseractive.info[aname].et + 172800)
    end

    --抽奖
    if action == "rand" then

        --学习的类型
        local rType = tonumber(request.params.rType) or 0
        --学习的数量
        local num = tonumber(request.params.num) or 0
        local rTypeCheck = {1,2,3 }
        local numCheck = {1,2}
        if not table.contains(rTypeCheck, rType) or not table.contains(numCheck, num) then
            response.ret = -102
            return response
        end

        --学习花费的金币
        local gemCost = activeCfg.gemcost[rType][num]
        --选择奖池
        local pool = activeCfg.serverreward.pool[rType]

        --是否免费抽奖
        local getCostFlag = true
        if rType == 2 then
            local weelTs = getWeeTs()
            if mUseractive.info[aname].v < weelTs and num == 2 then
                response.ret = -1981
                return response
            end
            --进阶2每日可以免费抽奖一次
            if mUseractive.info[aname].v < weelTs and num == 1 then
                getCostFlag = false
                mUseractive.info[aname].v = weelTs
            end
        end

        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end

        --抽奖次数
        local rewardTimes = 1
        if num == 2 then
            rewardTimes = 10
        end
        local serverreward = {}
        local clientreward = {}
        local score = 0
        setRandSeed()
        for i=1, rewardTimes do
            local reward = getRewardByPool(pool)
            for mtype,mnum in pairs(reward) do
                if not serverreward[mtype] then
                    serverreward[mtype] = mnum.num
                else
                    serverreward[mtype] = serverreward[mtype] + mnum.num
                end
                --积分值
                local tmpscore = rand(activeCfg.scorelist[rType][mnum.index][1], activeCfg.scorelist[rType][mnum.index][2])
                score = score + tmpscore
                local tmpPrefix,tmpType = serverToClient(mtype)
                table.insert(clientreward, {tmpPrefix, tmpType, mnum.num, tmpscore})
            end
        end

        --增加积分
        mUseractive.info[aname].t = mUseractive.info[aname].t + score

        --姓名，等级，战力，排名，学分
        --加入排行榜
        if mUseractive.info[aname].t >= activeCfg.scoreLimit then

            setRankInfo(mUseractive.info[aname].t, score, mUserinfo.fc)
        end

        --花费金币
        if getCostFlag then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=65,item="",value=gemCost,params={rtype=rType,num=num,reward=clientreward}})
        end

        if not takeReward(uid, serverreward) then
            return response
        end

        response.data[aname].clientReward = clientreward
        response.data[aname].nowScore = mUseractive.info[aname].t

        
        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','junshijiangtan',rewardTimes)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data[aname].hReward = hClientReward
        end        

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --排名奖励
    elseif action == "ranklist" then

        local redis = getRedis()
        local rank = redis:zrevrank(rankKey,uid)
        if activeCfg.scoreLimit <= mUseractive.info[aname].t
                and not rank then
            local mTroop = uobjs.getModel('troops')
            local maxTroops = mTroop.getMaxBattleTroops()
            setRankInfo(mUseractive.info[aname].t, 0, maxTroops)
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
                    table.insert(clientResult[k], uInfos[k][3])
                end
            end
        end

        if rank  then
            local rank = rank + 1
            response.data[aname].rank = rank
        end

        response.data[aname].point = mUseractive.info[aname].t
        response.data[aname].clientReward = clientResult
        response.ret = 0
        response.msg = "Success"

    --领取排名奖励
    elseif action == "rankReward" then

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

        --检查是否领取奖励
        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = 0
        end
        if mUseractive.info[aname].m == 1 then
            response.ret = -401
            return response
        end

        --增加奖励
        mUseractive.info[aname].m = 1
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

