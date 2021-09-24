--
-- 圣诞狂欢活动
-- User: luoning
-- Date: 14-12-9
-- Time: 下午3:24
--

function api_active_shengdankuanghuan(request)

    local aname = 'shengdankuanghuan'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    local mType = tonumber(request.params.mType) or 0

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active." .. aname .. "."..mUseractive.info[aname].cfg)
    if type(mUseractive.info[aname].v) ~= "table" then
        mUseractive.info[aname].v = {0,0,0,0,0,0}
    end
    --金币返利奖励
    if action == "getGoldReward" then

        if mUseractive.info[aname].v[mType] < 1 then
            response.ret = -1981
            return response
        end

        local payConfig = getConfig("pay")

        local rewardPool = getRewardByPool(activeCfg.serverreward.pool)
        local goldGems = math.floor(rewardPool[1] * payConfig[mType])
        local ret=mUserinfo.addResource({gems=goldGems})

        if not ret then
            response.ret = -403
            return response
        end

        mUseractive.info[aname].v[mType] = mUseractive.info[aname].v[mType] - 1

        if uobjs.save() then
            response.data[aname].rewardGold = goldGems
            response.data[aname].vate = rewardPool[1]
            response.ret = 0
            response.msg = "Success"
        end

    elseif action == "wholeReward" then

        local payConfig = getConfig("pay")

        local clientReward = {}
        local wholeGems = 0
        for i,v in pairs(mUseractive.info[aname].v) do
            if v >= 1 then
                for m=1, v do
                    local rewardPool = getRewardByPool(activeCfg.serverreward.pool)
                    local goldGems = math.floor(rewardPool[1] * payConfig[i])
                    table.insert(clientReward, {goldGems, rewardPool[1], i})
                    wholeGems = wholeGems + goldGems
                end
            end
        end

        if wholeGems <= 0 then
            response.ret = -1981
            return response
        end

        local ret=mUserinfo.addResource({gems=wholeGems})
        if not ret then
            response.ret = -403
            return response
        end
        mUseractive.info[aname].v = {0,0,0,0,0,0 }
        response.data[aname].clientRewardGold = clientReward

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --圣诞树领取奖励
    elseif action == "getTreeReward" then

        local redis = getRedis()
        local activeKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
        local treeNum = redis:get(activeKey)
        treeNum = tonumber(treeNum) or 0
        local rewardCfg = activeCfg.serverreward.treeReward

        if not rewardCfg[mType] then
            return response
        end

        if treeNum < rewardCfg[mType][1] then
            response.ret = -1981
            return response
        end

        if type(mUseractive.info[aname].t) ~= "table" then
            mUseractive.info[aname].t = {}
        end

        if table.contains(mUseractive.info[aname].t, mType) then
            response.ret = -401
            return response
        end

        if not takeReward(uid, rewardCfg[mType][2]) then
            return response
        end

        table.insert(mUseractive.info[aname].t, mType)

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end
    elseif action == "treeNum" then

        local redis = getRedis()
        local activeKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
        local treeNum = redis:get(activeKey)

        response.data[aname].num = tonumber(treeNum) or 0
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

