-- 莫斯科赌局
-- action 1为抽奖 2为合成坦克（黑鹰/T90）
-- part 合成材料--碎片类型 1为黑鹰，2为T90
-- num 抽奖次数，默认为1，期忘值10
-- 消耗碎片合成坦克，比例为2：1
-- 每日免费抽奖一次，凌晨刷新，只提供金币抽奖
function api_active_moscowgambling(request)
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
    local aname = 'moscowGambling'

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
    local activeCfg = getConfig("active")
    activeCfg = activeCfg[aname]

    if action == 1 then
        local gemCost = num * activeCfg.data.gemCost    
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
            
            reward = formatReward(reward)
        end
        
        -- 按是否免费分别记录抽奖次数
        if isfree then
            mUseractive.info[aname].d.fn = (mUseractive.info[aname].d.fn or 0) + num
        else
            mUseractive.info[aname].d.n = (mUseractive.info[aname].d.n or 0) + num
            regActionLogs(uid,1,{action=24,item="",value=gemCost,params={buyNum=num,reward=reward}})
        end

    elseif action == 2 then       
        part = part and "part" .. part 
        local tankId

        if part == "part1" then 
            tankId = "a10053" 
        elseif part == "part2" then
            tankId = "a10043"
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
    else
        return response
    end

    processEventsBeforeSave()

    if uobjs.save() then        
        if mTroops then
            response.data.troops = mTroops.toArray(true)   
        end

        response.data.useractive = mUseractive.toArray(true)
        response.data.reward = reward

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
