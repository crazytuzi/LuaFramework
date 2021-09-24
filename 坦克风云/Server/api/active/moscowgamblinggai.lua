-- 莫斯科赌局
-- action 1为抽奖 2为合成坦克（黑鹰/T90）
-- part 合成材料--碎片类型 1为黑鹰，2为T90
-- num 抽奖次数，默认为1，期忘值10
-- 消耗碎片合成坦克，比例为2：1
-- 每日免费抽奖一次，凌晨刷新，只提供金币抽奖
function api_active_moscowgamblinggai(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action = tonumber(request.params.action)
    local part = tonumber(request.params.part)
    local num = tonumber(request.params.num) or 1

     if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，莫斯科赌局
    local aname = 'moscowGamblingGai'

    local lotterylog = {hr={},ar={},r={},n=1}

    -- 抽奖
    -- 有一定机率出实物道具，以reward格式返给前台
    -- 碎片不会作为道具出现在背包中，活动结束后，碎片会消失，记录在活动数据中
    local function lottery(mUseractive,aname,lotteryCfg,num,reward,currN)
        local result = getRewardByPool(lotteryCfg)
        currN = (currN or 0) + 1
        
        reward = reward or {}

        for k, v in pairs(result or {}) do
            if string.find(k,'props_') == 1 then
                reward[k] = (reward[k] or 0) + v
            else
                mUseractive.info[aname].t[k] = (mUseractive.info[aname].t[k] or 0) + v
                lotterylog.ar[k] = (lotterylog.ar[k] or 0)+v
            end
        end

        if currN >= num then
            return reward
        else
            return lottery(mUseractive,aname,lotteryCfg,num,reward,currN)
        end        
    end

    -- 碎片升级为坦克
    -- 消耗指定碎片，升级为黑鹰/T90，比例是2：1
    local function upgrade(mUseractive,aname,upgradePartConsume,part)
        if tonumber(mUseractive.info[aname].t[part]) and mUseractive.info[aname].t[part] >= upgradePartConsume then
            local n = math.floor(mUseractive.info[aname].t[part] / upgradePartConsume)
            local prodeceN = upgradePartConsume * n
            local odd = mUseractive.info[aname].t[part] - prodeceN
            if odd < 0 then odd = 0 end

            if prodeceN <= mUseractive.info[aname].t[part] and prodeceN > 0 then
                mUseractive.info[aname].t[part] = odd
                return math.floor(prodeceN / 2) or 0
            end           
        end

        return 0
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

    if type(mUseractive.info[aname].d) ~= 'table' then
        mUseractive.info[aname].d = {}
    end

    if type(mUseractive.info[aname].t) ~= 'table' then
        mUseractive.info[aname].t = {}
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local harCReward={}--和谐版的值
    
    if action == 1 then
        local gemCost = activeCfg.data.gemCost - tonumber(mUserinfo.vip)
        if gemCost < 28 then
            gemCost = 28
        end
        if num > 1 then
            gemCost =  9 * gemCost - 14
        end

        local lastTs = mUseractive.info[aname].d.ts or 0

        local isfree = false
        if num == 1 and weeTs > lastTs then
            -- 更新最后一次抽奖时间
            mUseractive.info[aname].d.ts = weeTs
            isfree = true            
        end

        if not isfree then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
        end
        
        reward = lottery(mUseractive,aname,activeCfg.data.pool,num)
        
        if reward  and next(reward) then
            if not takeReward(uid,reward) then
                return response
            end
            lotterylog.r=reward
            reward = formatReward(reward)

        end
        
        -- 按是否免费分别记录抽奖次数
        if isfree then
            mUseractive.info[aname].d.fn = (mUseractive.info[aname].d.fn or 0) + num
        else
            mUseractive.info[aname].d.n = (mUseractive.info[aname].d.n or 0) + num
            regActionLogs(uid,1,{action=24,item="",value=gemCost,params={buyNum=num,reward=reward}})
        end

        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','moscowGamblingGai', num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward
            lotterylog.hr = hClientReward
        end

    elseif action == 2 then       
        part = part and "part" .. part 
        local tankId

        if part == "part1" then 
            tankId = activeCfg.data.partMap[1]
        elseif part == "part2" then
            tankId = activeCfg.data.partMap[2]
        else
            response.ret = -404
            return response 
        end

        local upgradeTankNun = upgrade(mUseractive,aname,activeCfg.data.upgradePartConsume,part)

        -- 无坦克产出，碎片不足
        if upgradeTankNun <= 0 then
            response.ret = -404
            return response
        end

        mTroops = uobjs.getModel('troops')
        mTroops.incrTanks(tankId,upgradeTankNun)
        regEventBeforeSave(uid,'e1')
    elseif action==3 then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    else
        return response
    end

    processEventsBeforeSave()

    if uobjs.save() then        
        if mTroops then
            response.data.troops = mTroops.toArray(true)   
        end

        response.data.useractive = mUseractive.toArray(true)
        if next(harCReward) then
            response.data.useractive[aname].hReward=harCReward
        end    
        response.data.reward = reward


        if action==1 then
            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatReward({[k]=v}))
                end
            end

            if next(lotterylog.ar) then
                for k,v in pairs(lotterylog.ar) do
                    table.insert(rewardlog,formatActiveReward(aname,{[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{getClientTs(),1,rewardlog,lotterylog.hr,num})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end 
        end

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
