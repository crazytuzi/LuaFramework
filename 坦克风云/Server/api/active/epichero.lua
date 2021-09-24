-- 史诗将领活动
-- @params action 0.获取活动数据【可用于凌晨刷新】 1.将领抽奖 2.领取终极奖励 3.获取抽奖记录
-- @params num (抽取次数1 or 10)、
function api_active_epichero(request)
    local response = {
        ret     = -1,
        msg     = 'error',
        data    = {},
    }

    local uid       = request.uid
    local action    = tonumber(request.params.action) or 0
    local num       = tonumber(request.params.num) or 1
    local aname     = 'epichero'

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive   = uobjs.getModel('useractive')
    local mUserinfo     = uobjs.getModel('userinfo')
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
    
    -- 领奖记录缓存
    local redis = getRedis()
    local redkey = "z"..getZoneId()..'.'..aname.."."..actinfo.st.."."..uid
    local rlog = json.decode(redis:get(redkey)) or {}

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
            actinfo.s       = {} -- 目标敌舰打掉的血量
            actinfo.r       = {} -- 目标奖励是否领取
            for i=1,#actCfg.randomItem do
                actinfo.s[i] = 0
                actinfo.r['s'..i] = 0
            end
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
    
    -- 随机计算新增的伤害
    local function rndAddPoint(rwdKey, pointTypeList)
        -- 根据物品价值算出添加多少积分
        setRandSeed()
        local pointType = 1
        if pointTypeList[rwdKey] then
            pointType = pointTypeList[rwdKey]
        end

        local pointList = actCfg.serverreward.pointList[pointType] or {1,1}
        local addPoint = rand(pointList[1],pointList[2])
        setRandSeed()
        local double = rand(1, 100)
        if double <= actCfg.doublePro*100 then
            double = 1
            addPoint = addPoint * actCfg.pointTimes
        else
            double = 0
        end

        -- 随机分配积分到某个部位
        local pool = {}
        local poolidx = {}
        local maxCount = 0
        for rindex,rnum in pairs(actCfg.randomItem) do
            local rndnum = 0
            -- 过滤已经集满的部位
            if actinfo.s[rindex] < actCfg.maxPoint then
                rndnum = rnum
            end
            
            table.insert(poolidx, rindex)
            table.insert(pool, rndnum)
            maxCount = maxCount + rndnum
        end
        
        -- 将积分加到对应位置 并判断是否集满
        if 0 < maxCount then
            setRandSeed()
            local rndN = rand(1, maxCount)
            local pos = 1
            for i=1,#pool do
                if rndN <= pool[i] then
                    pos = tonumber(poolidx[i])
                    break
                end
                rndN = rndN - pool[i]
            end
            actinfo.s[pos] = (actinfo.s[pos] or 0) + addPoint
            
            return pos,addPoint,double
        else
            return 0,0,0
        end
    end
    
    -- 发放终极奖励
    local function addMustRwd()
        -- 判断是否可以领取终极奖励
        local needRwd = true
        for i=1,#actCfg.randomItem do
            if 0 == actinfo.r['s'..i] then
                needRwd = false
                response.ret = -102
            end
        end
        
        -- 需要发放终极奖励
        if needRwd then
            local reward = actCfg.mustGetHero
            
            if not takeReward(uid,reward) then
                response.ret = -1989
                return false
            end
            
            -- 重置目标敌舰
            actinfo.s       = {} -- 目标敌舰打掉的血量
            actinfo.r       = {} -- 目标奖励是否领取
            for i=1,#actCfg.randomItem do
                actinfo.s[i] = 0
                actinfo.r['s'..i] = 0
            end
            
            return true,{4,formatReward(reward)},{{formatReward(reward)}, ts, 3}
        else
            response.ret = -102
            return false
        end
    end
    local harCReward={}--和谐版的值
    -- 抽奖励
    local function lottery(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- 消耗钻石
        local costGem = 0
        -- 单抽
        if 1 == num then
            -- 还有免费次数
            if actinfo.free < actCfg.freeNum then
                actinfo.free = actinfo.free + 1
            -- 需要消耗钻石
            else
                costGem = actCfg.cost1
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
            regActionLogs(uid,1,{action=144 ,item="" ,value=costGem ,params={num=num}})
        end
        
        -- 进行抽奖操作
        local report = {}
        local pointTypeList = actCfg.serverreward.pointType or {}
        local rep1,rep2,rep3 ={},{},{}
        for i=1,num do
            -- 抽取奖励
            local reward = getRewardByPool(actCfg.serverreward.randomPool)
            -- table.insert(rep1, formatReward(reward)) -- 记录奖励log
            
            for k,v in pairs(reward or {}) do
                rep1[k] = rep1[k] or 0
                rep1[k] = rep1[k] + v
                table.insert(report, {1, formatReward({[k]=v})}) -- 常规奖励log
                
                -- 随机出需要打出的伤害值
                local pos,addPoint,double = rndAddPoint(k, pointTypeList)
                table.insert(report, {2, {pos, addPoint, double}})
                
                -- 判断该目标是否满足击破奖励
                if actinfo.s[pos] >= actCfg.maxPoint then
                    actinfo.s[pos] = actCfg.maxPoint

                    -- 发集满奖励
                    if 0 == actinfo.r['s'..pos] then
                        local extReward = actCfg.serverreward.getReward[pos] or {}
                        if not takeReward(uid,extReward) then
                            response.ret = -1989
                            return false
                        end
                        actinfo.r['s'..pos] = 1
                        table.insert(report, {3, formatReward(extReward)})
                        table.insert(rep2, {{formatReward(extReward)}, ts, 2}) -- 记录奖励log
                    end
                end
            end
            
            -- 发放抽奖奖励
            if not takeReward(uid,reward) then
                response.ret = -1989
                return false
            end
            
            -- 判断是否添加终极奖励
            if i < num then
                local addFlag,addData,rwdlog = addMustRwd()
                if addFlag then
                    table.insert(report, addData)
                    table.insert(rep3, rwdlog) -- 记录奖励log
                end
            end
        end

        -- 抽奖奖励
        local clientF = {}
        for k,v in pairs(rep1) do
            table.insert(clientF, formatReward({[k] = v}))
        end

        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','epichero', num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward
            for k,v in pairs(hReward) do
                table.insert(clientF, formatReward({[k] = v}))
            end            
        end
        table.insert(rlog, 1, {clientF, ts, 1}) 
        
        -- 击破奖励
        for _,v in pairs(rep2) do
            table.insert(rlog, 1, v) 
        end
        
        -- 终极奖励
        for _,v in pairs(rep3) do
            table.insert(rlog, 1, v) 
        end
        
        
        response.data.report = report
        return true
    end
    
    -- 领取终极奖励
    local function recReward(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        local report = {}
        local addFlag,addData,rwdlog = addMustRwd()
        if addFlag then
            table.insert(report,addData)
            table.insert(rlog, rwdlog) -- 记录奖励log
        end
        
        response.data.report = report
        return addFlag
    end
    
    local function getLog(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        return true
    end
        
    
    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = lottery, -- 装备抽奖
        ['2'] = recReward, -- 领取终极奖励
        ['3'] = getLog, -- 获取抽奖记录
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)
    
    -- 数据返回
    if uobjs.save() and flag then
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
        response.data.hero = mHero.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
