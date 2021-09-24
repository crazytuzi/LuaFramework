-- 火线名将


function api_active_huoxianmingjianggai(request)
    local aname = 'huoxianmingjianggai'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local method = tonumber(request.params.method) or 0
    local action = request.params.action
    

    if uid == nil or  action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
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

    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].v = 0
    end

    if type(mUseractive.info[aname].s)~='table' then mUseractive.info[aname].s={0,0,0,0} end
    if not mUseractive.info[aname].l then mUseractive.info[aname].l=0 end

    if action == "rand" then

        if method == nil then
            return response
        end

        local gems=activeCfg.cost

        local redis =getRedis()
        local redkey ="zid."..getZoneId().."huoxianmingjianggai."..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)
        if type (data)~="table" then data={}  end
        local ts = getClientTs()

        local function search(cfg,num,reward,currN,report,heros,star)

            report = report or {}
            heros  = heros  or {}
            star   = star   or 0
            currN = (currN or 0) + 1

            local result = getRewardByPool(cfg.pool)
            reward = reward or {}
            local tmpScore = 0
            local tmpResult = {}
            for k, v in pairs(result or {}) do
                local award = k:split('_')
                tmpScore = rand(activeCfg.scorelist[v.index][1], activeCfg.scorelist[v.index][2]) + tmpScore
                --英雄的品阶特殊处理
                if award[1]=='hero' then
                    table.insert(heros,{award[2],v.num})
                else
                    reward[k] = (reward[k] or 0) + v.num
                end
                table.insert(data,{{[k]=v.num}, ts})
                tmpResult[k] = v.num
            end
            table.insert(report,{formatReward(tmpResult), tmpScore})
            star = star + tmpScore
            if currN >= num then
                return reward,report,heros,star
            else
                return search(cfg,num,reward,currN,report,heros,star)
            end
        end

        -- ==0 是抽一次如果有免费用免费的
        local num=0
        if method==0 then
            if mUseractive.info[aname].c==0  then
                gems=0
                mUseractive.info[aname].c=1
            end
            num=1
        else
            gems=math.floor(gems*10*activeCfg.value)
            num=10
        end

        if gems >0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
        end

        local reward,report,heros,score = search(activeCfg.serverreward,num)
        mUseractive.info[aname].l = mUseractive.info[aname].l + score

        if reward  and next(reward) then
            if not takeReward(uid,reward) then
                return response
            end
        end

        --姓名，等级，战力，排名，学分
        --加入排行榜
        if mUseractive.info[aname].l >= activeCfg.scoreLimit then

            setRankInfo(mUseractive.info[aname].l, score, mUserinfo.fc)
        end

        if next(heros) then
            for k,v in pairs(heros) do
                local flag =mHero.addHeroResource(v[1],v[2])
                if not flag then
                    return response
                end
            end
        end

        mUseractive.info[aname].t=ts
        regActionLogs(uid,1,{action=66,item="",value=gems,params={buyNum=num}})
        processEventsBeforeSave()
        regEventBeforeSave(uid,'e1')
        if uobjs.save() then
            if next(data) then
                if #data >30 then
                    for i=1,#data-30 do
                        table.remove(data,1)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end
            response.data[aname] =mUseractive.info[aname]
            response.data.hero =mHero.toArray(true)
            response.data.hero.report = report
            response.data.star =stars
            processEventsAfterSave()

            response.ret = 0
            response.msg = 'Success'
        end

    --获取积分奖励
    elseif action == "getScoreReward" then

        local tmpReward = {}
        for i,v in pairs(activeCfg.serverreward.scoreReward) do
            if mUseractive.info[aname].s[i] == 0 and mUseractive.info[aname].l >= v[1] then
                tmpReward[i] = v[2]
                mUseractive.info[aname].s[i] = 1
            end
        end

        if not next(tmpReward) then
            return response
        end

        for _,atmp in pairs(tmpReward) do
            if not takeReward(uid, atmp) then
                return response
            end
        end

        if uobjs.save() then
            response.msg = "Success"
            response.data.hero =mHero.toArray(true)
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
        end

    --排名奖励
    elseif action == "ranklist" then

        local redis = getRedis()
        local rank = redis:zrevrank(rankKey,uid)
        if not mUseractive.info[aname].l then
            mUseractive.info[aname].l = 0
        end
        if activeCfg.scoreLimit <= mUseractive.info[aname].l
                and not rank then
            local mTroop = uobjs.getModel('troops')
            local maxTroops = mTroop.getMaxBattleTroops()
            setRankInfo(mUseractive.info[aname].l, 0, maxTroops)
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
            if not response.data[aname] then
                response.data[aname] = {}
            end
            response.data[aname].rank = rank
        end

        response.data[aname].point = tonumber(mUseractive.info[aname].l) or 0
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