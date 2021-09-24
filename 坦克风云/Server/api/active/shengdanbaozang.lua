--
-- 圣诞宝藏
-- User: luoning
-- Date: 14-12-1
-- Time: 下午2:57
--

function api_active_shengdanbaozang(request)

    local aname = 'shengdanbaozang'

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

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
    if not mUseractive.info[aname].mm then
        mUseractive.info[aname].mm = {mm_m1=0}
    end
    if not mUseractive.info[aname].fc then
        mUseractive.info[aname].fc = 0
    end

    local serverToClient = function(type)
        local tmpData = type:split("_")
        local tmpType = tmpData[2]
        local tmpPrefix = string.sub(type, 1, 1)
        --if tmpPrefix == 't' then tmpPrefix = 'o' end
        --if tmpPrefix == 'a' then tmpPrefix = 'e' end
        
        local format = getClientRewardType()
        return format[tmpData[1]], tmpType
    end

    --抽奖
    if action == "rand" then

        local num = tonumber(request.params.num) or 1
        local category = request.params.category

        --获取抽奖列表
        local redis = getRedis()
        local rewardlist = redis:hget(redisKey, uid)
        if rewardlist then
            rewardlist = json.decode(rewardlist)
        end

        if (not rewardlist or type(rewardlist) ~= "table" or not next(rewardlist)
           or mUseractive.info[aname].v == 0)
           --只有数据单次抽奖的时候重置数据
           and category == 1
        then

            local big = {}
            local small = {}
            local tmpReward = getRewardByPool(activeCfg.serverreward.bigPool, true)
            for _,v in pairs(tmpReward) do
                table.insert(big, v)
            end
            local tmpReward = getRewardByPool(activeCfg.serverreward.smallPool,true)
            for _,v in pairs(tmpReward) do
                table.insert(small, v)
            end
            --{"大奖","小奖",已经抽取的奖励}
            rewardlist = {small, big, {{},{},{},{},{},{}}}
        end

        local gemCost = 0
        local costFlag = true
        --是否需要扣除金币
        local categoryFlag = true
        local weelTs = getWeeTs()
        if not mUseractive.info[aname].p then
            mUseractive.info[aname].p = 0
        end

        if category == 1 and (mUseractive.info[aname].t < weelTs and mUseractive.info[aname].fc == 0) then
            costFlag = false
        end

        --1, 一次抽取
        if category == 1 then

            if mUseractive.info[aname].p == 0 then
                response.ret = -1981
                return response
            end

            if not costFlag then
                mUseractive.info[aname].t = weelTs
            end

            mUseractive.info[aname].fc=0
            categoryFlag = false
            gemCost = activeCfg.cost
            if #(rewardlist[3][num]) >= 2 then
                response.ret = -1981
                return response
            end

            --抽取到的奖励
            local goodReward = {}
            mUseractive.info[aname].v = mUseractive.info[aname].v + 1
            if mUseractive.info[aname].v < activeCfg.serverreward.insertlocation then
                setRandSeed()
                local randNum = rand(1, #rewardlist[1])
                goodReward = rewardlist[1][randNum]
                table.remove(rewardlist[1], randNum)
            else
                setRandSeed()
                for i,v in pairs(rewardlist[2]) do
                    table.insert(rewardlist[1], v)
                end
                rewardlist[2] = {}
                local randNum = rand(1, #rewardlist[1])
                goodReward = rewardlist[1][randNum]
                table.remove(rewardlist[1], randNum)
            end

            rewardlist[3][num][1] = goodReward
            rewardlist[3][num][2] = 1
            for i,v in pairs(goodReward) do
                if i ~= 'mm_m1' then
                    if not takeReward(uid, {[i]=v}) then
                        return response
                    end
                else
                    mUseractive.info[aname].mm.mm_m1 = mUseractive.info[aname].mm.mm_m1 + v
                end
            end

            --重新填充位置
            local nullLocation = {}
            for i,v in pairs(rewardlist[3]) do
                if #v < 2 then
                    table.insert(nullLocation, i)
                end
            end
            --剩下的道具奖励
            local des = {}
            if next(rewardlist[1]) then
                for i,v in pairs(rewardlist[1]) do
                    table.insert(des, v)
                end
            end
            if next(rewardlist[2]) then
                for i,v in pairs(rewardlist[2]) do
                    table.insert(des, v)
                end
            end
            for i,v in pairs(des) do
                rewardlist[3][nullLocation[i]] = {v}
            end

            mUseractive.info[aname].p = 0

            if mUseractive.info[aname].v == 4 then
                mUseractive.info[aname].v = 0
            end

            local clientReward = {}
            local randlist = {}
            local randlocation = {}
            for i,v in pairs(rewardlist[3]) do
                local tmpReward = {}
                for type,num in pairs(v[1]) do
                    if type ~= "mm_m1" then
                        local tmpPrefix,tmpType = serverToClient(type)
                        table.insert(tmpReward, {tmpPrefix, tmpType, num})
                    else
                        table.insert(tmpReward, {"mm", "m1", num})
                    end
                end
                if v[2] then
                    table.insert(tmpReward, 1)
                else
                    table.insert(randlist, tmpReward)
                    table.insert(randlocation, i)
                end
                table.insert(clientReward, tmpReward)
            end

            if next(randlocation) then
                for _,v in pairs(randlocation) do
                    setRandSeed()
                    local tmpRand = rand(1,#randlist)
                    local info = table.remove(randlist, tmpRand)
                    clientReward[v] = info
                end
            end

            response.data[aname].clientReward = clientReward
            response.data[aname].pos = {num}
            redis:hset(redisKey, uid, json.encode(rewardlist))
            redis:expireat(redisKey, mUseractive.info[aname].et)

        --2, 全部挖掘
        elseif category == 2 then

            gemCost = activeCfg.allCost
            local ssReward = {}
            local pos = {}
            for i,v in pairs(rewardlist[3]) do
                if not v[2] then
                    for type,num in pairs(v[1]) do
                        if type == "mm_m1" then
                            mUseractive.info[aname].mm.mm_m1 = mUseractive.info[aname].mm.mm_m1 + num
                        else
                            if not ssReward[type] then
                                ssReward[type] = num
                            else
                                ssReward[type] = ssReward[type] + num
                            end
                        end
                    end
                    rewardlist[3][i][2] = 1
                    table.insert(pos, i)
                end
            end

            if not takeReward(uid, ssReward) then
                return response
            end

            response.data[aname].pos = pos

            local clientReward = {}
            for i,v in pairs(rewardlist[3]) do
                local tmpReward = {}
                for type,num in pairs(v[1]) do
                    if type ~= "mm_m1" then
                        local tmpPrefix,tmpType = serverToClient(type)
                        table.insert(tmpReward, {tmpPrefix, tmpType, num})
                    else
                        table.insert(tmpReward, {"mm", "m1", num})
                    end
                end
                if v[2] then
                    table.insert(tmpReward, 1)
                end
                table.insert(clientReward, tmpReward)
            end

            redis:hdel(redisKey,uid)
            response.data[aname].clientReward = clientReward
            mUseractive.info[aname].v = 0

        else
            return response
        end

        --用户金币是否够用
        if costFlag then
            if categoryFlag and (gemCost < activeCfg.cost or not mUserinfo.useGem(gemCost)) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=51,item="",value=gemCost,params={reward=response.data[aname].clientReward,pos=response.data[aname].pos}})
        end

        -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local rnum=1
            if category==2 then
                rnum=10
            end
            local hReward,hClientReward = harVerGifts('active','shengdanbaozang',rnum)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
           
            response.data[aname].hReward = hClientReward
        end

    --获取列表
    elseif action == "list" then

        local redis = getRedis()
        local info = {}
        if mUseractive.info[aname].v ~= 0 then
            info = redis:hget(redisKey, uid)
            if info then
                info = json.decode(info)
                local clientReward = {}
                local randlist = {}
                local randlocation = {}
                for i,v in pairs(info[3]) do
                    local tmpReward = {}
                    for type,num in pairs(v[1]) do
                        if type ~= "mm_m1" then
                            local tmpPrefix,tmpType = serverToClient(type)
                            table.insert(tmpReward, {tmpPrefix, tmpType, num})
                        else
                            table.insert(tmpReward, {"mm", "m1", num})
                        end
                    end
                    if v[2] then
                        table.insert(tmpReward, 1)
                    else
                        table.insert(randlist, tmpReward)
                        table.insert(randlocation, i)
                    end
                    table.insert(clientReward, tmpReward)
                end

                if next(randlocation) then
                    for _,v in pairs(randlocation) do
                        setRandSeed()
                        local tmpRand = rand(1,#randlist)
                        local info = table.remove(randlist, tmpRand)
                        clientReward[v] = info
                    end
                end
                info = clientReward
            end
        end
        response.data[aname].clientReward = type(info) == "table" and info or {}

    --单次抽奖花费记录
    elseif action == "pay" then

        if not mUseractive.info[aname].p then
            mUseractive.info[aname].p = 0
        end

        if mUseractive.info[aname].p == 1 then
            return response
        end
        local weelTs = getWeeTs()

        mUseractive.info[aname].p = 1
        local gemCost = activeCfg.cost
        local gemCostFlag = true
        if mUseractive.info[aname].t < weelTs then
            mUseractive.info[aname].fc = 0
            gemCostFlag = false
        else
            mUseractive.info[aname].fc = 1
        end

        if gemCostFlag and (gemCost < activeCfg.cost or not mUserinfo.useGem(gemCost)) then
            response.ret = -109
            return response
        end

    --商店
    elseif action == "shop" then

        local item = request.params.item
        local shopCfg = activeCfg.shopItem
        local cfgItem = tonumber(string.sub(item, 2))
        if not shopCfg[cfgItem] then
            response.ret = -102
            return response
        end

        if not mUseractive.info[aname].l then
            mUseractive.info[aname].l = {}
        end

        if not mUseractive.info[aname].l[item] then
            mUseractive.info[aname].l[item] = 0
        end

        if mUseractive.info[aname].l[item] >= shopCfg[cfgItem].buynum then
            return response
        end

        local costMM = shopCfg[cfgItem].price
        local reward = shopCfg[cfgItem].serverReward
        local mm = type(mUseractive.info[aname].mm) == 'table' and mUseractive.info[aname].mm or {}

        for type, num in pairs(costMM) do
            if not mm[type] or mm[type] < num then
                return response
            end
            mm[type] = mm[type] - num
        end
        mUseractive.info[aname].mm = mm
        mUseractive.info[aname].l[item] = mUseractive.info[aname].l[item] + 1
        if not takeReward(uid, reward) then
            return response
        end

    --重置数据
    elseif action == "refresh" then

        local redis = getRedis()
        redis:hdel(redisKey, uid)
        mUseractive.info[aname].v = 0
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

