-- 限时装备活动
-- @params action 0.获取活动数据【可用于凌晨刷新】 1.装备抽奖 2.领取终极奖励 3.商店兑换
-- @params num (抽取次数1 or 10)
-- @params id 目标id(兑换时是兑换目标的id)
function api_active_limitsequip(request)
    local response = {
        ret     = -1,
        msg     = 'error',
        data    = {},
    }

    local uid       = request.uid
    local action    = tonumber(request.params.action) or 0
    local tid       = tonumber(request.params.id) or 1
    local num       = tonumber(request.params.num) or 1
    local aname     = 'limitsequip'

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive   = uobjs.getModel('useractive')
    local mUserinfo     = uobjs.getModel('userinfo')
    local mTroops       = uobjs.getModel('troops')
    local mAccessory    = uobjs.getModel('accessory')
    local mBag          = uobjs.getModel("bag")
    local mHero         = uobjs.getModel('hero')
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
    
    -- 随机确定一个需要开启的格子位
    local function randStar(offSe)
        local rnd = math.random(1, #offSe)
        
        return offSe[rnd]
    end
    
    -- 进行格子是否开启的处理
    local function openNextStart(rndKeys)
        -- 先获取当前还未开启的格子
        local offSe = {}
        for k,v in pairs(actinfo.se) do
            if 0 == v then
                table.insert(offSe, k)
            end
        end
        
        -- 如果已经都开启了，则直接返回，等用户领取走奖励先
        if #offSe <= 0 then
            return 
        end
        
        -- 先判定是否达到幸运值阈值
        local nexNo = 9 - #offSe + 1
        if actinfo.luck >= actCfg.luckyLimit[nexNo] then
            -- 随机开启一个格子
            local star = randStar(offSe)
            actinfo.se[star] = 1
            
            -- 重置幸运值
            actinfo.luck = 0
            return
        end
        
        -- 否则根据当前开启个数获取几率进行随机
        local nextRate = actCfg["serverreward"]["starRate"][nexNo]
        local rndNum = math.random(1, 100)
        -- 命中
        if rndNum <= nextRate * 100 then
            -- 随机开启一个格子
            local star = randStar(offSe)
            actinfo.se[star] = 1
            
            -- 重置幸运值
            actinfo.luck = 0
            return
        end
        
        -- 没能开启一个格子，增加幸运值
        for _,v in pairs(rndKeys) do
            actinfo.luck = actinfo.luck + actCfg.luckyValue[v]
        end
    end

    -- 检查活动是否初始化或者隔天刷新数据
    local function checkActive()
        local needInit,crossDay = false,false
        -- 判断是否需要初始化
        if not actinfo or type(actinfo) ~= 'table' or 0 == actinfo.c then
            needInit = true
        -- 判断是否需要隔天重置
        elseif not tonumber(actinfo.t) or tonumber(actinfo.t) < weeTs then
            crossDay = true
        end

        -- 初始化
        if needInit then
            actinfo.luck    = 0 -- 幸运值
            actinfo.se      = {0,0,0,0,0,0,0,0,0} -- 9格 默认全部未开启
            actinfo.c       = 1
            actinfo.tbuy    = {} -- 活动期间道具购买总信息
            actinfo.rb      = {} -- 活动最近抽奖信息,保留20条
            actinfo.sp      = 0 -- 活动科研点数量
        end

        -- 隔天重置
        if crossDay or needInit then
            actinfo.free    = 1 -- 免费次数重置
            actinfo.t       = weeTs -- 最后刷新时间
        end

        -- 重新设定活动数据
        mUseractive.info[aname] = actinfo
        return true
    end
    local harCReward={}-- 和谐版客户端奖励值
    -- 抽奖励
    local function lotteryPool(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- 消耗钻石
        local costGem = 0
        -- 单抽
        if 1 == num then
            -- 还有免费次数
            if actinfo.free >= 1 then
                actinfo.free = actinfo.free - 1
            -- 需要消耗钻石
            else
                costGem = actCfg.cost
            end
        -- 10连
        elseif 10 == num then
            costGem = actCfg.cost2
        end

        -- 需要消耗钻石
        if costGem > 0 then
            if not mUserinfo.useGem(costGem) then
                response.ret = -109
                return false
            end
            regActionLogs(uid,1,{action=141 ,item="" ,value=costGem ,params={num=num}})
        end

        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','limitsequip',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward         

            local tmpdata={formatReward(hReward),ts}
            --table.insert(actinfo.rb,#actinfo.rb-num,tmpdata) 
            table.insert(actinfo.rb,1,tmpdata) 
        end        
        
        -- 进行抽奖操作
        local rewards = {}
        local report = {}
        for _=1,num do
            -- 抽取奖励
            local reward,rndKeys = getRewardByPool(actCfg["serverreward"]["pool"])
            for k,v in pairs(reward) do
                rewards[k] = rewards[k] or 0
                rewards[k] = rewards[k] + v
                
                -- 客户端的格式修改
                local clientFormat
                if k == 'sp_s1' then
                    clientFormat = {["p"]={["sp_s1"]=v}}
                else
                    clientFormat = formatReward({[k]=v})
                end
                table.insert(report, clientFormat)
                
                -- 最近抽奖记录
                actinfo.rb = actinfo.rb or {}
                table.insert(actinfo.rb, 1, {clientFormat, ts})
            end
            
            -- 是否能开启新格子的处理
            openNextStart(rndKeys)
        end
        
        -- 删除多余的最近抽奖信息
        local difNum = #actinfo.rb - 20
        if difNum > 0 then
            for _=1,difNum do
                table.remove(actinfo.rb)
            end
        end
        
        -- 发放奖励
        for addkey,addcount in pairs(rewards) do
            if addkey ~= 'sp_s1' then
                if not takeReward(uid, {[addkey]=addcount}) then
                    response.ret = -403
                    return response
                end
            else
                actinfo.sp = actinfo.sp or 0
                actinfo.sp = actinfo.sp + addcount
            end
        end
        
        response.data.reward = report
        return true
    end
    
    -- 领取终极奖励
    local function recReward(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- 验证是否9格全部开启
        for _,v in pairs(actinfo.se) do
            -- 还有未开启的格子
            if 0 == v then
                response.ret = -102
                return false
            end
        end
            
        -- 发放奖励
        local reward = actCfg.mustGetSuperEquip
        if not takeReward(uid, reward) then
            response.ret = -403
            return false
        end
        
        -- 重置格子
        actinfo.se = {0,0,0,0,0,0,0,0,0}
        
        response.data.reward = {formatReward(reward)}
        
        return true
    end
    
    -- 商店兑换
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
        actinfo.tbuy = actinfo.tbuy or {}
        local tbuyNum = actinfo.tbuy[tid] or 0 
        if tonumber(shopItem.maxLimit) and tbuyNum >= tonumber(shopItem.maxLimit) then
            response.ret = -102
            return false
        end
        
        -- 判断玩家道具数量足够并进行消耗
        local costNum = tonumber(shopItem.price["sp_s1"])
        if actinfo.sp >= costNum then
            actinfo.sp = actinfo.sp - costNum
        end
        
        -- 增加对应奖励
        if not takeReward(uid, shopItem.serverReward) then
            response.ret = -403
            return false
        end
        
        -- 记录购买
        tbuyNum = tbuyNum + 1
        actinfo.tbuy[tid] = tbuyNum
        
        response.data.reward = formatReward(shopItem.serverReward)
        
        return true
    end
    
    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = lotteryPool, -- 装备抽奖
        ['2'] = recReward, -- 领取终极奖励
        ['3'] = exchangeItem, -- 商店兑换
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)

    -- 数据返回
    if uobjs.save() and flag then
        response.data[aname] = mUseractive.info[aname]
        if next(harCReward) then
            response.data[aname].hReward=harCReward
        end         
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
