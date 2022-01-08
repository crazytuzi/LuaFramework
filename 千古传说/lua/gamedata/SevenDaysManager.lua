--[[
******七日活动管理类*******

	-- by king
	-- 2015/9/8
]]


local SevenDaysManager = class("SevenDaysManager")

local sevenDaysConfig = require("lua.table.t_s_7_days_goal")

SevenDaysManager.UPDATETASK = "SevenDaysManager.UPDATETASK"

function SevenDaysManager:ctor()
    TFDirector:addProto(s2c.SEVEN_DAYS_GOAL_TASK_LIST, self,    self.onReceiveSevenListResult)
    TFDirector:addProto(s2c.NOTIFY_NEW_SEVEN_DAYS_GOAL_TASK, self,    self.onReceiveNewTaskResult)

    TFDirector:addProto(s2c.GET_SEVEN_DAYS_GOAL_TASK_REWARD_RESULT, self, self.onReceiveSevenRewardResult)
    TFDirector:addProto(s2c.NOTIFY_SEVEN_DAYS_GOAL_TASK_FINISH, self, self.onReceiveSevenTaskCompelete)
    TFDirector:addProto(s2c.NOTIFY_SEVEN_DAYS_GOAL_TASK_STEP, self, self.onReceiveSevenTaskProgress)
    TFDirector:addProto(s2c.SHOP_ITEM_ALREADY_BUY_INFO_LIST, self, self.onReceiveAlreadyBuyInfo)

    -- 七日一天的数据 
    self.DayTaskData    = TFArray:new()
    -- 七日一天数据的其中一项
    self.DayTaskTitle   = TFArray:new()

    -- 一天中一个类目的数据
    self.DayTaskDataWithTitle    = TFArray:new()

    -- 网络下发七日任务的状态
    self.taskStatusList = MEMapArray:new()

    -- 网络下发半价商店状态
    self.shopItemList = MEMapArray:new()

    self.sevenTaskList = sevenDaysConfig

    self.SevenDayShopConfig = require("lua.table.t_s_7_days_discount")
end

function SevenDaysManager:restart()
    self:stopSevenDaysTimer()
end

function SevenDaysManager:onReceiveSevenListResult( event )
    print("----------------onReceiveSevenListResult")
    -- print(event.data)


    self.taskStatusList:clear()
    local tasklist = event.data.tasklist

    for k,v in pairs(tasklist) do
        self.taskStatusList:pushbyid(v.taskid, v)
    end

        
--     hideLoading()
--     AlertManager:close()
--     toastMessage("发送成功")
-- n = adad +1
end

-- code = 0x2052 领取奖励成功
function SevenDaysManager:onReceiveSevenRewardResult( event )
    
    hideLoading()

    print("------SevenDaysManager:onReceiveSevenRewardResult-------")
    print("event.data = ",event.data)
    -- 领取可能多个
    local taskid = event.data.taskid[1]
    local task = self.taskStatusList:objectByID(taskid)
    
    if task then
        task.state = 2
    end

    print("领取奖励 taskid = ",taskid)

    local taskData = sevenDaysConfig:objectByID(taskid)
    if taskData then
        -- 半价商店
        if taskData.type == 9999 then
            print("购买的是半价商品 = ", taskData.reward_id)
            local itemInfo = self.shopItemList:objectByID(taskData.reward_id)
            if itemInfo then
                itemInfo.number = itemInfo.number + 1
            end
        end
    end

    TFDirector:dispatchGlobalEventWith(self.UPDATETASK, {id = taskid})
end

-- code = 0x2053 通知成就完成
function SevenDaysManager:onReceiveSevenTaskCompelete( event )

    print("------SevenDaysManager:onReceiveSevenTaskCompelete-------")
    print("event.data = ",event.data)
    local taskid = event.data.taskid
    local task = self.taskStatusList:objectByID(taskid)
    
    if task then
        task.state = 1
    end

    TFDirector:dispatchGlobalEventWith(self.UPDATETASK, {id = taskid})
end

-- code = 0x2054 新任务(领奖后发送)
function SevenDaysManager:onReceiveNewTaskResult( event )
    -- print("----------------onReceiveSevenListResult")
    -- print(event.data)

    local tasklist = event.data.tasklist

    for k,v in pairs(tasklist) do
        self.taskStatusList:pushbyid(v.taskid, v)
    end

        
--     hideLoading()
--     AlertManager:close()
--     toastMessage("发送成功")
-- n = adad +1
end


-- code = 0x2055 通知成就进度变化
function SevenDaysManager:onReceiveSevenTaskProgress( event )

    print("------SevenDaysManager:onReceiveSevenTaskProgress-------")
    print("event.data = ",event.data)
    local taskid   = event.data.taskid
    local currstep = event.data.currstep
    local task = self.taskStatusList:objectByID(taskid)
    
    if task then
        task.currstep = currstep
    end

    TFDirector:dispatchGlobalEventWith(self.UPDATETASK, {id = taskid})
end

-- 查询折扣商品信息
-- code = 0x2060
function SevenDaysManager:onReceiveAlreadyBuyInfo(event)


    print("------SevenDaysManager:onReceiveAlreadyBuyInfo-------")

    hideLoading()

    -- 半价商店商品状态
    self.shopItemList:clear()

    local itemList = event.data.info

    for k,v in pairs(itemList) do
        self.shopItemList:pushbyid(v.id, v)
    end

    for v in sevenDaysConfig:iterator() do
        if v.type == 9999 then
            print("")
            local itemStatus = self.shopItemList:objectByID(v.reward_id)
            local itemInfo   = self.SevenDayShopConfig:objectByID(v.reward_id)
            if itemInfo and itemStatus then
                if itemInfo.max_num == itemStatus.number then
                    -- print("itemInfo = ", itemInfo)
                    -- print("itemStatus = ", itemStatus)
                    local task = self.taskStatusList:objectByID(v.id)
                    if task then
                        -- print("task = ",task)
                        task.state = 0
                    end
                end
            end
        end
    end


    self:enterSevenDaysLayer()
end

function SevenDaysManager:getShopItemInfo(shopItemId)

    -- required int32 id = 1;              //ID
    -- required int32 number = 2;          //已经被购买了多少

    local itemInfo = nil

    itemInfo = self.shopItemList:objectByID(shopItemId)

    return itemInfo
end



function SevenDaysManager:getTaskStauts(taskid)
    -- required int32 taskid = 1;    //成就id
    -- required int32 state = 2;     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    -- required int32 currstep = 3;  //当前进度
    -- required int32 totalstep = 4; //总进度
    local task = nil

    task = self.taskStatusList:objectByID(taskid)

    return task
end

function SevenDaysManager:filterTaskData(dayIndex)

    self.DayTaskData:clear()
    self.DayTaskTitle:clear()

    -- 
    for v in sevenDaysConfig:iterator() do
        if v.day == dayIndex  then
            self.DayTaskData:push(v)
        end
    end

    local titleType = 0
    for v in self.DayTaskData:iterator() do
        if v.tab ~= titleType then
            titleType = v.tab
            local titleInfo = {titleId = titleType, name = v.name}
            self.DayTaskTitle:push(titleInfo)
        end
    end

    -- -- 添加半价商店
    -- self.DayTaskTitle:push(16)

    -- print("self.DayTaskTitle = ", self.DayTaskTitle)
    -- print("self.DayTaskData = ", self.DayTaskData)
    -- -- 比较函数
    -- local function sortlist( v1,v2 )
    --     if v1.id < v2.id then
    --         return true
    --     end
    --     return false
    -- end

    -- self.SignRewardList:sort(sortlist)
end

function SevenDaysManager:getTitleWithDayIndex(dayIndex)
    local titleList = {}

    for v in self.DayTaskTitle:iterator() do
        table.insert(titleList, v.titleId)
    end

    return titleList --{1,2,3,4,20}
end

function SevenDaysManager:getTasksWithDayIndex(dayIndex, titleType)
    self.DayTaskDataWithTitle:clear()

    for v in self.DayTaskData:iterator() do
        if v.tab == titleType then
            self.DayTaskDataWithTitle:push(v)
            local task = nil
            task = self.taskStatusList:objectByID(v.id)
            if task then
                v.state = task.state
            end
        end
    end

    local function cmp1( num1 ,num2 )
        if num1 == 1 then
        return true
        end
        if num2 == 1 then
        return false
        end
        if num1 > num2 then
            return false
        end
        return true
    end

    -- int32 state = 2;     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    local function cmp(task1, task2)

        if task1.state ~= task2.state then
            return cmp1(task1.state,task2.state)
        end
        -- -- 返回true 不交换   返回false 交换
        -- if task1.state > task2.state then
        --     return true
        -- elseif task1.state < task2.state then
        --     return false
        -- end

        if task1.id < task2.id then
            return true
        end

        return false

    end

    if self.DayTaskDataWithTitle:length() > 1 then
        self.DayTaskDataWithTitle:sort(cmp)
    end

    return self.DayTaskDataWithTitle
end

function SevenDaysManager:getTitleName(titleType)
    local titleName = ""

    for v in self.DayTaskTitle:iterator() do
        if v.titleId == titleType then
            return v.name
        end
    end

    return titleName
end

function SevenDaysManager:getSevenDaysReward(taskid)
    showLoading()
    TFDirector:send(c2s.GET_SEVEN_DAYS_GOAL_TASK_REWARD, {taskid} )
end

function SevenDaysManager:queryShopItemStataus()
    showLoading()
    TFDirector:send(c2s.QUERY_DISCOUNT_SHOP_ITEM, {})
end

function SevenDaysManager:enterSevenDaysLayer()
    local status = self:sevenDaysOpenSatus()

    -- 判断在线奖励是否过期
    if status == 0 then
        print("七日活动过期")
        return
    end

    AlertManager:addLayerByFile("lua.logic.sevendays.SevenDaysLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    AlertManager:show()
end


function SevenDaysManager:showSevenDaysLayer()
    self:queryShopItemStataus()
end

function SevenDaysManager:checkRedPoint()

    for i=1,7 do
        if self:checkRedPointWithDayIndex(i) then
            return true
        end
    end


    return false
end


function SevenDaysManager:checkRedPointWithDayIndex(dayIndex)

    --     
    if dayIndex > MainPlayer:getRegisterDay() then
        return false
    end

    for v in sevenDaysConfig:iterator() do
        if v.day == dayIndex  then
            local task = nil
            task = self.taskStatusList:objectByID(v.id)
            if task and task.state == 1 then
                return true
            end
        end
    end

    return false

    -- int32 state = 2;     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
end

-- 
function SevenDaysManager:checkRedPointWithTitle(dayIndex, titleType)
    if dayIndex > MainPlayer:getRegisterDay() then
        return false
    end

    for v in sevenDaysConfig:iterator() do
        if v.day == dayIndex and v.tab == titleType then
            local task = nil
            task = self.taskStatusList:objectByID(v.id)
            if task and task.state == 1 then
                return true
            end
        end
    end

    return false
end


function SevenDaysManager:getSevenDaysStatus(dayIndex)

    if dayIndex <= MainPlayer:getRegisterDay() then
        return true
    else
        return false
    end

    -- print("MainPlayer:getRegisterDay() = ", MainPlayer:getRegisterDay())

    -- local secInOneDay = 24 * 60 * 60
    -- local nowTime    = MainPlayer:getNowtime()
    -- local registTime = MainPlayer.registTime

    -- local registTime = registTime + secInOneDay * dayIndex
    -- if registTime <= nowTime then
    --     return true
    -- end

    -- return false
end

function SevenDaysManager:getRegisterDay()

    local registerDay = MainPlayer:getRegisterDay()
    print("注册天数 = ", registerDay)

    -- if dayIndex > registerDay then
    --     return false
    -- end

    -- local secInOneDay = 24 * 60 * 60
    -- local nowTime    = MainPlayer:getNowtime()
    -- local registTime = MainPlayer.registTime

    -- local gapTime = nowTime - registTime

    -- local registerDay = math.ceil(gapTime/secInOneDay)

    -- return registerDay
end

-- 七天之内是开启的 0 关闭 ； 1 七天内 ； 2 过了七天 3天内
function SevenDaysManager:sevenDaysOpenSatus()
    -- local RegisterTime = MainPlayer:getRegisterTime()

    local RegisterTime = MainPlayer:ServerOpenTime()
    local nowTime      = MainPlayer:getNowtime()

    local secInOneDay  = 24 * 3600

    if RegisterTime == nil then
        return 0
    end

 --Modify by ZR ,临时关闭7天活动
  -- if nowTime > (RegisterTime + 10 * secInOneDay) then
   --     return 0 
  --  end


    if nowTime > (RegisterTime + 10 * secInOneDay) then
        return 0 
    end
--Modify by ZR



   if nowTime <= (RegisterTime + 7 * secInOneDay) then
        return 1
    end

   return 2

  
end

-- function SevenDaysManager:startSevenDaysTimer()
--     local status = self:sevenDaysOpenSatus()

--     if status == 0 then 

--     end
--         for v in self.SevenDaysTimerEvents:iterator() do
--         -- print("---v = ", v)
--         v.desc      = timedesc
--         v.timeCount = self.OnlineRewardData.timeCount
--         v.bPrize    = self.bOnlineRewardOnTime  --当前的在线奖励是否可领
--         if v.handler then
--             v.handler(v)
--         end
--     end
-- end

function SevenDaysManager:stopSevenDaysTimer()
    if self.SevenDaysTimer then
        TFDirector:removeTimer(self.SevenDaysTimer)
        self.SevenDaysTimer = nil
    end

    -- 清空倒计时奖励
    if self.SevenDaysTimerEvents then
        self.SevenDaysTimerEvents:clear()
    end
end

function SevenDaysManager:updateSevenDaysTimer()

    local status = self:sevenDaysOpenSatus()

    -- 判断在线奖励是否过期
    if status == 0 then
        self:stopSevenDaysTimer()
        return
    end

    -- local RegisterTime = MainPlayer:getRegisterTime()
    local RegisterTime = MainPlayer:ServerOpenTime()
    local nowTime      = MainPlayer:getNowtime()

    if status == 1 then
        RegisterTime = RegisterTime + 3600 * 24 * 7
    else
        RegisterTime = RegisterTime + 3600 * 24 * 10
    end

    local timeCount = RegisterTime - nowTime

    local secInOneDay  = 24 * 3600

    local day = math.floor(timeCount/secInOneDay)

    local sec   = timeCount - secInOneDay * day
    local time1 = math.floor(sec/3600)
    local time2 = math.floor((sec-time1 * 3600)/60)
    local time3 = math.fmod(sec, 60)

    -- local timedesc1 = string.format("%02d天%02d小时%02d分%02d秒", day, time1, time2, time3)
    day = string.format("%02d", day)
    time1 = string.format("%02d", time1)
    time2 = string.format("%02d", time2)
    time3 = string.format("%02d", time3)
    local timedesc1 = stringUtils.format(localizable.common_time_5, day, time1, time2, time3)

    sec   = timeCount
    time1 = math.floor(sec/3600)
    time2 = math.floor((sec-time1 * 3600)/60)
    time3 = math.fmod(sec, 60)
    local timedesc2 = string.format("%02d:%02d:%02d", time1, time2, time3)

    for v in self.SevenDaysTimerEvents:iterator() do
        v.status    = status
        v.desc1     = timedesc1
        v.desc2     = timedesc2

        if v.handler then
            v.handler(v)
        end
    end
end

-- 设置在线奖励回调
function SevenDaysManager:addSevenDaysEvent(logic, id, callback)

    local status = self:sevenDaysOpenSatus()

    -- 判断在线奖励是否过期
    if status == 0 then
        print("过期")
        self:stopSevenDaysTimer()
        return
    end

    if self.SevenDaysTimerEvents == nil then
        self.SevenDaysTimerEvents = TFMapArray:new()
        self.SevenDaysTimerEvents:clear()
    end

    if  self.SevenDaysTimer == nil then
        
        self.SevenDaysTimer = TFDirector:addTimer(1000, -1, nil, 
            function() 
                self:updateSevenDaysTimer()
            end)
    end

    local obj = self.SevenDaysTimerEvents:objectByID(id)
    
    if obj then
        obj.handler             = callback
        obj.logic               = logic
        -- self.SevenDaysTimerEvents:push(obj)
        print("---- 1 addSevenDaysEvent add = ".."id = "..id)
    else
        local timer = {}

        timer.id                = id
        timer.logic             = logic
        timer.handler           = callback
        self.SevenDaysTimerEvents:push(timer)
        print("---- 2 addSevenDaysEvent modify = ".."id = "..id)
    end
end

-- 停止在线奖励定时器
function SevenDaysManager:removeOnlineRewardTimer(id)
    if self.SevenDaysTimerEvents == nil then
        return
    end

    local obj = self.SevenDaysTimerEvents:objectByID(id)
    if obj then
        self.SevenDaysTimerEvents:removeInMapList(obj)
    end

    if self.SevenDaysTimerEvents:length() <= 0 and self.SevenDaysTimer then
        self:stopSevenDaysTimer()
    end
end

-- MainPlayer:getRegisterTime()

-- 显示栏目类型。
-- 1、每日福利
-- 2、主线副本(普通关卡)
-- 3、武学
-- 4、技能法术
-- 5、装备
-- 6、宗师关卡
-- 7、群豪谱
-- 8、无量山
-- 9、经脉/穴位
-- 10、雁门关
-- 11、宝石
-- 12、装备升星

-- 20 每日半价

return SevenDaysManager:new()