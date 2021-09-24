local function checkKV(scoreCfg,k,v)
    if not scoreCfg[k] then return false end
    
    if math.floor(v) ~= v then return false end

    if v < 1 then return false end

    return true
end

-- 获取固定消耗的任务的消耗
local function getTaskCost1(items,itemlack,taskCfg,scoreCfg)
    if not items then return false end

    local itemCost = {}
    for k,v in pairs(items) do
        if not checkKV(scoreCfg,k,v) then return false end
        itemCost[k] = (itemCost[k] or 0) + v
    end

    local gemsCost = 0
    if itemlack then
        for k,v in pairs(itemlack) do
            if not checkKV(scoreCfg,k,v) then return false end

            itemCost[k] = (itemCost[k] or 0) + v
            gemsCost = gemsCost + scoreCfg[k].gemCost * v
        end
    end

    for k,v in pairs(taskCfg.cost) do
        if not itemCost[k] or itemCost[k] ~= v then
            return false
        end
    end

    for k,v in pairs(itemCost) do
        if not taskCfg.cost[k] then  return false end
    end

    return items,math.ceil(gemsCost)
end

-- 固定等级船消耗taskType=2的任务的消耗
local function getTaskCost2(items,itemlack,taskCfg,scoreCfg)
    if not items then return false end

    local totalNum = 0
    for k,v in pairs(items) do
        if not checkKV(scoreCfg,k,v) then return false end

        if scoreCfg[k].level ~= taskCfg.costShipLevel then
            return false
        end

        totalNum = totalNum + v
    end

    local gemsCost = 0
    if itemlack then
        for k,v in pairs(itemlack) do
            if not checkKV(scoreCfg,k,v) then return false end

            if scoreCfg[k].level ~= taskCfg.costShipLevel then
                return false
            end

            totalNum = totalNum + v
            gemsCost = gemsCost + scoreCfg[k].gemCost * v
        end
    end

    if totalNum == taskCfg.costNum then
        return items, math.ceil(gemsCost)
    end
end

-- 获取消耗固定积分的跨等级船taskType=3的任务的消耗
local function getTaskCost3(items,itemlack,taskCfg,scoreCfg)
    if not items then return false end

    local totalScore = 0
    for k,v in pairs(items) do
        if not checkKV(scoreCfg,k,v) then return false end

        totalScore = totalScore + scoreCfg[k].score * v
    end

    local gemsCost = 0
    if itemlack then
        for k,v in pairs(itemlack) do
            if not checkKV(scoreCfg,k,v) then return false end

            totalScore = totalScore + scoreCfg[k].score * v
            gemsCost = gemsCost + scoreCfg[k].gemCost * v
        end
    end

    if totalScore >= taskCfg.shipScore then
        return items, math.ceil(gemsCost)
    end
end


-- 补给舰 任务相关api
local function api_tender_task(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_refresh"] = {
                idx = {"required","number"},
                tid = {"required","string"},
            },

            ["action_remove"] = {
                idx = {"required","number"},
                tid = {"required","string"},
            },

            ["action_buy"] = {
                cost = {"required","number"},
            },

            ["action_execute"] = {
                idx = {"required","number"},
                tid = {"required","string"},
                items = {"required","table"},
                cost = {"required","number"},
            },

            ["action_reward"] = {
                idx = {"required","number"},
                tid = {"required","string"},
                cost = {"required","number"},
            },
        }
    end

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('tender') then
            self.response.ret = -180
            return self.response
        end
    end

    --[[
        任务刷新
        因购买任务从蓝色起，则刷新的范围是从蓝色起到橙色，不会出现绿色和白色；
        执行中的任务不可刷新
    ]]
    function self.action_refresh(request)
        local response = self.response
        local idx = request.params.idx
        local tid = request.params.tid

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local taskInfo = mTender.getTask(idx,tid)

        -- 操作的任务不存在(请刷新数据后重试)
        if not taskInfo then
            response.ret = -28007
            return response
        end

        -- 任务已经开始，不能刷新
        if mTender.taskIsStart(taskInfo) then
            response.ret = -28008
            return response
        end

        local newTaskInfo
        if mTender.isCommonTask(taskInfo) then
            newTaskInfo = mTender.genCommonTask(taskInfo)
        else
            newTaskInfo = mTender.genAdvancedTask(taskInfo)
        end

        if not newTaskInfo then
            response.ret = -1989
            return response
        end

        mTender.replaceTask(idx,newTaskInfo)

        local gemsCost = getConfig("tender").main.refreshPrice
        if gemsCost < 1 then
            response.ret = -102
            response.gemsCost = gemsCost
            return response
        end

        -- 金币不足
        if not uobjs.getModel('userinfo').useGem(gemsCost) then
            response.ret = -109 
            return response
        end

        -- 补给舰-任务刷新
        regActionLogs(uid,1,{action=228,item="",value=gemsCost,params={taskInfo[1],newTaskInfo[1]}})

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        任务购买
        购买的任务至少为蓝色任务
    ]]
    function self.action_buy(request)
        local response = self.response
        local clientCost = request.params.cost

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        -- 任务队列已满，不能购买了
        if mTender.taskQueueIsFull() then
            response.ret = -28009
            return response
        end

        local buycount = mTender.incrBuyCount()

        local taskPriceCfg = getConfig("tender").main.taskPrice
        local gemsCost = taskPriceCfg[buycount] or taskPriceCfg[#taskPriceCfg]
        if gemsCost < 1 or clientCost ~= gemsCost then
            response.ret = -102
            response.gemsCost = gemsCost
            return response
        end

        -- 金币不足
        if not uobjs.getModel('userinfo').useGem(gemsCost) then
            response.ret = -109 
            return response
        end

        local newTaskInfo = mTender.genAdvancedTask()
        if not newTaskInfo then
            response.ret = -1989
            return response
        end

        mTender.addTask(newTaskInfo)

        -- 补给舰-任务购买
        regActionLogs(uid,1,{action=227,item="",value=gemsCost,params={newTaskInfo[1]}})

        if uobjs.save() then
            processEventsAfterSave()
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        任务删除
        已在执行的任务，不可删除
    ]]
    function self.action_remove(request)
        local response = self.response
        local idx = request.params.idx
        local tid = request.params.tid

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local taskInfo = mTender.getTask(idx,tid)

        -- 操作的任务不存在(请刷新数据后重试)
        if not taskInfo then
            response.ret = -28007
            return response
        end

        -- 任务已经开始，不能删除
        if mTender.taskIsStart(taskInfo) then
            response.ret = -28008
            return response
        end

        mTender.removeTask(idx)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        执行任务

        一键执行时，只消费钻石，不消耗船
        舰船不足时，也可以一键执行；
        钻石补充不足的船;
    ]]
    function self.action_execute(request)
        local response = self.response
        local idx = request.params.idx
        local tid = request.params.tid

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local taskInfo = mTender.getTask(idx,tid)

        -- 操作的任务不存在(请刷新数据后重试)
        if not taskInfo then
            response.ret = -28007
            return response
        end

        -- 任务已经开始
        if mTender.taskIsStart(taskInfo) then
            response.ret = -28008
            return response
        end

        local tenderCfg = getConfig("tender")
        local taskCfg = tenderCfg.taskList[taskInfo[1]]

        local items = request.params.items  -- 本次消耗的物品
        local clientCost = request.params.cost  -- 金币补足消耗
        local itemlack = request.params.itemlack  -- 缺少的物品

        --[[
            taskType：任务类型：
            1.固定船消耗
            2.固定等级船消耗，
            3.消耗固定积分的跨等级船
            4.固定配件材料消耗
            5.固定异星宝石消耗
            6.固定装甲矩阵消耗
            7.固定异星资源消耗
        ]]
        local itemCost, gemsCost

-- TODO TEST
-- ptb:p(uobjs.getModel('accessory').props)
-- ptb:p(uobjs.getModel('alienweapon').jewelinfo1)
-- ptb:p(uobjs.getModel('armor').exp)
-- ptb:p(uobjs.getModel('alien').prop)
-- ptb:p({
--         {"a10013",uobjs.getModel('troops').troops.a10013},
--         {"a10031",uobjs.getModel('troops').troops.a10031},
--         {"a10024",uobjs.getModel('troops').troops.a10024},
--         {"a10002",uobjs.getModel('troops').troops.a10002},
--         {"a10023",uobjs.getModel('troops').troops.a10023},
--         {"a10016",uobjs.getModel('troops').troops.a10016},
--     })

        if taskCfg.taskType > 0 and taskCfg.taskType <= 3 then
            if taskCfg.taskType == 1 then
                itemCost, gemsCost = getTaskCost1(items,itemlack,taskCfg,tenderCfg.shipScore)
            elseif taskCfg.taskType == 2 then
                itemCost, gemsCost = getTaskCost2(items,itemlack,taskCfg,tenderCfg.shipScore)
            elseif taskCfg.taskType == 3 then
                itemCost, gemsCost = getTaskCost3(items,itemlack,taskCfg,tenderCfg.shipScore)
            end

            local kfkLog = {}

            -- 扣除部队
            if itemCost and next(itemCost) then
                local mTroop = uobjs.getModel("troops")
                for k,v in pairs(itemCost) do
                    if not mTroop.consumeTanks(k,v) then
                        response.ret = -5006
                        return response
                    end

                    table.insert(kfkLog,{k,v,(mTroop.troops[k] or 0)})
                end
            end

            regKfkLogs(uid,'tankChange',{
                    addition={
                        {desc="补给舰任务消耗船(船id,消耗数,剩余数)",value=kfkLog},
                    }
                }
            )
        elseif taskCfg.taskType == 4 then
            -- 配件材料
            itemCost, gemsCost = getTaskCost1(items,itemlack,taskCfg,tenderCfg.accessoryScore)
            if itemCost then
                if not uobjs.getModel('accessory').useProps(itemCost) then
                    response.ret = -9033
                    return response
                end
            end
        elseif taskCfg.taskType == 5 then
            -- 异星武器宝石材料
            itemCost, gemsCost = getTaskCost1(items,itemlack,taskCfg,tenderCfg.jewelScore)
            if itemCost then
                local mAlienweapon = uobjs.getModel("alienweapon")
                for k,v in pairs(itemCost) do
                    if not mAlienweapon.costjewel(k,v) then
                        response.ret = -26004
                        return response
                    end
                end
            end
        elseif taskCfg.taskType == 6 then
            -- 方阵材料，只会扣经验
            itemCost, gemsCost = getTaskCost1(items,itemlack,taskCfg,tenderCfg.armorScore)
            if itemCost then
                if not uobjs.getModel('armor').useExp(itemCost.exp) then
                    response.ret = -9052
                    return response
                end
            end
        elseif taskCfg.taskType == 7 then
            --异星资源材料
            itemCost, gemsCost = getTaskCost1(items,itemlack,taskCfg,tenderCfg.alienScore)
            if itemCost then
                if not uobjs.getModel('alien').useProps(itemCost) then
                    response.ret=-16014
                    return response
                end
            end
        else
            response.ret = -102
            response.err = "taskType error"
            response.taskType = taskType
            return response
        end

        if not itemCost then
            response.ret = -102
            response.err = "itemCost is nil"
            return response
        end

        -- 金币对不上
        if gemsCost ~= clientCost then
            response.ret = -102
            response.gemsCost = gemsCost
            return response
        end
         
        if gemsCost > 0 then
            -- 金币不足
            if not uobjs.getModel('userinfo').useGem(gemsCost) then
                response.ret = -109 
                return response
            end

            -- 229 补给舰-任务一键执行
            regActionLogs(uid,1,{action=229,item="",value=gemsCost,params={itemlack=itemlack}})
        end

-- TODO TEST

-- ptb:p(uobjs.getModel('accessory').props)
-- ptb:p(uobjs.getModel('alienweapon').jewelinfo1)
-- ptb:p(uobjs.getModel('armor').exp)
-- ptb:p(uobjs.getModel('alien').prop)

-- ptb:p({
--         {"a10013",uobjs.getModel('troops').troops.a10013},
--         {"a10031",uobjs.getModel('troops').troops.a10031},
--         {"a10024",uobjs.getModel('troops').troops.a10024},
--         {"a10002",uobjs.getModel('troops').troops.a10002},
--         {"a10023",uobjs.getModel('troops').troops.a10023},
--         {"a10016",uobjs.getModel('troops').troops.a10016},
--     })


        -- ptb:p({
        --     itemCost, gemsCost, itemlack,uobjs.getModel('userinfo').gems
        --     })

        mTender.taskStart(taskInfo)

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 领取任务奖励
    function self.action_reward(request)
        local response = self.response
        local idx = request.params.idx
        local tid = request.params.tid
        local cost = request.params.cost or 0

        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTender = uobjs.getModel('tender')

        local taskInfo = mTender.getTask(idx,tid)

        -- 操作的任务不存在(请刷新数据后重试)
        if not taskInfo then
            response.ret = -28007
            return response
        end

        -- 任务未完成,不能领奖
        if not mTender.taskIsCompleted(taskInfo) then
            response.ret = -28010
            return response
        end

        local taskCfg = getConfig("tender").taskList[tid]
        local expGet = taskCfg.expGet

        -- 双倍经验
        if cost > 0 and cost == taskCfg.doublePrice then
            local gemsCost = taskCfg.doublePrice

            -- 金币不足
            if not uobjs.getModel('userinfo').useGem(gemsCost) then
                response.ret = -109 
                return response
            end

            expGet = expGet * 2

            -- 232 补给舰-领取双倍任务经验
            regActionLogs(uid,1,{action=232,item="",value=gemsCost,params={exp=expGet}})
        end

        mTender.addExp(expGet)
        mTender.addMaterial(taskCfg.get)
        mTender.removeTask(idx)

        -- 国庆七天乐
        activity_setopt(uid,'nationalday2018',{act='tk',type='bj',num=1})
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='bj',num=1})

        if uobjs.save() then
            response.data.tender = mTender.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_tender_task