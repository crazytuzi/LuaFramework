--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归活动数据处理
-- @DateTime:    2019-12-13 17:13:08
-- *******************************
ReturnActionModel = ReturnActionModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort
function ReturnActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ReturnActionModel:config()
	self.item_list = {}
	self.return_redbag_data = {}
end


--设置回归礼包信息 --flag, "是否已领取（0：否，1：是)  endtime, "结束时间"
function ReturnActionModel:setActionGiftData(data)
	self.action_gift_data = data
	self:checkGiftRedPoint()
end

--获取回归礼包领取状态
function ReturnActionModel:getActionGiftStatus()
	local status = 0
	if self.action_gift_data then
		status = self.action_gift_data.flag
	end
	return status
end

--获取回归礼包结束时间
function ReturnActionModel:getActionGiftEndTime()
	local endtime = 0
	if self.action_gift_data then
		endtime = self.action_gift_data.endtime
	end
	return endtime
end

--回归礼包红点
function ReturnActionModel:checkGiftRedPoint()
	local is_open = self:returnActionIsOpen()
	if is_open then
		local status = false
		local gift_status = self:getActionGiftStatus()
		if gift_status == 0 then
			status = true
		end
		ReturnActionController:getInstance():setReturnActionTabStatus(ReturnActionConstants.ReturnActionType.privilege, status)
	end
end

--设置回归抽奖信息
function ReturnActionModel:setActionSummonData(data)
	self.action_summon_data = data
	self:checkSummonRedPoint()
end

--获取回归抽奖信息
function ReturnActionModel:getActionSummonData()
	return self.action_summon_data
end

--初始化回归抽奖道具数量信息
function ReturnActionModel:initActionSummonItem()
	if next(self.item_list or {}) == nil then
		self.item_list = {}
		local period = self:getActionPeriod()
		if Config.HolidayReturnNewData.data_summon and Config.HolidayReturnNewData.data_summon[period] then
			for i,v in pairs(Config.HolidayReturnNewData.data_summon[period]) do
				if self.item_list[v.type_id] and self.item_list[v.type_id].num then
					self.item_list[v.type_id].num = self.item_list[v.type_id].num + 1
					self.item_list[v.type_id].pro = self.item_list[v.type_id].pro + v.pro
					self.item_list[v.type_id].show_pro = v.show_pro
				else
					self.item_list[v.type_id] = {itemId = v.rewards[1][1],itemNum = v.rewards[1][2],cfg = v,num = 1,pro = v.pro,show_pro = v.show_pro}
				end
			end
		end
	end
end

--获取回归抽奖道具次数信息
function ReturnActionModel:getActionSummonItemNumById(item_id)
	for k,v in pairs(self.item_list) do
		if v.itemId == item_id then
			local count = self:getActionSummonItemCountByTypeId(k)
			return count,v.num
		end
	end
	return 0,0
end

--获取回归抽奖道具已抽取次数
function ReturnActionModel:getActionSummonItemCountByTypeId(type_id)
	if self.action_summon_data and self.action_summon_data.award_list then
		for k,v in pairs(self.action_summon_data.award_list) do
			if v.type_id == type_id then
				return v.get_count
			end
		end
	end
	return 0
end

--获取回归抽奖奖励列表
function ReturnActionModel:getActionSummonItemList()
	return self.item_list
end

--抽奖红点处理
function ReturnActionModel:checkSummonRedPoint()
	local is_open = self:returnActionIsOpen()
	if is_open and self.action_summon_data then
		local red_point = false
		if self.action_summon_data.draw_time<self.action_summon_data.limit_draw_time then
			if self.action_summon_data.free_time == 1 then
				red_point = true
			else
				local item_bid_cfg = Config.HolidayReturnNewData.data_constant["draw_item_cost"]
				if item_bid_cfg then
					local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_bid_cfg.val[1][1])
					if summon_have_num and summon_have_num >=item_bid_cfg.val[1][2] then
						red_point = true
					end
				end
			end
		end
		ReturnActionController:getInstance():setReturnActionTabStatus(ReturnActionConstants.ReturnActionType.summon, red_point)
	end
end


--设置回归任务信息
function ReturnActionModel:setActionTaskData(data)
	self.action_task_data = data
	self:checkTaskRedPoint()
end

--刷新回归任务信息
function ReturnActionModel:updateActionTaskData(data)
	if self.action_task_data and self.action_task_data.quest_list and data then
		for i,v in ipairs(self.action_task_data.quest_list) do
			if v.id == data.id then
				v.finish = data.finish
				v.target_val = data.target_val
				v.value = data.value
				break
			end
		end
	end
	self:checkTaskRedPoint()
end

--刷新回归任务信息
function ReturnActionModel:updateActionTaskDataById(data)
	if self.action_task_data and self.action_task_data.quest_list and data then
		for i,v in ipairs(self.action_task_data.quest_list) do
			if v.id == data.id then
				v.finish = 2
				v.target_val = data.target_val
				v.value = data.target_val
				break
			end
		end
	end
	self:checkTaskRedPoint()
	self:checkSummonRedPoint()--刷新召唤红点
end

--获取回归任务列表
function ReturnActionModel:getActionTaskQuestList()
	local quest_list = {}
	if self.action_task_data and self.action_task_data.quest_list then
		quest_list = self.action_task_data.quest_list
	end
	return quest_list
end


--根据周期和天数得到该显示的 Tab
function ReturnActionModel:getActionSubList(period, day)
	local holiday_data = Config.HolidayReturnNewData.data_action_holiday
	if holiday_data and holiday_data[period] then
		self.holiday_list = {}
		for i,v in pairs(holiday_data[period]) do
			if day >= v.min_day and day <= v.max_day then
				table_insert(self.holiday_list,v)
			end
		end
		table_sort(self.holiday_list, function(a,b) return a.camp_id < b.camp_id end)
		return self.holiday_list
	end
end

function ReturnActionModel:getReturnActionData(bid)
	if self.holiday_list then
		for k,v in pairs(self.holiday_list) do
			if v.camp_id == bid then
				return v
			end
		end
		return nil
	end
	return nil
end
--活动是否开启
function ReturnActionModel:setActionIsOpen(open)
	self.action_isopen = open
end
function ReturnActionModel:getActionIsOpen()
	if self.action_isopen then
		return self.action_isopen
	end
	return 0
end

--获取当前的周期
function ReturnActionModel:setActionPeriod(period)
	self.action_period = period
end
function ReturnActionModel:getActionPeriod()
	if self.action_period then
		return self.action_period
	end
	return 1
end
--获取当前的天数
function ReturnActionModel:setActionDay(day)
	self.action_day = day
end
function ReturnActionModel:getActionDay()
	if self.action_day then
		return self.action_day
	end
	return 1
end

--商店数据
function ReturnActionModel:setShopData()
	if self.shop_data then return end
	local shop_data = Config.HolidayReturnNewData.data_shop
	local period =  self:getCurPeriodByOtherRole()
	if period<=0 then--如果没有拿到周期数据 默认第一期
		period = 1
	end
	self.shop_data = {}
	if shop_data and shop_data[period] then
		for i,v in pairs(shop_data[period]) do
			table_insert(self.shop_data,v)
		end
		
		table_sort(self.shop_data, function(a,b) return a.id < b.id end)
	end
end
function ReturnActionModel:getShopData()
	if self.shop_data then
		return self.shop_data
	end
	return nil
end
function ReturnActionModel:setServerShopData(data)
	if data and data.buy_info then
		self.server_shop_data = {}
		for i,v in pairs(data.buy_info) do
			self.server_shop_data[v.id] = v
		end
	end
end
function ReturnActionModel:getServerShopData(id)
	if self.server_shop_data and self.server_shop_data[id] then
		return self.server_shop_data[id]
	end
	return nil
end
--回归活动是否开启
function ReturnActionModel:returnActionIsOpen()
	local is_open = self:getActionIsOpen()
	if is_open == 0 then
		return false
	end

	local data_info = Config.FunctionData.data_info
	if data_info and data_info[MainuiConst.icon.return_action] then
		local bool = MainuiController:getInstance():checkIsOpenByActivate(data_info[MainuiConst.icon.return_action].activate)
        if bool == false then
        	return false
        end
        return true
    end
    return false
end

--任务红点
function ReturnActionModel:checkTaskRedPoint()
	if not self.action_task_data then return end
	local is_open = self:returnActionIsOpen()
	if is_open and self.action_task_data.quest_list then
		local status = false
		for i,v in pairs(self.action_task_data.quest_list) do
			if v.finish == 1 then
				status = true
				break
			end
		end
		ReturnActionController:getInstance():setReturnActionTabStatus(ReturnActionConstants.ReturnActionType.task, status)
	end
end

--回归签到
function ReturnActionModel:setSignConfigData()
	local signin_data = Config.HolidayReturnNewData.data_signin
	local period =  self:getActionPeriod()
	if signin_data and signin_data[period] then
		self.sign_data = {}
		for i,v in pairs(signin_data[period]) do
			table_insert(self.sign_data,v)
		end
		table_sort(self.sign_data,function(a,b) return a.day < b.day end)
	end
end
function ReturnActionModel:getSignConfigData()
	if self.sign_data then
		return self.sign_data
	end
	return nil
end
function ReturnActionModel:setServerSignData(data)
	if data and data.status_list then
		self.server_sign_data = {}
		for i,v in pairs(data.status_list) do
			self.server_sign_data[v.day] = v
		end
		self:checkSignRedPoint()
	end
end
function ReturnActionModel:getServerSignData(day)
	if self.server_sign_data and self.server_sign_data[day] then
		return self.server_sign_data[day]
	end
	return nil
end
--更新数据
function ReturnActionModel:updataServerSignData(day)
	if self.server_sign_data and self.server_sign_data[day] then
		self.server_sign_data[day].status = 2
		self:checkSignRedPoint()
		self:checkSummonRedPoint()--刷新召唤红点
	end
end

--获取回归签到天数
function ReturnActionModel:getActionSignCurDay()
	local day = #self.server_sign_data or 1
	return day
end

--签到红点处理
function ReturnActionModel:checkSignRedPoint()
	if self.server_sign_data then
		local red_point = false
		for i,v in pairs(self.server_sign_data) do
			if v.status == 1 then
				red_point = true
				break
			end
		end
		ReturnActionController:getInstance():setReturnActionTabStatus(ReturnActionConstants.ReturnActionType.sign, red_point)
	end
end

-- 红包数据
function ReturnActionModel:setReturnRedbagData( data )
	self.return_redbag_data = data or {}
end

function ReturnActionModel:getReturnRedbagData(  )
	return self.return_redbag_data
end

-- 红包数量数据
function ReturnActionModel:setReturnRedbagNumData( data )
	self.return_redbag_Num_data = data
end

function ReturnActionModel:isCanGetRedbag(  )
	local is_can = true
	if self.return_redbag_Num_data and self.return_redbag_Num_data.get_num and self.return_redbag_Num_data.max_num then
		if self.return_redbag_Num_data.get_num >= self.return_redbag_Num_data.max_num then
			is_can = false
		end
	end
	return is_can
end

--获取活动剩余时间
function ReturnActionModel:getLessTime(  )
	local config = Config.HolidayReturnNewData.data_privilege
	local less_time = 0
	for k,v in pairs(config) do
		local start_time = v.start_time
		local end_time = v.end_time
		local  start_time_2  =  os.time{year = start_time[1], month = start_time[2], day = start_time[3], hour = start_time[4], min = start_time[5], sec = start_time[6]}
		local  end_time_2  =  os.time{year = end_time[1], month = end_time[2], day = end_time[3], hour = end_time[4], min = end_time[5], sec = end_time[6]}
		local cur_time = GameNet:getInstance():getTime()
		if end_time_2 > cur_time and cur_time > start_time_2 then
			less_time = 1
			break
		end
	end
	
	return less_time
end

--非回归玩家获取当前活动的周期
function ReturnActionModel:getCurPeriodByOtherRole(  )
	local period = 0
	local config = Config.HolidayReturnNewData.data_privilege
	for k,v in pairs(config) do
		local start_time = v.start_time
		local end_time = v.end_time
		local  start_time_2  =  os.time{year = start_time[1], month = start_time[2], day = start_time[3], hour = start_time[4], min = start_time[5], sec = start_time[6]}
		local  end_time_2  =  os.time{year = end_time[1], month = end_time[2], day = end_time[3], hour = end_time[4], min = end_time[5], sec = end_time[6]}
		local cur_time = GameNet:getInstance():getTime()
		if end_time_2 > cur_time and cur_time > start_time_2 then
			period = v.period
			break
		end
	end
	return period
end

function ReturnActionModel:__delete()
end