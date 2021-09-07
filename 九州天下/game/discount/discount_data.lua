DisCountData = DisCountData or BaseClass()

function DisCountData:__init()
	if DisCountData.Instance ~= nil then
		ErrorLog("[DisCountData] Attemp to create a singleton twice !")
	end
	self.phase_list = {}
	self.new_phase_list = {}
	self.discount_cfg = ConfigManager.Instance:GetAutoConfig("discountbuycfg_auto") or {}
	self.phase_cfg = self.discount_cfg.phase_cfg or {}
	self.item_cfg = self.discount_cfg.item_cfg or {}

	self.discount_list = {}
	self.old_phase_list = {}

	self.can_active = false
	self.active_state = false
	self.have_new_discount = false      --是否有新的一折抢购

	DisCountData.Instance = self
end

function DisCountData:__delete()
	DisCountData.Instance = nil
end

--获取阶段数
function DisCountData:GetPaseCount()
	return #self.phase_cfg
end

--获取阶段名字
function DisCountData:GetPhaseNameByPhase(phase)
	local name = ""
	for _, v in ipairs(self.phase_cfg) do
		if v.phase == phase then
			name = v.name
			break
		end
	end
	return name
end

function DisCountData:SetPhaseList(list)
	self.phase_list = list
	self:SetNewPhaseList(list)
end

function DisCountData:GetPhaseList()
	return self.phase_list
end

function DisCountData:GetNewPhaseList()
	return self.new_phase_list
end

--清除缓存表
function DisCountData:ClearDiscountList()
	self.discount_list = {}
end

function DisCountData:GetHaveNewDiscount()
	return self.have_new_discount
end

function DisCountData:SetHaveNewDiscount(state)
	self.have_new_discount = state
end

function DisCountData:SetNewPhaseList(list)
	--记录旧的表
	self.old_phase_list = self.new_phase_list
	self.new_phase_list = {}
	local server_time = TimeCtrl.Instance:GetServerTime()
	--先保存服务器发送过来的表
	for k1, v1 in ipairs(list) do
		if server_time < v1.close_timestamp then
			local temp_data1 = {}
			temp_data1.close_timestamp = v1.close_timestamp
			temp_data1.phase = k1 - 1
			temp_data1.phase_item_list = {}
			for k2, v2 in ipairs(v1.buy_count_list) do
				table.insert(temp_data1.phase_item_list, {buy_count = v2})
			end
			table.insert(self.new_phase_list, temp_data1)
		end
	end

	--在添加本地表
	for k, v in ipairs(self.new_phase_list) do
		local stage_list = self.phase_cfg[v.phase + 1]
		if nil ~= stage_list then
			v.active_level = stage_list.active_level
			v.last_time = stage_list.last_time
			v.phase_desc = stage_list.phase_desc
			v.model_show = stage_list.model_show
			v.special_show = stage_list.special_show
		end
	end

	--添加每个物品的数据
	for k1, v1 in ipairs(self.new_phase_list) do
		for k2, v2 in pairs(self.item_cfg) do
			if v2.phase == v1.phase then
				local phase_item_list = v1.phase_item_list
				local data = phase_item_list[v2.item_seq+1]
				data.seq = v2.seq
				data.item_seq = v2.item_seq
				data.price = v2.price
				data.show_price = v2.show_price
				data.buy_limit_count = v2.buy_limit_count
				data.reward_item = v2.reward_item
			end
		end
	end

	--清空每个阶段不存在的物品
	for k, v in ipairs(self.new_phase_list) do
		local phase_item_list = v.phase_item_list
		for i = #phase_item_list, 1, -1 do
			local data = phase_item_list[i]
			if nil == data.buy_limit_count then
				table.remove(phase_item_list, i)
			end
		end
	end

	--清除已经卖完的阶段
	for i = #self.new_phase_list, 1, -1 do
		local temp_phase_info = self.new_phase_list[i]
		if nil ~= temp_phase_info then
			for k, v in pairs(temp_phase_info) do
				if k == "phase_item_list" then
					local sell_out_count = 0
					for k1, v1 in ipairs(v) do
						if v1.buy_count >= v1.buy_limit_count then
							sell_out_count = sell_out_count + 1
						end
					end
					if sell_out_count >= #v then
						table.remove(self.new_phase_list, i)
						break
					end
				end
			end
		end
	end
	--判断是否有新的一折抢购
	self.have_new_discount = false
	if #self.old_phase_list < #self.new_phase_list then
		self.have_new_discount = true
	end
end

function DisCountData:CheckCanActive()
	local can_active = false
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = main_vo.level
	local server_time = TimeCtrl.Instance:GetServerTime()
	for k, v in ipairs(self.new_phase_list) do
		if can_active then
			break
		end
		if level >= v.active_level then
			if v.close_timestamp > server_time then
				for k1, v1 in ipairs(v.phase_item_list) do
					if v1.buy_count < v1.buy_limit_count then
						can_active = true
						break
					end
				end
			end
		end
	end
	return can_active
end

function DisCountData.SortList(tbl1, tbl2)
	if tbl1.is_sell_out == tbl2.is_sell_out then
		return tbl1.seq < tbl2.seq
	else
		return tbl1.is_sell_out < tbl2.is_sell_out
	end
end

--先记录刷新的列表
function DisCountData:SetRefreshList()
	self.discount_list = self.new_phase_list
end

--获取刷新后的列表（数据量无变化）
function DisCountData:GetRefreshList()
	if #self.discount_list <= 0 then
		self.discount_list = self.new_phase_list
	end
	for k, v in ipairs(self.discount_list) do
		local temp_phase_info = self.phase_list[v.phase + 1]
		if nil ~= temp_phase_info then
			for k1, v1 in ipairs(v.phase_item_list) do
				v1.buy_count = temp_phase_info.buy_count_list[k1]
			end
		end
	end
	return self.discount_list
end

function DisCountData:GetDiscountInfoByType(phase, init)
	local data = self.new_phase_list
	if not init then
		data = self:GetRefreshList()
	end
	data = data or {}
	for k,v in ipairs(data) do
		if phase == v.phase then
			return v, k
		end
	end
	return nil
end

--获取每个阶段对应的物品列表
function DisCountData:GetItemListByPhase(phase, init)
	local data = self.new_phase_list
	if not init then
		data = self:GetRefreshList()
	end
	data = data or {}
	for k,v in ipairs(data) do
		if phase == v.phase then
			return v.phase_item_list
		end
	end
	return {}
end

function DisCountData:SetCanActive(enable)
	self.can_active = enable
end

function DisCountData:GetCanActive()
	return self.can_active
end


function DisCountData:GetActiveState()
	return self.active_state
end

--设置当前一折抢购状态
function DisCountData:SetActiveState(state)
	self.active_state = state
end