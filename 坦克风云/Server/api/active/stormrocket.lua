-- 飓风来袭
-- action 1为抽奖 2为合成坦克 3为购买碎片
-- part 合成材料，购买时只能购买自己没有的碎片
-- num 抽奖次数，默认为1，期忘值10
-- 每日免费抽奖一次，凌晨刷新，只提供金币抽奖
function api_active_stormrocket(request)
    -- 活动名称，莫斯科赌局
    local aname = 'stormrocket'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = tonumber(request.params.action)
    local num = tonumber(request.params.num) or 1
    local free = request.params.free

     if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    -- 抽奖    
    -- 碎片不会作为道具出现在背包中，活动结束后，碎片会消失，记录在活动数据中
    local function lottery(aname,lotteryCfg,num,reward,currN)
        local result = getRewardByPool(lotteryCfg)

        currN = (currN or 0) + 1        
        reward = reward or {}

        table.insert(reward,result)

        if currN >= num then return reward end

        return lottery(aname,lotteryCfg,num,reward,currN)
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

    -- 初始化数据
    if type(mUseractive.info[aname].d) ~= 'table' then
        mUseractive.info[aname].d = {}
    end

    if type(mUseractive.info[aname].t) ~= 'table' then
        mUseractive.info[aname].t = {}
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active." .. aname .. "." .. mUseractive.info[aname].cfg)
    
    local lotterylog = {hr={},r={},n=1}
    -- 抽奖
    -- 分1次抽奖和10次抽奖
    -- 抽奖后会有暴击，按vip等级额外获取碎片
    if action == 1 then
        local lastTs = mUseractive.info[aname].d.ts or 0
        local isfree

        -- 更新最后一次抽奖时间        
        if free == 1 then
            if weeTs > lastTs then
                mUseractive.info[aname].d.fn = 0
                mUseractive.info[aname].d.ts = weeTs
                -- 如果dailyFree 的值变为>1r的时候，这行代码要挪到下面去判断
                isfree = (activeCfg.reward.dailyFree - mUseractive.info[aname].d.fn) >= num
            end

            -- isfree = (activeCfg.reward.dailyFree - (mUseractive.info[aname].d.fn or 100)) >= num

            if not isfree then
                response.ret = -1981
                return response
            end

            num = 1
        end

        local gemCost = 100000000  
        if not isfree then
            if num == 1 then
                gemCost =  activeCfg.reward.gemCost   
            else
                gemCost =  activeCfg.reward.gemCost_10   
                lotterylog.n=10
            end

            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
        end

        local lotteryReward = lottery(aname,activeCfg.reward.pool,num)

        local randomNum = rand(1,100)
        local iscrit = randomNum <= activeCfg.reward.criclyChance

        reward = reward or {}
        for _,partinfo in ipairs(lotteryReward or {}) do
            if partinfo then
                local part,partNum = next(partinfo)
                if iscrit then                    
                    partinfo[part] = partNum * activeCfg.reward.vipMulti[mUserinfo.vip+1]
                    partNum = partinfo[part]
                end

                reward[part] = (reward[part] or 0) + partNum
                mUseractive.info[aname].t[part] = (mUseractive.info[aname].t[part] or 0) + partNum
            end
        end
       
       lotterylog.r = reward
        
        -- 按是否免费分别记录抽奖次数
        if isfree then
            mUseractive.info[aname].d.fn = (mUseractive.info[aname].d.fn or 0) + num
        else
            mUseractive.info[aname].d.n = (mUseractive.info[aname].d.n or 0) + num
            regActionLogs(uid,1,{
                action=35,
                item="",
                value=gemCost,
                params={
                    buyNum=num,
                    reward=reward,
                    totalNum=mUseractive.info[aname].d.n,
                }
            })
        end



        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','stormrocket', num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data[aname].hReward=hClientReward
            lotterylog.hr = hClientReward
        end    
        response.data[aname].iscrit = iscrit

    elseif action == 2 then          
        local upgradeNum = 0
        for k,v in ipairs(activeCfg.reward.pool[3]) do
            local hasPartNum = (mUseractive.info[aname].t[v[1]] or 0)
            
            if hasPartNum <= 0 then 
                upgradeNum = 0
                break 
            end

            if k == 1 then 
                upgradeNum = mUseractive.info[aname].t[v[1]] 
            elseif mUseractive.info[aname].t[v[1]] < upgradeNum then
                upgradeNum = mUseractive.info[aname].t[v[1]]
            end
        end
        
        upgradeNum = math.floor(upgradeNum/activeCfg.reward.partToTank)

        if upgradeNum <= 0 then
            response.ret = -404
            return response
        end
        
        mTroops = uobjs.getModel('troops')
        mTroops.incrTanks(activeCfg.reward.tankId,upgradeNum)
        regEventBeforeSave(uid,'e1')

        local upgradePartConsume = upgradeNum * activeCfg.reward.partToTank
        for k,v in ipairs(activeCfg.reward.pool[3]) do
            mUseractive.info[aname].t[v[1]] = mUseractive.info[aname].t[v[1]] - upgradePartConsume
            if mUseractive.info[aname].t[v[1]] < 0 then return end
        end
        
    elseif action == 3 then
        local part = request.params.part
        local ablebuy = false

        for _,v in ipairs(activeCfg.reward.pool[3]) do            
            if part == v[1] and (mUseractive.info[aname].t[v[1]] or 0) == 0 then
                ablebuy = true
                break
            end
        end

        if not ablebuy then
            response.ret = -1974
            return response
        end

        local gemCost = activeCfg.reward.buyGemCost
        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        
        mUseractive.info[aname].t[part] = (mUseractive.info[aname].t[part] or 0) + activeCfg.reward.buyPartNum        
        regActionLogs(uid,1,{action=33,item="",value=gemCost,params={buyNum=activeCfg.reward.buyPartNum,hasNum=mUseractive.info[aname].t[part],}})
    elseif action==4 then
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

        response.data[aname].active = mUseractive.info[aname]

        if reward then
            response.data[aname].reward = reward
        end

        if action==1 then
            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatActiveReward(aname,{[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{getClientTs(),1,rewardlog,lotterylog.hr,lotterylog.n})
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
