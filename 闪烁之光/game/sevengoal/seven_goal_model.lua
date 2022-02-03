-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
SevenGoalModel = SevenGoalModel or BaseClass()

local table_sort = table.sort
local table_insert = table.insert
local table_remove = table.remove
local charge_list = Config.DayGoalsNewData.data_charge_list
function SevenGoalModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function SevenGoalModel:config()
end

function SevenGoalModel:setInitSevenGoalData(data)
	self:setSevenGoalPeriod(data.period)
    self:setSevenGoalDay(data.cur_day)
    self:setSevenGoalLev(data.lev)
	self.seven_goal_data = {}
	
    local list = {} --累充
    local list1 = {}--普通
    --新版本的七天
    if charge_list[data.period] then
        for i,v in pairs(data.list) do
            local status = false
            for m,val in pairs(charge_list[data.period]) do
                if v.id == val.goal_id then
                    status = true
                    break
                end
            end
            if status == true then
                table_insert(list,v)
            else
                table_insert(list1,v)
            end
        end
        self:setSortItem(list)
        self:setChargeTotalData(list)

        -- -- 当为魔盒的时候
        if data.period == SevenGoalEntranceCycle.period_3 or data.period == SevenGoalEntranceCycle.period_6 or
           data.period == SevenGoalEntranceCycle.period_9 or data.period == SevenGoalEntranceCycle.period_11 or
           data.period == SevenGoalEntranceCycle.period_13 then
            --当全部领取完的时候
            local all_status = true
            for i,v in pairs(list) do
                if v.finish ~= 2 then
                    all_status = false
                    break
                end
            end
            if all_status == true then
                table_sort(list,function(a,b) return a.id > b.id end)
            end
            table_sort(list1,function(a,b) return a.id < b.id end)
        else
            self:setSortItem(list1)
        end
        
        --插入累充的任务
        local count = 1
        for i,v in ipairs(list1) do
            if v.finish == 2 then
                count = i
                break
            else
                count = i+1
            end
        end
        if list[1] then
            if list[1].finish == 1 then
                table_insert(list1,1,list[1])
            else
                table_insert(list1,count,list[1])
            end
        end
        self.seven_goal_data = list1
    end
end
function SevenGoalModel:getInitSevenGoalData()
	if not self.seven_goal_data or next(self.seven_goal_data) == nil then return nil end
	return self.seven_goal_data or {}
end
--更新内容
function SevenGoalModel:setInitDataUpdata(data)
    if not self.seven_goal_data or next(self.seven_goal_data) == nil then return end
    for i,v in ipairs(self.seven_goal_data) do
        for k,val in pairs(data) do
            if v.id == val.id then
                self.seven_goal_data[i] = val
            end
        end
    end
    self:updataChargeTotalData(data[1].id,data[1])

    local period = self:getSevenGoalPeriod()
    for i,v in pairs(self.seven_goal_data) do
        for m,val in pairs(charge_list[period]) do
            if v.finish == 2 and v.id == val.goal_id then
                --配置的位置，用来判断是否可以进行下一次充值
                local next_goal_id = val.id
       
                --如果本档次充值领取，就进入下一档次的累充
                local temp_id = val.goal_id
                for i,v in pairs(charge_list[period]) do
                    if v.id == next_goal_id+1 then
                        temp_id = v.goal_id
                        break
                    end
                end
                --下一个档次累充的ID
                local totle_list = self:getChargeTotalData(temp_id)
                if totle_list then
                    for i,v in ipairs(self.seven_goal_data) do
                        if v.id == val.goal_id then
                            self.seven_goal_data[i] = totle_list
                            break
                        end
                    end
                end
            end
        end
    end
    if period == SevenGoalEntranceCycle.period_3 or period == SevenGoalEntranceCycle.period_6 or period == SevenGoalEntranceCycle.period_9 or
       period == SevenGoalEntranceCycle.period_11 or period == SevenGoalEntranceCycle.period_13 then
    else
        self:setSortItem(self.seven_goal_data)
    end
end
--累充
function SevenGoalModel:setChargeTotalData(data)
    self.chargeTotalData = {}
    for i,v in pairs(data) do
        self.chargeTotalData[v.id] = v
    end
end
function SevenGoalModel:getChargeTotalData(id)
    if not self.chargeTotalData or next(self.chargeTotalData) == nil then return nil end
    return self.chargeTotalData[id] or {}
end
--更新累充数据
function SevenGoalModel:updataChargeTotalData(id,data)
    if not self.chargeTotalData or next(self.chargeTotalData) == nil then return end
    local status = false
    for i,v in pairs(self.chargeTotalData) do
        if v.id == data.id then
            status = true
            break
        end
    end
    if status == true then
        self.chargeTotalData[id] = data
    end
end
--获取累充的数字，以便知道当前周期充值了多少
function SevenGoalModel:getPeriodChargeTotalData()
    if not self.chargeTotalData then return {} end
    local list = {}
    for i,v in pairs(self.chargeTotalData) do
        table_insert(list,v)
    end
    table_sort(list,function(a,b) return a.id < b.id end)
    self:setSortItem(list)
    return list
end
function SevenGoalModel:setSortItem(data_list)
    local tempsort = {
        [0] = 2,
        [1] = 1,
        [2] = 3,
    }
    local function sortFunc(objA,objB)
        if objA.finish ~= objB.finish then
            if tempsort[objA.finish] and tempsort[objB.finish] then
                return tempsort[objA.finish] < tempsort[objB.finish]
            else
                return false
            end
        else
            return objA.id < objB.id
        end
    end
    table_sort(data_list, sortFunc)
end

function SevenGoalModel:setSevenGoalPeriod(peroid)
	self.peroid = peroid
end
function SevenGoalModel:getSevenGoalPeriod()
	return self.peroid or 2
end
function SevenGoalModel:setSevenGoalDay(day)
	self.day = day
end
function SevenGoalModel:getSevenGoalDay()
	return self.day or 1
end
function SevenGoalModel:setSevenGoalLev(lev)
    self.current_lev = lev
end
function SevenGoalModel:getSevenGoalLev()
    return self.current_lev or 1
end

--领取等级奖励
function SevenGoalModel:setSevenGoalLevData(data)
    self.lev_data = {}
    for i,v in pairs(data) do
        self.lev_data[v.id] = true
    end
    self:checkMainRedPoint()
end
function SevenGoalModel:getSevenGoalLevData(lev)
    if self.lev_data and self.lev_data[lev] then
        return self.lev_data[lev]
    end
    return false
end
--领取红点
function SevenGoalModel:setInitRedPoint()
    local red_status = false
    if self.seven_goal_data then
        for i,v in pairs(self.seven_goal_data) do
            if v.finish == 1 then
                red_status = true
                break
            end
        end
    end
    return red_status
end

--查看更多红点
function SevenGoalModel:setMoreResPoint()
    local lev_list = Config.DayGoalsNewData.data_make_lev_list
    local red_status = false
    if lev_list[self:getSevenGoalPeriod()] then
        for i,v in pairs(lev_list[self:getSevenGoalPeriod()]) do
            if self:getSevenGoalLevData(v.lev) == false and v.lev <= self:getSevenGoalLev() then
                red_status = true
                break
            end
        end
    end
    return red_status
end
--检查主场景红点
function SevenGoalModel:checkMainRedPoint()
    local red_status = false
    red_status = self:setMoreResPoint() or self:setInitRedPoint()
    
    local icon_id = SevenGoalEntranceID.period_1
    --魔盒秘密
    if self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_3 or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_6 or 
       self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_9 or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_11 or
       self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_13 then
        icon_id = SevenGoalEntranceID.period_2
    --冒险日记
    elseif self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_2 or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_5 
        or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_8 or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_10
        or self:getSevenGoalPeriod() == SevenGoalEntranceCycle.period_12 then
        icon_id = SevenGoalEntranceID.period_1
    end
    MainuiController:getInstance():setFunctionTipsStatus(icon_id, red_status)
end

function SevenGoalModel:__delete()
end