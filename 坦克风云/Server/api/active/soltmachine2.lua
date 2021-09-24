--
-- 小日本坦克拉吧
-- User: luoning
-- Date: 14-9-9
-- Time: 下午6:07
--

function api_active_soltmachine2(request)

    -- 活动名称，莫斯科赌局
    local aname = 'slotMachine2'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    --抽奖次数1,10
    local num = tonumber(request.params.num) or 1
    --上一次免费抽奖的12点
    local oldWeelTs = 0
    --抽奖次数
    local freeCounts = 0

    --是否免费0为免费,1为收费
    local free = request.params.free

    if uid == nil or free == nil  then
        response.ret = -102
        return response
    end
    --免费只能抽取一倍
    if free == 0 or num < 1 then
        num = 1
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

    local activeCfg =  getConfig("active." .. aname )
    --免费次数
    local maxFree = activeCfg.free
    --验证是否可以抽奖
    local weelTs = getWeeTs()

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

    --得到奖励
    local getReward = function (cfgServer, num)
        setRandSeed()
        local randTank = {rand(1, 4), rand(1, 4), rand(1, 4) }
        local randResult = {}
        local rewardResult = {server = {}, client = {}, show = randTank}

        for _, v in pairs(randTank) do
            if not randResult[v] then
                randResult[v] = 1
            else
                randResult[v] = randResult[v] + 1
            end
        end

        for i, v in pairs(randResult) do
            for tankType, tankNum in pairs(cfgServer[v][i]) do
                rewardResult['server'][tankType] = tankNum * num
            end
            table.insert(rewardResult.client, {i, v, num})
        end
        return rewardResult
    end

    --坦克数量
    local totalReward = getReward(activeCfg.serverreward, num)
    --增加坦克
    if not takeReward(uid, totalReward.server) then
        return response
    end

    --免费刷新时间和免费次数
    if free == 0 then
        mUseractive.info[aname].t = weelTs
        mUseractive.info[aname].v = freeCounts + 1
    end

    mUseractive.info[aname].ls = totalReward.show
    mUseractive.info[aname].num = num
    mUseractive.info[aname].free = free
    --记录金币消耗
    if free == 1 then
        regActionLogs(uid,1,{action=34,item="",value=costGem,params={buyNum=num,hasNum=totalReward.client}})
    end

    processEventsBeforeSave()
    mTroops = uobjs.getModel('troops')
    if uobjs.save() then
        if mTroops then
            response.data.troops = mTroops.toArray(true)
        end

        --response.data[aname].active = mUseractive.info[aname]
        --response.data[aname].reward = totalReward.client
        response.data[aname].show = totalReward.show
        response.data[aname].free = free
        response.data[aname].num = num

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end

    return response

end

