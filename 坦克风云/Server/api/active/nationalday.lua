-- 国庆活动
-- @params action 0.获取活动数据【可用于凌晨刷新】 1.刷新转盘 2.转盘抽奖 3.道具兑换 4.领取任务奖励
-- @params num (抽取次数1 or 10)
-- @params id 目标id(兑换时是兑换道具的id，任务时是任务id)
function api_active_nationalday(request)
    local response = {
        ret = -1,
        msg = 'error',
        data = {},
    }

    local uid = request.uid
    local action = tonumber(request.params.action) or 0
    local tid = tonumber(request.params.id) or 1
    local num = tonumber(request.params.num) or 1
    local aname = 'nationalDay'

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    setRandSeed()
    local redis = getRedis()

    -- 活动数据
    local actinfo = mUseractive.info[aname]
    local actCfg = mUseractive.getActiveConfig(aname)

    -- 进行转盘8个位置的刷新
    local function rndPool()
        local spool = {}
        local pool = {}

        -- 随机8个位置
        for i=1,8 do
            -- 随机单个位置的奖励
            local singlePool = getRewardByPool(actCfg["serverreward"]["randomPool"..i])

            -- 取出第一个结果
            for k,v in pairs(singlePool) do
                table.insert(spool, {k,v})
                table.insert(pool, formatReward(singlePool))
                break
            end
        end

        return spool,pool
    end

    -- 重置日常任务
    local function refreshTask()
        local task = {}

        -- 随机任务
        for _,value in pairs(actCfg.task) do
            local tmp={value.key, 0}
            table.insert(task,tmp)
        end

        return task
    end
    
    -- 转盘抽奖
    local function rndPoolReward()
        local poolWeight = {}
        local totalWeight = 0
        
        -- 添加权重
        for _,weight in pairs(actCfg.probability) do
            table.insert(poolWeight, weight)
            totalWeight = totalWeight + weight
        end
        
        -- 随机抽取
        local rndNum = math.random(1, totalWeight)
        local hitKey = 1
        for key,v in pairs(poolWeight) do
            if rndNum <= v then
                hitKey = key
                break
            end
            
            rndNum = rndNum - v
        end
        
        return hitKey
    end

    -- 检查活动是否初始化或者隔天刷新数据
    local function checkActive()
        local needInit,crossDay = false,false
        -- 判断是否需要初始化
        if not actinfo or type(actinfo) ~= 'table' or not actinfo.pool then
            needInit = true
            -- 判断是否需要隔天重置
        elseif not tonumber(actinfo.t) or tonumber(actinfo.t) < weeTs then
            crossDay = true
        end

        -- 初始化
        if needInit then
            -- 初始化转盘(刷新转盘)
            actinfo.spool,actinfo.pool = rndPool() -- 转盘信息
            actinfo.anum = actCfg.ReNum -- 距离自动刷新的剩余抽取次数
            actinfo.tbuy = {} -- 活动期间道具购买总信息
        end

        -- 隔天重置
        if crossDay or needInit then
            actinfo.free = 1 -- 免费次数重置
            actinfo.t = weeTs -- 最后刷新时间
            -- actinfo.buy = {} -- 道具购买信息

            -- 刷新日常任务
            if not tonumber(actinfo.t1) or tonumber(actinfo.t1) < weeTs then
                actinfo.tk = refreshTask() -- 任务
                actinfo.t1 = weeTs
            end  

        end

        -- 重新设定活动数据
        mUseractive.info[aname] = actinfo
        return true
    end

    -- 主动刷新转盘
    local function refreshPool(needCheck, free)
        -- 先检查活动
        if needCheck then
            checkActive()
        end

        -- 获取消耗钻石数量（非免费刷新）
        if not free then
            local cost = actCfg.refreshCost
            if not mUserinfo.useGem(cost) then
                response.ret = -109
                return false
            end
            regActionLogs(uid,1,{action=139 ,item="" ,value=cost ,params={}})
        end

        -- 刷新转盘
        actinfo.spool,actinfo.pool = rndPool()
        actinfo.anum = actCfg.ReNum
        return true
    end

    -- 抽奖励
    local function lotteryPool(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end

        local costGem = 0
        -- 单抽
        if 1 == num then
            -- 还有免费次数
            if actinfo.free >= 1 then
                actinfo.free = actinfo.free - 1
            -- 需要消耗钻石
            else
                costGem = actCfg.Cost1
            end
        -- 10连
        elseif 10 == num then
            costGem = actCfg.Cost2
        end

        -- 需要消耗钻石
        if costGem > 0 then
            if not mUserinfo.useGem(costGem) then
                response.ret = -109
                return false
            end
            regActionLogs(uid,1,{action=140 ,item="" ,value=costGem ,params={num=num}})
        end
        
        -- 进行抽奖操作
        local rewards = {}
        local report = {}
        for _=1,num do
            -- 抽取奖励
            local hitkey = rndPoolReward()
            local hitPool = copyTable(actinfo.spool[hitkey])
            
            rewards[hitPool[1]] = rewards[hitPool[1]] or 0
            rewards[hitPool[1]] = rewards[hitPool[1]] + hitPool[2]
                
            -- 扣减自动刷新次数
            actinfo.anum = actinfo.anum - 1
            table.insert(report, copyTable(actinfo.pool[hitkey]))
            
            -- 如果达到自动刷新阈值，则需要自动刷新转盘
            if actinfo.anum <= 0 then
                refreshPool(false, true)
            end
        end
        
        -- 发放奖励
        if not takeReward(uid, rewards) then
            response.ret = -403
            return false
        end
        -- 国庆活动埋点
        activity_setopt(uid, 'nationalDay', {action='cj', num=num})
        
        response.data.reward = report
        return true
    end

    -- 道具兑换
    local function exchangeItem(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end

        tid = tostring(tid)

        -- 先找到要兑换的商品
        local shopItem
        for _,v in pairs(actCfg.exchange) do
            if tid == tostring(v.id) then
                shopItem = v
                break
            end
        end
        
        -- 商品不存在
        if not shopItem then
            response.ret = -102
            return false
        end
        
        -- 判断总兑换上限
        local tbuyNum = actinfo.tbuy[tid] or 0 
        if tonumber(shopItem.maxLimit) and tbuyNum >= tonumber(shopItem.maxLimit) then
            response.ret = -102
            return false
        end
        
        -- 判断今日兑换上限(暂时不要每日限制了)
        -- local buyNum = actinfo.buy[tid] or 0 
        -- if tonumber(shopItem.buynum) and buyNum >= tonumber(shopItem.buynum) then
        --     response.ret = -102
        --     return false
        -- end
        
        -- 判断玩家道具数量足够并进行消耗
        if not mBag.usemore(shopItem.price) then
            response.ret = -1996
            return false
        end
        
        -- 增加对应奖励
        if not takeReward(uid, shopItem.serverReward) then
            response.ret = -403
            return false
        end
        
        -- 记录购买
        tbuyNum = tbuyNum + 1
        -- buyNum = buyNum + 1
        actinfo.tbuy[tid] = tbuyNum
        -- actinfo.buy[tid] = buyNum
        
        response.data.reward = formatReward(shopItem.serverReward)
        response.data.hero = mHero.toArray(true)
        return true
    end

    -- 领取任务奖励
    local function getQuestPrz(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end

        -- 任务 不存在
        if actinfo.tk[tid] == nil then
            response.ret = -102
            return false
        end
        
        local taskCfg
        for _,v in pairs(actCfg.task) do
            if v.key == actinfo.tk[tid][1] then
                taskCfg = v
            end
        end

        -- 任务未完成
        local nnum = actinfo.tk[tid][2] or 0
        if taskCfg.needNum > nnum then
            response.ret = -1981
            return false
        end

        -- 获取奖励
        local reward = taskCfg.serverReward
        -- 发放奖励
        if not takeReward(uid, reward) then
            response.ret = -403
            return false
        end

        actinfo.tk[tid][2] = -1
        response.data.reward = formatReward(reward)
        return true
    end

    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = refreshPool, -- 刷新转盘
        ['2'] = lotteryPool, -- 抽奖励
        ['3'] = exchangeItem, -- 道具兑换
        ['4'] = getQuestPrz, -- 领取任务奖励
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)

    -- 数据返回
    if uobjs.save() and flag then
        response.data[aname] = copyTable(mUseractive.info[aname])
        response.data[aname].spool = nil
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
