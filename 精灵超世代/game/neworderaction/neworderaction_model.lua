-- --------------------------------------------------------------------
-- 全新战令（英灵战令）
--数据处理模块
-- @author: yuanqi@shiyue.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-02-20
-- --------------------------------------------------------------------
NeworderactionModel = NeworderactionModel or BaseClass()

local table_sort = table.sort
local table_insert = table.insert
local config = Config.HolidayNewWarOrderData
local const_config = config.data_constant
function NeworderactionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function NeworderactionModel:config()
    self:initTaskData()
end

function NeworderactionModel:initTaskData()
    self.day_task_list = {} --每日任务
    self.week_task_list = {} --每周任务
end

--任务归类
function NeworderactionModel:setTaskInduct(period, day, index)
    if index == 1 then
        local day_list = config.data_day_task_list
        local day_lev = self:getDayLev()
        if day_list and day_list[period] then
            for i, v in pairs(day_list[period]) do
                if v.day == day and day_lev >= v.min_lev and day_lev <= v.max_lev then
                    table_insert(self.day_task_list, v)
                end
            end
            table_sort(
                self.day_task_list,
                function(a, b)
                    return a.goal_id < b.goal_id
                end
            )
        end
    elseif index == 2 then
        local week_list = config.data_week_task_list
        local week_lev = self:getWeekLev()
        if week_list and week_list[period] then
            for i, v in pairs(week_list[period]) do
                if day >= v.min_day and day <= v.max_day and week_lev >= v.min_lev and week_lev <= v.max_lev then
                    table_insert(self.week_task_list, v)
                end
            end
            table_sort(
                self.week_task_list,
                function(a, b)
                    return a.goal_id < b.goal_id
                end
            )
        end
    end
end

function NeworderactionModel:getTaskInduct(index)
    local list
    if index == 1 then
        list = self.day_task_list
    elseif index == 2 then
        list = self.week_task_list
    end
    if list and next(list) ~= nil then
        return list
    end
    return nil
end

--当前经验
function NeworderactionModel:setCurExp(exp)
    self.cur_exp = exp
end

function NeworderactionModel:getCurExp()
    if self.cur_exp then
        return self.cur_exp
    end
    return 1
end

--当前周期
function NeworderactionModel:setCurPeriod(period)
    self.cur_period = period
end

--获取当前周期
function NeworderactionModel:getCurPeriod()
    if self.cur_period then
        return self.cur_period
    end
    return 1
end

--当前天数
function NeworderactionModel:setCurDay(day)
    self.cur_day = day
end

function NeworderactionModel:getCurDay()
    if self.cur_day then
        return self.cur_day
    end
    return 1
end

--当前等级
function NeworderactionModel:setCurLev(lev)
    self.cur_lev = lev
end

function NeworderactionModel:getCurLev()
    if self.cur_lev then
        return self.cur_lev
    end
    return 1
end

function NeworderactionModel:getJumpNum()
end

--是否激活特权
function NeworderactionModel:setRMBStatus(status)
    self.rmb_status = status
    self:setRewardLevRedPoint()
end

function NeworderactionModel:getRMBStatus()
    if self.rmb_status then
        return self.rmb_status
    end
    return 0
end

--是否已购买礼包
function NeworderactionModel:setGiftStatus(data)
    if data and next(data) == nil then
        self.gift_status = nil
    end

    if self.gift_status and self.gift_status == 1 then
        return 1
    end
    local charge_list = Config.ChargeData.data_charge_data
    local card_list = config.data_advance_card_list
    local period = self:getCurPeriod()
    if card_list and card_list[period] and card_list[period] then
        local charge_id = card_list[period].id or nil
        if charge_id then
            for i, v in pairs(data) do
                if charge_id == v.id then
                    self.gift_status = v.status
                end
            end
        end
    end
end

function NeworderactionModel:getGiftStatus()
    if self.gift_status then
        return self.gift_status
    end
    return 0
end

--等级奖励展示
function NeworderactionModel:setLevShowData(data)
    self.lev_show_data = {}
    for i, v in pairs(data) do
        self.lev_show_data[v.id] = v
    end
    self:setRewardLevRedPoint()
    self:setTaskRedPoint()
end

function NeworderactionModel:getLevShowData(lev)
    if self.lev_show_data and self.lev_show_data[lev] then
        return self.lev_show_data[lev]
    end
    return nil
end

-- 周期开始等级
function NeworderactionModel:setPeriodLev(period_lev)
    self.period_lev = period_lev
end

function NeworderactionModel:getPeriodLev()
    if self.period_lev then
        return self.period_lev
    end
    return 1
end

-- 天开始等级
function NeworderactionModel:setDayLev(day_lev)
    self.day_lev = day_lev
end

function NeworderactionModel:getDayLev()
    if self.day_lev then
        return self.day_lev
    end
    return 1
end

-- 周开始等级
function NeworderactionModel:setWeekLev(week_lev)
    self.week_lev = week_lev
end

function NeworderactionModel:getWeekLev()
    if self.week_lev then
        return self.week_lev
    end
    return 1
end

function NeworderactionModel:getDayTaskEndTime()
    local end_time = 0
    for k, v in pairs(self.day_task_list) do
        local task_data = self:getInitTaskData(v.goal_id)
        if task_data and task_data.end_time and (task_data.end_time < end_time or end_time == 0) then
            end_time = task_data.end_time
        end
    end
    return end_time
end

function NeworderactionModel:getWeekTaskEndtime()
    local end_time = 0
    for k, v in pairs(self.week_task_list) do
        local task_data = self:getInitTaskData(v.goal_id)
        if task_data and task_data.end_time and (task_data.end_time < end_time or end_time == 0) then
            end_time = task_data.end_time
        end
    end
    return end_time
end

--计算等级奖励的红点
function NeworderactionModel:setRewardLevRedPoint()
    local status = false
    local reward_list = config.data_lev_reward_list
    local cur_lev = self:getCurLev()
    local cur_period = self:getCurPeriod()
    if self.lev_show_data and reward_list[cur_period] and not self:checkIsGetAll() then
        for i, v in pairs(reward_list[cur_period]) do
            if v.lev <= cur_lev then
                local status1 = false
                local data = self:getLevShowData(v.lev)
                if data then
                    if self:getRMBStatus() == 1 then --激活的时候
                        if data.rmb_status == 1 and data.status == 1 then
                            status1 = false
                        else
                            status1 = true
                        end
                    else
                    end
                else
                    if reward_list[cur_period][v.lev] and reward_list[cur_period][v.lev].reward and reward_list[cur_period][v.lev].reward[1] then
                        status1 = true
                    end
                end

                if status1 == true then
                    status = true
                    break
                end
            end
        end
    end
    self.reward_red_point = status
    self:setMainTipsStatus(NewOrderActionView.reward_panel, status)
end

function NeworderactionModel:checkIsGetAll()
    local reward_list = config.data_lev_reward_list
    local cur_period = self:getCurPeriod()
    local award_cfg_list = {}
    if reward_list and reward_list[cur_period] then
        local award_cfg = reward_list[cur_period]
        for k, v in pairs(award_cfg) do
            table_insert(award_cfg_list, v)
        end
    end
    if self.lev_show_data ~= nil then
        if #self.lev_show_data >= #award_cfg_list then
            return true
        end
    end
    return false
end

function NeworderactionModel:getRewardLevRedPoint()
    if self.reward_red_point then
        return self.reward_red_point
    end
    return false
end

--任务的
function NeworderactionModel:setInitTaskData(data)
    self:config()
    self.init_task_data = {}
    for i, v in pairs(data) do
        self.init_task_data[v.id] = v
    end
    self:setTaskRedPoint()
end

function NeworderactionModel:getInitTaskData(id)
    if self.init_task_data and self.init_task_data[id] then
        return self.init_task_data[id]
    end
    return nil
end

--任务更新
function NeworderactionModel:updataTaskData(data)
    if data and data.list then
        for i, v in pairs(data.list) do
            if self.init_task_data and self.init_task_data[v.id] then
                self.init_task_data[v.id] = v
            end
        end
    end
    self:setTaskRedPoint()
end

--计算任务的红点
function NeworderactionModel:setTaskRedPoint()
    local status = false
    if not self:checkIsGetAll() then
        if self.init_task_data then
            for i, v in pairs(self.init_task_data) do
                if v.finish == 1 then
                    status = true
                    break
                end
            end
        end
        self.task_red_point = status
    
        local lev = self:getCurLev()
        local rmb_status = self:getRMBStatus()
        if const_config and const_config["war_order_levmax"] then
            if lev >= const_config["war_order_levmax"].val and rmb_status == 1 then
                status = false
            end
        end
    end
    self:setMainTipsStatus(NewOrderActionView.task_panel, status)
end

function NeworderactionModel:getTaskRedPoint()
    if self.task_red_point then
        return self.task_red_point
    end
    return false
end

--主城红点
function NeworderactionModel:setMainTipsStatus(id, status)
    local num = 0
    if status or self:getPeriodRed() then
        num = 1
    end
    local vo = {
        bid = id,
        num = num
    }
    local main_id = NewOrderActionEntranceID.entrance_id
    MainuiController:getInstance():setFunctionTipsStatus(main_id, vo)
end

function NeworderactionModel:sortTaskItemList(list)
    local tempsort = {
        [0] = 2, -- 0 未完成
        [1] = 1, -- 1 已完成
        [2] = 3 -- 2 已提交
    }
    local function sortFunc(objA, objB)
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.goal_id < objB.goal_id
        end
    end
    table_sort(list, sortFunc)
end

-- 设置周期重置红点
function NeworderactionModel:setPeriodRed(bool)
    self.period_red = bool
end

function NeworderactionModel:getPeriodRed()
    if self.period_red then
        return self.period_red
    end
    return false
end

function NeworderactionModel:__delete()
end
