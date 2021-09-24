--
-- 摧枯拉朽活动
-- User: luoning
-- Date: 14-11-10
-- Time: 下午4:27
--
function api_active_cuikulaxiu(request)

    -- 活动名称，莫斯科赌局
    local aname = 'cuikulaxiu'

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

    local flag = false
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local redis = getRedis()
    local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
    local redisInfoKey = getActiveCacheKey(aname, "def.info", mUseractive.info[aname].st)

    if action == "getRankList" then

        flag = true
        local result = redis:zrevrange(redisKey,0,9,'withscores')
        local clientResult = {}
        local uids = {}
        local merank = 0
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
        local rank = redis:zrevrank(redisKey,uid)
        if rank  then
            local rank = rank + 1
            response.data[aname].rank = rank
        end
        response.data[aname].point = mUseractive.info[aname].v
        response.data[aname].clientReward = clientResult

    --领取军功奖励
    elseif action == "getPointReward" then

        if item == nil then
            response.ret = -102
            return response
        end
        flag = true
        item = tonumber(item)
        local rankCfg = activeCfg.serverreward.pointReward
        if not rankCfg[item] then return response end
        if not mUseractive.info[aname].p then
            mUseractive.info[aname].p = {}
        end
        if table.contains(mUseractive.info[aname].p, item) then
            response.ret = -402
            return response
        end
        if mUseractive.info[aname].v < rankCfg[item][1] then
            response.ret = -1981
            return response
        end
        table.insert(mUseractive.info[aname].p, item)
        if not takeReward(uid, rankCfg[item][2]) then
            return response
        end


    elseif action == "getRankReward" then

        flag = true
        local rank = redis:zrevrank(redisKey,uid)
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


        if not mUseractive.info[aname].l then
            mUseractive.info[aname].l = 0
        end
        if mUseractive.info[aname].l == 1 then
            response.ret = -401
            return response
        end
        mUseractive.info[aname].l = 1

        if not takeReward(uid, reward) then
            return response
        end
    end

    if flag and uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

