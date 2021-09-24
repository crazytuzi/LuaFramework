-- 
-- 群蜂来袭
-- chenyunhe
-- @params action  1.舰船抽奖 2.获取抽奖日志 3.改造工厂
-- @params num (抽奖时 为抽取次数1 or 10， 改造工厂时为 改造的数量)
-- @params aid 舰船id
--

function api_active_qflx2018(request)
    local response = {
        ret     = -1,
        msg     = 'error',
        data    = {},
    }

    local uid       = request.uid
    local action    = tonumber(request.params.action) or 0
    local num       = tonumber(request.params.num) or 1
    local aname     = 'qflx2018'

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive   = uobjs.getModel('useractive')
    local mUserinfo     = uobjs.getModel('userinfo')
    local mTroop        = uobjs.getModel('troops')
    local activStatus   = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts        = getClientTs()
    local weeTs     = getWeeTs()
    setRandSeed()

    -- 活动数据
    local actinfo   = mUseractive.info[aname]
    local actCfg    = mUseractive.getActiveConfig(aname)

    -- 领奖记录缓存
    local redis = getRedis()
    local redkey = "z"..getZoneId()..'.'..aname.."."..actinfo.st.."."..uid
    local rlog = json.decode(redis:get(redkey)) or {}
    local harCReward={}--和谐版给客户端的奖励
    -- 检查活动是否初始化或者隔天刷新数据
    local function checkActive()
        local needInit,crossDay = false,false
        -- 判断是否需要初始化
        if not actinfo or type(actinfo) ~= 'table' or 0 == actinfo.c then
            needInit = true
        -- 判断是否需要隔天重置
        elseif not tonumber(actinfo.t) or tonumber(actinfo.t) ~= weeTs then
            crossDay = true
        end

        -- 初始化
        if needInit then
            actinfo.bn      = actCfg.baseNum    -- 初始大奖数量
            actinfo.ln      = 0                 -- 抽取积累次数(每满一次大奖增长则重置0)
            actinfo.c       = 1
        end

        -- 隔天重置
        if crossDay or needInit then
            actinfo.free    = 0 -- 免费次数重置
            actinfo.t       = weeTs -- 最后刷新时间
        end

        -- 重新设定活动数据
        mUseractive.info[aname] = actinfo
        return true
    end
    
    -- 抽奖励
    local function lottery(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- 消耗钻石
        local costGem = 0
        if not table.contains({1,10},num) then
            return false
        end
        -- 单抽
        if 1 == num then
            -- 还有免费次数
            if actinfo.free < 1 then
                actinfo.free = actinfo.free + 1
            -- 需要消耗钻石
            else
                costGem = actCfg.cost
            end
        -- 10连
        elseif 10 == num then
            costGem = actCfg.cost10
        end

        -- 需要消耗钻石
        if costGem > 0 then
            if not mUserinfo.useGem(costGem) then
                response.ret = -109
                return false
            end
            regActionLogs(uid,1,{action=264 ,item="" ,value=costGem ,params={num=num}})
        end
        
        -- 进行抽奖操作
        local report = {}
        local rewards = {}
        local hasbig = 0

        for _=1,num do
            -- 先随机奖池
            local poolkey = getRewardByPool(actCfg.serverreward.pool)
            local pkey = poolkey[1]
            
            -- 大奖
            local big = false
            local pool = actCfg.serverreward.poolB
            if 'A' == pkey then
                big = true
                hasbig = 1
                pool = actCfg.serverreward.poolA
            end

            local reward = getRewardByPool(pool)
    
            -- 判定是否增加数量
            -- 大奖计数增加
            actinfo.ln = actinfo.ln + 1
            
            -- 计数达到阈值，则增加大奖数量并重置计数
            if actinfo.ln >= actCfg.drawNum then
                actinfo.bn = actinfo.bn + actCfg.addNum
                if actinfo.bn >= actCfg.limintNum then
                    actinfo.bn = actCfg.limintNum
                end
                actinfo.ln = 0
            end
            -- 如果是大奖，大奖计数重置
            if big then
                actinfo.ln = 0
                -- 大奖奖励处理
                local rkey = reward[1]
                reward = {[rkey] = actinfo.bn}
                
                -- 大奖数量变为初始
                actinfo.bn = actCfg.baseNum
            end
            
            -- 累加奖励
            for k,v in pairs(reward) do
                rewards[k] = rewards[k] or 0
                rewards[k] = rewards[k] + v
            end
            
            table.insert(report, {formatReward(reward), big and 1 or 0})
        end
        
        -- 抽奖奖励
        local clientF = {}
        for k,v in pairs(rewards) do
            table.insert(clientF, formatReward({[k] = v}))
        end
        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active',aname, num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward
            --for k,v in pairs(hReward) do
              --  table.insert(clientF, formatReward({[k] = v}))
            --end            
        end
        table.insert(rlog, 1, {clientF, ts, hasbig,num,harCReward}) 
        
        -- 发放抽奖奖励
        if not takeReward(uid,rewards) then
            response.ret = -1989
            return false
        end
        
        response.data.report = report
        return true
    end
    
    -- 获取抽奖记录
    local function getLog(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        return true
    end
    
    -- 改造工厂
    local function upgrade(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        local aid = request.params.aid
        local nums = tonumber(num)
        local cfg = actCfg.consume[aid]
        if nums <= 0 or not cfg then
            response.ret = -102
            return false
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
                return false
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
                    return false
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
            return false
        end

        mTroop.incrTanks(aid, nums)
        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        
        return true
    end

    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = lottery, -- 装备抽奖
        ['2'] = getLog, -- 获取抽奖记录
        --['3'] = upgrade, -- 改造工厂  *****这个接口不用了 客户端跳转其他接口了*****
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)

    processEventsBeforeSave()

    -- 数据返回
    if flag and uobjs.save() then
        -- 删除多余的最近抽奖信息
        if next(rlog) then
            local difNum = #rlog - 20
            if difNum > 0 then
                for _=1,difNum do
                    table.remove(rlog)
                end
            end
            redis:set(redkey, json.encode(rlog))
            redis:expireat(redkey,mUseractive.info[aname].et + 86400)
        end
        
        response.data[aname] = mUseractive.info[aname]
        if next(harCReward) then
            response.data[aname].hReward=harCReward
        end        
        response.data[aname].rlog = rlog
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
