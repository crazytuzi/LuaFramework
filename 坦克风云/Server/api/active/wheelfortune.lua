-- 幸运轮盘
-- 初始化数据接口：
--     self.rankList=data["list"]          --排行榜
--     self.point=data["point"]            --个人的物资点数
--     self.consume=data["consume"]        --今日消费额度
--     self.rewardList=data["rewards"]     --奖池中的奖励物品
--     self.chips=data["chips"]            --今日剩余可抽奖次数
-- 点击抽奖按钮，后台需要扣除可抽奖次数，然后重新返回上述的数据金币抽奖

-- action 1为抽奖，2为获取前10排行,3为领奖积分对应的物资,4领取物资排行奖励
function api_active_wheelfortune(request)
    local response = {
        ret=-1,
        msg='error',
        data = {wheelFortune={}},
    }

    local uid = request.uid
    local action = tonumber(request.params.action)

     if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，莫斯科赌局
    local aname = 'wheelFortune'

    -- 抽奖
    -- 按主基地等级来取
    local function lottery(cfg)
        return getRewardByPool(cfg.pool)
    end
        
    -- return bool
    local function hasLottery(c,v,cfg)
        local total = cfg.lotteryConsume * ((c or 0) + 1)

        if (v or 0) >= total then
            return true
        end
    end

    -- 奖励值转积分
    local function getPointByReward(award,cfg)
        local rname = type(award) == 'table' and (next(award)) or ''      
        return arrayGet(getRewardByPool(cfg[rname]),1,0)
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    if action ~= 2 then
        local activStatus 
        if action == 4 then 
            activStatus = mUseractive.isTakeReward(aname) 
        else
            activStatus = mUseractive.getActiveStatus(aname,true)
        end

        -- 活动检测
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    end

    if type(mUseractive.info[aname].d) ~= 'table' then
        mUseractive.info[aname].d = {}
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].d.fn = 0
        mUseractive.info[aname].d.point = 0
        mUseractive.info[aname].d.fr = 0
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].un = 0
        mUseractive.info[aname].vip = 0
    end

    local activeCfg = getConfig("active.wheelFortune."..mUseractive.info[aname].cfg..".serverreward")

    -- 直接抽奖
    if action == 1 then          
        local userfreeN = mUserinfo.vip > 0 and 2 or 1
        
        if (mUseractive.info[aname].d.fn or 0) < userfreeN then
            mUseractive.info[aname].d.fn = (mUseractive.info[aname].d.fn or 0 ) + 1
        else            
            if not hasLottery(mUseractive.info[aname].c,mUseractive.info[aname].un,activeCfg) then
                response.ret = -1981
                return response
            end

            mUseractive.info[aname].c = mUseractive.info[aname].c + 1
            mUseractive.info[aname].d.n = (mUseractive.info[aname].d.n or 0) + 1
        end
        
        reward = lottery(activeCfg)
        local point = getPointByReward(reward,activeCfg.res4point)
        
        mUseractive.info[aname].d.point = (mUseractive.info[aname].d.point or 0) + point
        mUseractive.info[aname].point = (mUseractive.info[aname].point or 0) + point

        if mUseractive.info[aname].point > activeCfg.rankPoint then
            if not setWheelFortuneRanking(uid,mUseractive.info[aname].point) then
                setWheelFortuneRanking(uid,mUseractive.info[aname].point)
            end
        end

        -- 纯粹是为了统计每日VIP用户抽奖数
        if mUserinfo.vip > 0 and (mUseractive.info[aname].vip or 0) == 0 then            
            -- 统计
            mUseractive.setStats(aname,{res=reward,lottery=1,isvip=1})
            mUseractive.info[aname].vip = mUserinfo.vip
        else
            mUseractive.setStats(aname,{res=reward,lottery=1})
        end

        -- 更新最后一次抽奖时间
        mUseractive.info[aname].t = weeTs
        response.data.wheelFortune.active = mUseractive.info[aname]

        if not takeReward(uid,reward) then
            response.ret = -1989
            return response
        end

    -- 拉取活动的排行列表
    elseif action == 2 then       
        local rankList = getWheelFortuneRanking()
        
        local list = {}
        for _,v in ipairs(rankList) do
            local uid = tonumber(v[1])            
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                local item = {}

                table.insert(item,userinfo.nickname)
                table.insert(item,userinfo.level)
                table.insert(item,userinfo.fc)
                table.insert(item,(v[2] or 0))                
                table.insert(item,userinfo.uid)
                table.insert(list,item)
            end    
        end

        response.data.wheelFortune.rankList =  list

    -- 领取活动对应的物资
    elseif action == 3 then
        if (mUseractive.info[aname].d.point or 0) < activeCfg.pointReward[1] then
            response.ret = -1981
            return response
        end

        if (mUseractive.info[aname].d.fr or 0) >= 1 then
            response.ret = -1976
            return response
        end
        
        if not takeReward(uid,activeCfg.pointReward[2]) then
            response.ret = -1989
            return response
        end

        mUseractive.info[aname].d.fr = (mUseractive.info[aname].d.fr or 0) + 1

    -- 领取物资排行的奖励
    elseif action == 4 then
        if (mUseractive.info[aname].rr or 0) >= 1 then
            response.ret = -1976
            return response
        end

        local rank = tonumber(request.params.rank) or 0
        if rank < 1 or rank > 10 then
            response.ret = -1977
            return response
        end

        local selfRank 

        -- 领奖就领一次，一次性把所有排行（共10个）取出来，再遍历也无所谓
        -- 没必要再开一个方法，单独获取个人排名
        local rankList = getWheelFortuneRanking()
        for k,v in ipairs(rankList) do
            if tonumber(v[1]) == uid then
                selfRank = tonumber(k)
                break
            end 
        end
        
        if rank ~= selfRank then
            response.ret = -1975
            return response
        end

        if not selfRank or not activeCfg.r[selfRank] then
            response.ret = -1980
            return response
        end

        if not takeReward(uid,activeCfg.r[selfRank]) then
            response.ret = -1989
            return response
        end

        mUseractive.info[aname].rr = 1
    else
        return response
    end

    processEventsBeforeSave()

    if uobjs.save() then
        if reward then 
            response.data.reward = formatReward(reward)
        end

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
