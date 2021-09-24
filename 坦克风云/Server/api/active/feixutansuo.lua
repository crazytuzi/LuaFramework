--
-- 废墟探索
-- User: luoning
-- Date: 14-11-19
-- Time: 下午4:31
--
function api_active_feixutansuo(request)

    local aname = 'feixutansuo'

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

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local harnum=1

    if action == "getreward" then

        local nums = tonumber(num) or 0
        local weelTs = getWeeTs()
        if (mUseractive.info[aname].t < weelTs and nums > 0) or (mUseractive.info[aname].t >= weelTs and nums <= 0) then
            response.ret = -1981
            return response
        end
        local costGems, times, getCostFlag, rewardType = 0, 0, false, 0
        if not mUseractive.info[aname].l then
            mUseractive.info[aname].l = 1
        end
        --重置抽奖次数
        if not mUseractive.info[aname].f then
            mUseractive.info[aname].f = 0
        end
        if mUseractive.info[aname].t < weelTs then
            mUseractive.info[aname].f = 0
        end

        --获取消耗的金币
        local randFlag = true
        if nums <= 0 then

            costGems = 0
            times = 1
            rewardType = mUseractive.info[aname].l
            mUseractive.info[aname].t = weelTs
            harnum=1

        elseif nums > 10 then
            randFlag = false
            local vip = mUserinfo.vip
            local vipTimes = 0
            if vip <= 0 then
                return response
            end
            for _,v in pairs(activeCfg.vipCost) do
                if v[1][1] <= vip and vip <= v[1][2] then
                    rewardType = v[3]
                    costGems = v[2]
                    vipTimes = v[4]
                    getCostFlag = true
                    times = 1
                    break
                end
            end
            if mUseractive.info[aname].f >= vipTimes then
                response.ret = -1981
                return response
            end
            mUseractive.info[aname].f = mUseractive.info[aname].f + 1
            harnum=99
        else

            getCostFlag = true
            times = nums
            if nums == 1 then
                costGems = activeCfg.cost
            else
                costGems = activeCfg.cost * activeCfg.mulc
                times = activeCfg.mul
            end
            rewardType = mUseractive.info[aname].l
            harnum=nums
        end

        local pool = activeCfg.serverreward.pool[rewardType]
        local clientReward = {}
        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end
        for i=1, times do
            local reward = getRewardByPool(pool)
            if not takeReward(uid, reward) then
                return response
            end

            for i,v in pairs(reward) do
                local tmpPrefix, tmpType = serverToClient(i)
                table.insert(clientReward, {tmpPrefix, tmpType, v})
            end
            if randFlag then
                local vate = activeCfg.serverreward.vate[mUseractive.info[aname].l]
                setRandSeed()
                local randNum = rand(1,100)
                if randNum <= vate then
                    mUseractive.info[aname].l = mUseractive.info[aname].l + 1
                    if #(activeCfg.serverreward.pool) < mUseractive.info[aname].l then
                        mUseractive.info[aname].l = #(activeCfg.serverreward.pool)
                    end
                else
                    mUseractive.info[aname].l = 1
                end
                pool = activeCfg.serverreward.pool[mUseractive.info[aname].l]
            end
        end

        local cpClientReward=copyTable(clientReward)
        response.data[aname].clientReward = cpClientReward

        if getCostFlag then
            if costGems < activeCfg.cost or not mUserinfo.useGem(costGems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=47,item="",value=costGems,params={buyNum=nums,hasNum=clientReward}})
        end

        response.data[aname].location = mUseractive.info[aname].l
        local redis = getRedis()
        local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
        local list = redis:hget(redisKey, uid)
        list = json.decode(list)
        if not list then list = {} end

     -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward
            if harnum>10 then
                 hReward,hClientReward = harVerGifts('active','feixutansuo',harnum,true)
            else
                 hReward,hClientReward = harVerGifts('active','feixutansuo',harnum)
            end
            
            for i,v in pairs(hReward) do
                local tmpPrefix, tmpType = serverToClient(i)
                table.insert(clientReward, {tmpPrefix, tmpType, v})
            end            
            
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data[aname].hReward = hClientReward
        end

        for _,v in pairs(clientReward) do
            table.insert(list, v)
        end
        local flag = true
        while flag do
            if #list > 20 then
                table.remove(list, 1)
            end
            if #list <= 20 then
                flag = false
            end
        end
        redis:hset(redisKey, uid, json.encode(list))
        redis:expireat(redisKey, mUseractive.info[aname].et)

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
            response.data[aname].list = list
        end

    elseif action == "getlist" then

        local redis = getRedis()
        local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
        local list = redis:hget(redisKey, uid)
        local result = {}
        if not list then
            result = {}
        else
            result = json.decode(list)
        end
        response.data[aname].list = type(result) == "table" and result or {}
        response.ret = 0
        response.msg = "Success"
        return response

    elseif action == "upgrade" then

        local aid = request.params.aid
        local nums = tonumber(num)
        local cfg = activeCfg.consume[aid]
        if nums <= 0 or not cfg then
            response.ret = -102
            return response
        end

        -- 刷新队列
        mTroop.upgradeupdate()

        local bTankConsume = cfg.upgradeShipConsume
        if next(bTankConsume) then
            -- 升级需要消耗的坦克数
            local iTanks = bTankConsume[2] * nums
            if not mTroop.troops[bTankConsume[1]]
                    or iTanks > mTroop.troops[bTankConsume[1]]
                    or not mTroop.consumeTanks(bTankConsume[1],iTanks) then
                response.ret = -115
                return response
            end
        end

        -- 改装需要的道具
        local bPropConsume = cfg.upgradePropConsume
        if type(bPropConsume) == 'table' and next(bPropConsume) then
            local mBag = uobjs.getModel('bag')

            for _,v in ipairs(bPropConsume) do
                local tmpNum = v[2] * nums
                if not mBag.use(v[1],tmpNum) then
                    response.ret = -1996
                    return response
                end
            end
            response.data.bag = mBag.toArray(true)
        end

        local bRes = {}
        bRes.r1 = nums * cfg.upgradeMetalConsume
        bRes.r2 = nums * cfg.upgradeOilConsume
        bRes.r3 = nums * cfg.upgradeSiliconConsume
        bRes.r4 = nums * cfg.upgradeUraniumConsume
        bRes.gold = nums * cfg.upgradeMoneyConsume

        if not mUserinfo.useResource(bRes) then
            response.ret = -107
            return response
        end

        mTroop.incrTanks(aid,nums)

        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
            response.data.userinfo = mUserinfo.toArray(true)
            response.data.troops = mTroop.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -1
            response.msg = 'save failed'
        end
    end

    return response
end

