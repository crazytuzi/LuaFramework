--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令数据处理模块
-- @DateTime:    2019-04-19 10:07:59
-- *******************************

OrderActionModel = OrderActionModel or BaseClass()

local table_sort = table.sort
local table_insert = table.insert
local const_config = Config.HolidayWarOrderData.data_constant
function OrderActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function OrderActionModel:config()
	self:initTaskData()
end

function OrderActionModel:initTaskData()
	self.day_task_list = {} --每日任务
	self.week_task_list = {} --每周任务
	self.period_task_list = {} --周期任务
end

--任务归类
function OrderActionModel:setTaskInduct(period,day,index)
	if index == 1 then
		local day_list = Config.HolidayWarOrderData.data_day_task_list
		if day_list and day_list[period] then
			for i,v in pairs(day_list[period]) do
				if v.day == day then
					table_insert(self.day_task_list,v)
				end
			end
			table_sort(self.day_task_list,function(a,b) return a.goal_id < b.goal_id end)
		end
	elseif index == 2 then
		local week_list = Config.HolidayWarOrderData.data_week_task_list
		if week_list and week_list[period] then
			for i,v in pairs(week_list[period]) do
				if day >= v.min_day and day <= v.max_day then
					table_insert(self.week_task_list,v)
				end
			end
			table_sort(self.week_task_list,function(a,b) return a.goal_id < b.goal_id end)
		end
	elseif index == 3 then
		local period_list = Config.HolidayWarOrderData.data_period_task_list
		if period_list and period_list[period] then
			for i, v in pairs(period_list[period]) do
				table_insert(self.period_task_list,v)
			end
			table_sort(self.period_task_list,function(a,b) return a.goal_id < b.goal_id end)
		end
	end
end
function OrderActionModel:getTaskInduct(index)
	local list
	if index == 1 then
		list = self.day_task_list
	elseif index == 2 then
		list = self.week_task_list
	elseif index == 3 then
		list = self.period_task_list
	end
	if list and next(list) ~= nil then
		return list
	end
	return nil
end

--当前经验
function OrderActionModel:setCurExp(exp)
	self.cur_exp = exp
end
function OrderActionModel:getCurExp()
	if self.cur_exp then
		return self.cur_exp
	end
	return 1
end

--当前周期
function OrderActionModel:setCurPeriod(period)
	self.cur_period = period
end
function OrderActionModel:getCurPeriod()
	if self.cur_period then
		--存在在线时0点更新的时候出现断线会有周期替换的周期数不正确，，这时要判断主城图标来判断周期数
		-- local order_icon_6 = MainuiController:getInstance():getFunctionIconById(OrderActionEntranceID.entrance_id5)
		-- if order_icon_6 then
		-- 	self.cur_period = 6
		-- end
		-- local order_icon_7 = MainuiController:getInstance():getFunctionIconById(OrderActionEntranceID.entrance_id6)
		-- if order_icon_7 then
		-- 	self.cur_period = 7
		-- end
		-- local order_icon_8 = MainuiController:getInstance():getFunctionIconById(OrderActionEntranceID.entrance_id7)
		-- if order_icon_8 then
		-- 	self.cur_period = 8
		-- end
		local order_icon_9 = MainuiController:getInstance():getFunctionIconById(OrderActionEntranceID.entrance_id8)
		if order_icon_9 then
			self.cur_period = 9
		end
		local order_icon_10 = MainuiController:getInstance():getFunctionIconById(OrderActionEntranceID.entrance_id9)
		if order_icon_10 then
			self.cur_period = 10
		end
		return self.cur_period
	end
	return 3
end
--当前天数
function OrderActionModel:setCurDay(day)
	self.cur_day = day
end
function OrderActionModel:getCurDay()
	if self.cur_day then
		return self.cur_day
	end
	return 1
end
--当前等级
function OrderActionModel:setCurLev(lev)
	self.cur_lev = lev
end
function OrderActionModel:getCurLev()
	if self.cur_lev then
		return self.cur_lev
	end
	return 1
end

--是否激活特权
function OrderActionModel:setRMBStatus(status)
	self.rmb_status = status
end
function OrderActionModel:getRMBStatus()
	if self.rmb_status then
		return self.rmb_status
	end
	return 0
end

--是否领取额外礼包
function OrderActionModel:setExtraStatus(status)
	self.extra_status = status
end
function OrderActionModel:getExtraStatus()
	if self.extra_status then
		return self.extra_status
	end
	return 0
end

--是否已购买礼包
function OrderActionModel:setGiftStatus(data)
	if data and next(data) == nil then
		self.gift_status = nil
	end

	if self.gift_status and self.gift_status == 1 then return 1 end
	local charge_list = Config.ChargeData.data_charge_data
    local card_list = Config.HolidayWarOrderData.data_advance_card_list
    local period = self:getCurPeriod()
    if card_list and card_list[period] and card_list[period][1] then
        local charge_id = card_list[period][1].id or nil
        if charge_id then
            for i,v in pairs(data) do
            	if charge_id == v.id then
    				self.gift_status = v.status        		
            	end
            end
        end
    end	
end
function OrderActionModel:getGiftStatus()
	if self.gift_status then
		return self.gift_status
	end
	return 0
end

--等级奖励展示
function OrderActionModel:setLevShowData(data)
	self.lev_show_data = {}
	for i,v in pairs(data) do
		self.lev_show_data[v.id] = v
	end

	self:setRewardLevRedPoint()
end
function OrderActionModel:getLevShowData(lev)
	if self.lev_show_data and self.lev_show_data[lev] then
		return self.lev_show_data[lev]
	end
	return nil
end
--计算等级奖励的红点
function OrderActionModel:setRewardLevRedPoint()
	local status = false
	local reward_list = Config.HolidayWarOrderData.data_lev_reward_list
	local cur_lev = self:getCurLev()
	local cur_period = self:getCurPeriod()
	if self.lev_show_data and reward_list[cur_period] then
		for i,v in pairs(reward_list[cur_period]) do
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
	self:setMainTipsStatus(OrderActionView.reward_panel,status)
end
function OrderActionModel:getRewardLevRedPoint()
	if self.reward_red_point then
		return self.reward_red_point
	end
	return false
end

--任务的
function OrderActionModel:setInitTaskData(data)
	self:config()
	self.init_task_data = {}
	for i,v in pairs(data) do
		self.init_task_data[v.id] = v
	end
	self:setTaskRedPoint()
end
function OrderActionModel:getInitTaskData(id)
	if self.init_task_data and self.init_task_data[id] then
		return self.init_task_data[id]
	end
	return nil
end
--任务更新
function OrderActionModel:updataTeskData(data)
	if data and data.list then
		for i,v in pairs(data.list) do
			if self.init_task_data and self.init_task_data[v.id] then
				self.init_task_data[v.id] = v
			end
		end
	end
	self:setTaskRedPoint()
end
--计算任务的红点
function OrderActionModel:setTaskRedPoint()
	local status = false
	if self.init_task_data then
		for i,v in pairs(self.init_task_data) do
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
	self:setMainTipsStatus(OrderActionView.tesk_panel,status)
end
function OrderActionModel:getTaskRedPoint()
	if self.task_red_point then
		return self.task_red_point
	end
	return false
end
--主城红点
function OrderActionModel:setMainTipsStatus(id,status)
	local num = 0
    if status then 
        num = 1
    end
    local vo = {
        bid = id, 
        num = num
    }
	local main_id = OrderActionEntranceID.entrance_id
	if self:getCurPeriod() == 2 then
		main_id = OrderActionEntranceID.entrance_id1
	elseif self:getCurPeriod() == 3 then
		main_id = OrderActionEntranceID.entrance_id2
	elseif self:getCurPeriod() == 4 then
		main_id = OrderActionEntranceID.entrance_id3
	elseif self:getCurPeriod() == 5 then
		main_id = OrderActionEntranceID.entrance_id4
	elseif self:getCurPeriod() == 6 then
		main_id = OrderActionEntranceID.entrance_id5
	elseif self:getCurPeriod() == 7 then
		main_id = OrderActionEntranceID.entrance_id6
	elseif self:getCurPeriod() == 8 then
		main_id = OrderActionEntranceID.entrance_id7
	elseif self:getCurPeriod() == 9 then
		main_id = OrderActionEntranceID.entrance_id8
	elseif self:getCurPeriod() == 10 then
		main_id = OrderActionEntranceID.entrance_id9
	end 
	MainuiController:getInstance():setFunctionTipsStatus(main_id, vo)
end

function OrderActionModel:sortTeskItemList(list)
    local tempsort = {
        [0] = 2,  -- 0 未完成
        [1] = 1,  -- 1 已完成
        [2] = 3,  -- 2 已提交
    }
    local function sortFunc(objA,objB)
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

function OrderActionModel:__delete()
end