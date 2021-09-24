--
-- 改造计划
-- User: luoning
-- Date: 14-8-25
-- Time: 下午5:57
--
function api_active_refitplant99(request)

    -- 活动名称，莫斯科赌局
    local aname = 'refitPlanT99'

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
    local free = request.params.free

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local getReward = function(maxVate, addVate, bigPoolReward, smallPoolReward, userRand, defaultRand, playTime)
        --返回抽奖结果
        local defaultData = {server={}, client={} }
        --真实的抽奖概率
        if not userRand then
            userRand = defaultRand
        end
        local realRate = userRand
        --是否可以增加概率
        local ifAddVate = false
        --十个连抽享受增加概率
        if playTime == 10 then
            ifAddVate = true
        end
        --格式化数据
        local formatData = function(data, defaultData, index, rewardType)
            if type(defaultData) ~= "table" then
                defaultData = {server={}, client={}}
            end
            for type, num in pairs(data) do
                if not defaultData.server[type] then
                    defaultData.server[type] = num
                else
                    defaultData.server[type] = defaultData.server[type] + num
                end
                local tmpData = type:split("_")
                local tmpType = tmpData[2]
                local tmpPrefix = string.sub(type, 1, 1)
                if tmpPrefix == 't' then tmpPrefix = 'o' end
                table.insert(defaultData.client, {p=tmpPrefix, t=tmpType, n=num, i = index, r = rewardType})
            end
            return defaultData
        end
        --是否抽到大奖
        local bigFlag = false
        for i=1, playTime do
            setRandSeed()
            local randTime = rand(0, 100)
            --假如抽到大奖重置概率
            if bigFlag and playTime == 10 then
                realRate = defaultRand
            end
            local tmpRate = defaultRand
            if playTime == 10 then
                tmpRate = realRate
            end
            --用户抽奖
            if randTime <= tmpRate then
            --if false then
                bigFlag = true
                defaultData = formatData(getRewardByPool(bigPoolReward), defaultData, i, 1)
            else
                defaultData = formatData(getRewardByPool(smallPoolReward), defaultData, i, 0)
            end
        end
        --增加下次抽奖的概率
        if (not bigFlag) and ifAddVate and ((realRate + addVate) <= maxVate) then
            realRate = realRate + addVate
        end
        --抽到大奖后概率值改为默认
        if bigFlag and playTime == 10 then
            realRate = defaultRand
        end
        --前段显示倍数
        local userVate
        if ifAddVate or bigFlag then
            userVate = ((realRate - defaultRand) / addVate) + 1
        end
        
        return defaultData.server, defaultData.client, userVate, bigFlag
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

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg )

    if action == 'getReward' then

        num = tonumber(num)
        if free == nil or num == nil then
            response.ret = -102
            return response
        end
        --免费只能抽取一倍
        if free == 0 or num < 1 then
            num = 1
        end
        --免费次数
        local maxFree = activeCfg.free
        --验证是否可以抽奖
        local weelTs = getWeeTs()
        local oldWeelTs = 0
        --免费抽奖次数
        local freeCounts = 0
        if mUseractive.info[aname].t then
            oldWeelTs = mUseractive.info[aname].t
        end
        --初始化免费抽奖次数
        if oldWeelTs < weelTs then
            mUseractive.info[aname].v = 0
            mUseractive.info[aname].t = weelTs
        end
        freeCounts = mUseractive.info[aname].v
        --验证是否可抽奖
        if (freeCounts >= maxFree and free == 0) --免费
        or (freeCounts < maxFree and free == 1) --付费
        then
            response.ret = -102
            return response
        end

        --消耗的金币
        local payCostNum = num == 10 and activeCfg.mulc or 1
        local costGem = free == 1 and payCostNum * activeCfg.cost or 0
        --用户金币是否够用
        if free == 1 then
            if costGem < activeCfg.cost or not mUserinfo.useGem(costGem) then
                response.ret = -109
                return response
            end
        end
        --初始化概率等级
        if not mUseractive.info[aname].ls then
            mUseractive.info[aname].ls = 1
        end
        local serverAward, clientAward, userVate, bigFlag = getReward(
            activeCfg.serverreward.maxVate, activeCfg.serverreward.addVate,
            activeCfg.serverreward.bigPool, activeCfg.serverreward.smallPool,
            (mUseractive.info[aname].ls - 1) * activeCfg.serverreward.addVate + activeCfg.serverreward.bigRate,
            activeCfg.serverreward.bigRate,
            num)
        --记录用户档次
        if userVate then
            mUseractive.info[aname].ls = userVate
        end
        
        -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','refitPlanT99',num)
           
            response.data[aname].hReward = hClientReward
            for k,v in pairs(hReward) do
                serverAward[k] =(serverAward[k] or 0) + v
            end
        end

        -- 最近抽奖记录
        mUseractive.info[aname].rb = mUseractive.info[aname].rb or {}
        table.insert(mUseractive.info[aname].rb, 1, {formatReward(serverAward), getClientTs(), bigFlag, num})
        -- 删除多余的最近抽奖信息
        local difNum = #mUseractive.info[aname].rb - 20
        if difNum > 0 then
            for _=1,difNum do
                table.remove(mUseractive.info[aname].rb)
            end
        end
        
        --记录日志
        if free == 1 then
            regActionLogs(uid,1,{action=39,item="",value=costGem,params={buyNum=num,hasNum=clientAward}})
        end
        --增加坦克
        if not takeReward(uid, serverAward) then
            return response
        end
        --免费刷新时间和免费次数
        if free == 0 then
            mUseractive.info[aname].t = weelTs
            mUseractive.info[aname].v = freeCounts + 1
        end

        if uobjs.save() then
            response.data[aname].clientReward = clientAward
            response.data[aname].rb = mUseractive.info[aname].rb 
            response.data[aname].ls = mUseractive.info[aname].ls
            response.data[aname].t = mUseractive.info[aname].t
            response.ret = 0
            response.msg = 'Success'
        end

    elseif action == 'upgrade' then

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
