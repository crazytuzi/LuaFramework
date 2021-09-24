--
-- jidongbudui
-- User: luoning
-- Date: 14-11-12
-- Time: 下午4:24
--
function api_active_jidongbudui(request)

    -- 活动名称
    local aname = 'jidongbudui'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil then
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
    local addMm = function(old, reward)
        if type(old) ~= 'table' then
            old = {}
        end
        for type, num in pairs(reward) do
            if not old[type] then
                old[type] = 0
            end
            old[type] = old[type] + num
        end
        return old
    end

    local redis = getRedis()
    local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
    local allCount = redis:get(redisKey)
    allCount = tonumber(allCount) or 0
    local validCount = activeCfg.serverreward.trNums - allCount
    validCount = validCount > 0 and validCount or 0
    response.data[aname].validCount = validCount
    if not mUseractive.info[aname].mm then
        mUseractive.info[aname].mm = {mm_m1=0}
    end

    if action == "rank" then

        local num = 1
        local costGem = num * activeCfg.cost
        local costFlag = true
        local weelTs = getWeeTs()
        if mUseractive.info[aname].t < weelTs then
            costFlag = false
        end

        if costFlag and (costGem < activeCfg.cost or not mUserinfo.useGem(costGem)) then
            response.ret = -109
            return response
        end

        local pool = activeCfg.serverreward.pool
        local rankItem = function(pool, num)
            local reward = {}
            local mmItem = {}
            local clientReward = {}
            for i=1, num do
                local poolReward = getRewardByPool(pool)
                for type, num in pairs(poolReward) do
                    local tTable = type:split('_')
                    if tTable[1] == 'mm' then
                        if not mmItem[type] then
                            mmItem[type] = 0
                        end
                        mmItem[type] = mmItem[type] + num
                        table.insert(clientReward, {tTable[1],type,num})
                    else
                        if not reward[type] then
                            reward[type] = 0
                        end
                        reward[type] = reward[type] + num
                        local tmpPrefix = string.sub(type, 1, 1)
                        if tmpPrefix == 't' then tmpPrefix = 'o' end
                        if tmpPrefix == 'a' then tmpPrefix = 'e' end
                        table.insert(clientReward, {tmpPrefix,tTable[2],num})
                    end
                end
            end
            return reward, mmItem, clientReward
        end

        local reward, mmItem, clientReward = rankItem(pool, num)
        if next(reward) and not takeReward(uid, reward) then
            return response
        end
        if costFlag then
            regActionLogs(uid,1,{action=46,item="",value=costGem,params={buyNum=num,reward=reward,mmItem=mmItem}})
        end

        if next(mmItem) then
            mUseractive.info[aname].mm = addMm(mUseractive.info[aname].mm, mmItem)
        end
        mUseractive.info[aname].t = weelTs
        response.data[aname].clientReward = clientReward

        -- 和谐版
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','jidongbudui',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data[aname].hReward=hClientReward
        end           

    --兑换坦克
    elseif action == "combine" then

        local num = tonumber(request.params.num) or 0
        local aTankNum = 0
        local aTankType = 0
        for i, v in pairs(activeCfg.reward.gettank) do
            aTankNum = v
            aTankType = i
        end
        local needSpice = activeCfg.reward.needPartNum * num
        if num <= 0 or validCount <= 0
                or (mUseractive.info[aname].v + aTankNum * num) > activeCfg.limitNums
                or (mUseractive.info[aname].mm.mm_m1 < needSpice)
        then
            response.ret = -1981
            return response
        end
        local mTroops = uobjs.getModel('troops')
        if not mTroops.incrTanks(aTankType,aTankNum * num) then
            return response
        end
        mUseractive.info[aname].v = mUseractive.info[aname].v + aTankNum * num
        mUseractive.info[aname].mm.mm_m1 = mUseractive.info[aname].mm.mm_m1 - needSpice
        local allCount = tonumber(redis:incrby(redisKey, aTankNum * num))
        redis:expireat(redisKey, mUseractive.info[aname].et)
        response.data[aname].validCount = activeCfg.serverreward.trNums - allCount
        local msg = {
            sender = "",
            reciver = "",
            channel = 1,
            sendername = "",
            recivername = "",
            content = {
                type = 100,
                ts = getClientTs(),
                contentType = 4,
                params = {
                    category = "num",
                    data = response.data[aname].validCount,
                },
            },
            type = "chat",
        }
        sendMessage(msg)
    --兑换其他道具
    elseif action == "other"  then

        local index = tonumber(request.params.index) or 0
        if index <= 0 then
            response.ret = -1981
            return response
        end

        if validCount > 0 then
            if  mUseractive.info[aname].v < activeCfg.limitNums then
                response.ret = -1981
                return response
            end
        end

        local rewardType = activeCfg.serverreward.otherReward[index]
        if not rewardType then
            response.ret = -1981
            return response
        end
        local needSpice = rewardType.num
        if mUseractive.info[aname].mm.mm_m1 < needSpice then
            response.ret = -1981
            return response
        end
        for i,v in pairs(rewardType) do
            if i ~= 'num' then
                if not takeReward(uid, {[i]=v}) then
                    return response
                end
            end
        end

        mUseractive.info[aname].mm.mm_m1 = mUseractive.info[aname].mm.mm_m1 - needSpice

    --获取坦克全服总数
    elseif action == "getTotal" then
        local placeKey = getActiveCacheKey(aname, "def.place", mUseractive.info[aname].st)
        local res = redis:lrange(placeKey, 0, 39)
        if type(res) == "table" and next(res) then
            for i,v in pairs(res) do
                res[i] = json.decode(v)
            end
        end
        response.data[aname].place = type(res) == 'table' and res or {}
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

