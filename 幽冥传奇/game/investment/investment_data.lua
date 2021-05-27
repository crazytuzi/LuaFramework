------------------------------------------------------------
-- 超值投资数据
------------------------------------------------------------

InvestmentData = InvestmentData or BaseClass()

InvestmentData.NOREWARD = "noreward"
InvestmentData.RewardChange = "investment_reward_change"
InvestmentData.Everyrebate = "Investment_everyrebate"

function InvestmentData:__init()
    if InvestmentData.Instance then
        ErrorLog("[IndicatorData]:Attempt to create singleton twice!")
    end
    InvestmentData.Instance = self
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

    self.pingji_list = nil
    self.daliy_list = nil
    
    self.daliy_all_received = true
    self.vip_all_received = true
    self.power_all_received = true
    self.is_close = true --是否关闭视图

    self.luxury_gifts_sign = {} -- 天天充值豪礼标记
    self.luxury_gifts_pay_day = 0 -- 天天充值豪礼充值天数

    self:InitCfg()
    -- self:SetPingjiList()
    self.rebate_every_day_info = {render_list = {}}

    GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.InvestmentReward, BindTool.Bind(self.CheckInvestmentReward, self))
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.Investment)
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.EveryDayRebate)
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.LuxuryGifts)
end

function InvestmentData:__delete()
    InvestmentData.Instance = nil
end

function InvestmentData:InitCfg()
	self.extra_list = {}
	local vip_award_cfg = {}
	for i,v in ipairs(InvestmentCfg.vipAwards) do
		vip_award_cfg[i] = {}
		vip_award_cfg[i].viplvLimt = v.viplvLimt
		vip_award_cfg[i].award = {}
		for i2,v2 in ipairs(v.award) do
			vip_award_cfg[i].award[i2] = ItemData.InitItemDataByCfg(v2)
		end
	end

	local power_award_cfg = {}
	for i,v in ipairs(InvestmentCfg.powerAwards) do
		power_award_cfg[i] = {}
		power_award_cfg[i].powerLimit = v.powerLimit
		power_award_cfg[i].award = {}
		for i2,v2 in ipairs(v.award) do
			power_award_cfg[i].award[i2] = ItemData.InitItemDataByCfg(v2)
		end
	end

	local count = math.max(#vip_award_cfg, #power_award_cfg)
	for i = 1, count do
		self.extra_list[i] = {}
		self.extra_list[i].vip_award_cfg = vip_award_cfg[i]
		self.extra_list[i].power_award_cfg = power_award_cfg[i]
		self.extra_list[i].index = i
	end
end

-- function InvestmentData:SetPingjiList()
-- 	self.pingji_list = {}
-- 	for k, v in pairs(InvestmentCfg.showItem) do
-- 		if type(v) == "table" then
-- 			table.insert(self.pingji_list, ItemData.FormatItemData(v))
-- 		end
-- 	end
-- 	if not self.pingji_list[0] and self.pingji_list[1] then
-- 		self.pingji_list[0] = table.remove(self.pingji_list, 1) 	--girdscorll网格下标从0开始，table下标从1开始，为了适配将table下标前移操作
-- 	end 
-- end

-- function InvestmentData:GetPingjiList()
-- 	return self.pingji_list
-- end

local function sort_reward(a,b)
		if a.isReceive ~= b.isReceive then
			return a.isReceive == 0 and b.isReceive == 1
		else
			return a.day < b.day
		end
	end

local function sort_extra_reward(a,b)
			local bool = false
			if a.vip_is_received ~= b.vip_is_received or a.power_is_received ~= b.power_is_received then
				if a.vip_is_received == 1 and a.power_is_received == 1 then
					bool = false
				elseif b.vip_is_received == 1 and b.power_is_received == 1 then
					bool = true
				else
					bool = a.index < b.index
				end
			else
				bool = a.index < b.index
			end
			return bool
		end

function InvestmentData:SetDaliyList(protocol)
	self.daliy_all_received = true
	self.vip_all_received = true
	self.power_all_received = true

	self.daliy_list = {}
	for k,v in pairs(InvestmentCfg.awards)do
		self.daliy_list[k] = {}
		if type(v) == "table" then
			self.daliy_list[k].awards = {}
			for k1,v1 in pairs(v) do
				if type(v1) == "table" then
					table.insert(self.daliy_list[k].awards, ItemData.FormatItemData(v1))
				end
			end
		end
		self.daliy_list[k].day = k
	end

	local login_mark = bit:d2b(protocol.login_mark)
	self.canReceived = protocol.login_day_count
	for k,v in pairs(self.daliy_list) do
		self.daliy_list[k].isReceive = login_mark[32 - k]
		if self.daliy_list[k].isReceive == 0 then
			self.daliy_all_received = false
		end
	end

	local vip_mark = bit:d2b(protocol.vip_mark)
	local power_mark = bit:d2b(protocol.power_mark)
	for i,v in ipairs(self.extra_list) do
		v.vip_is_received = vip_mark[32 - v.index]
		v.power_is_received = power_mark[32 - v.index]
		if v.vip_award_cfg ~= nil then
			if v.vip_is_received == 0 then
				self.vip_all_received = false
			end
		else
			v.vip_is_received = 1
		end
		if v.power_award_cfg ~= nil then
			if v.power_is_received == 0 then
				self.power_all_received = false
			end
		else
			v.power_award_cfg = 1
		end
	end
	
	self.is_close = self.daliy_all_received and self.vip_all_received and self.power_all_received
	if login_mark[32] == 1 then
		self.is_active = true  
	else
		self.is_active = false
	end
	if self.is_close then
		GameCondMgr.Instance:CheckCondType(GameCondType.InvestmentReward)

		local view_def = ViewDef.Investment.Investment
		GameCondMgr.Instance:Check(view_def.v_open_cond)
	end
	table.sort(self.daliy_list, sort_reward)
	table.sort(self.extra_list, sort_extra_reward)
	self:DispatchEvent(InvestmentData.RewardChange)


	local func = function ()
		InvestmentCtrl.RequestInvestmentInfo(1)
	end
	
	-- 未开放时,监听充值金额
	if not self.is_active then
		GlobalEventSystem:Bind(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, func)
	end

	-- 已开放且已未领完奖励时,监听跨天
	if self.is_active and not self.is_close then
		local flush_remind = function ()
			RemindManager.Instance:DoRemind(RemindName.Investment)
		end

		GlobalEventSystem:Bind(OtherEventType.PASS_DAY, flush_remind)

		-- vip奖励未领完时,监听vip等级
		if not self.vip_all_received then
			VipData.Instance:AddEventListener(VipData.VIP_INFO_EVENT, flush_remind)
		end

		-- 战力奖励未领完时,监听战力
		if not self.power_all_received then
			RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_BATTLE_POWER, flush_remind)
		end
	end
end

function InvestmentData:IsActive()
	return self.is_active  --活动是否激活
end

function InvestmentData:GetCanReceivedNum()
	return math.min(self.canReceived, #InvestmentCfg.awards) 		--累计登陆天数
end

function InvestmentData:IsCloseView()
	return self.is_close 		--奖励全部领取后关闭页面
end

function InvestmentData:GetHasReceivedNum()
	self.hasReceived = 0
	for k,v in pairs(self.daliy_list) do
		if (self.daliy_list[k].isReceive == 1) then   --已经领取
			self.hasReceived = self.hasReceived + 1
		end
	end
	return self.hasReceived
end

function InvestmentData:SetDaliyData(protocol)
	self.is_close = true
	if protocol.op_type == 2 then
		for k,v in pairs(self.daliy_list) do 
			if v.day == protocol.award_index then
				v.isReceive = 1
			end
			if self.daliy_list[k].isReceive == 0 then
				self.daliy_all_received = false
			end
		end
	elseif protocol.op_type == 3 then
		for i,v in ipairs(self.extra_list or {}) do
			if v.index == protocol.award_index then
				v.vip_is_received = 1
			end
			if v.vip_award_cfg ~= nil then
				if v.vip_is_received == 0 then
					self.vip_all_received = false
				end
			end
		end
	elseif protocol.op_type == 4 then
		for i,v in ipairs(self.extra_list or {}) do
			if v.index == protocol.award_index then
				v.power_is_received = 1
			end
			if v.power_award_cfg ~= nil then
				if v.power_is_received == 0 then
					self.power_all_received = false
				end
			end
		end
	end

	self.is_close = self.daliy_all_received and self.vip_all_received and self.power_all_received
	if self.is_close then
		GameCondMgr.Instance:CheckCondType(GameCondType.InvestmentReward)
	end
	table.sort(self.daliy_list, sort_reward)
	table.sort(self.extra_list, sort_extra_reward)
	self:DispatchEvent(InvestmentData.RewardChange)
end

function InvestmentData:GetDaliyList()
	return self.daliy_list
end

function InvestmentData:GetExtraList()
	return self.extra_list
end

function InvestmentData:GetRemindNum(remind_name)
	if remind_name == RemindName.Investment then
		if not InvestmentData.Instance:IsActive() then return 0 end

		if (not self.daliy_all_received) or (not self.power_all_received) then
			local vip_lv = VipData.Instance:GetVipLevel()
			local power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)
			local cfg
			for i,v in ipairs(self.extra_list) do
				if v.vip_award_cfg ~= nil then
					if v.vip_is_received == 0 then
						cfg = v.vip_award_cfg
						if vip_lv >= cfg.viplvLimt then
							return 1
						end
					end
				end

				if v.power_award_cfg ~= nil then
					if v.power_is_received == 0 then
						cfg = v.power_award_cfg
						if power >= cfg.powerLimit then
							return 1
						end
					end
				end
			end
		end

		if not self.daliy_all_received then
			if(self:GetHasReceivedNum() < self:GetCanReceivedNum()) then
				return 1
			end
		end

		return 0
	elseif remind_name == RemindName.EveryDayRebate then
		for k, v in pairs(self.rebate_every_day_info.render_list) do
			if v.btn_state == 0 then
				return 1
			end

		end
		return 0

	elseif remind_name == RemindName.LuxuryGifts then
		return InvestmentData.GetLuxuryGiftsRemindIndex()
	end
end

function InvestmentData:CheckInvestmentReward(param)
	return not self.is_close 
end

function InvestmentData:GetInvestmentIconOpen()
	if not IS_AUDIT_VERSION then
		if self.is_close ~= true then
			return true
		else
			return false
		end
	else
		return false
	end
end

function InvestmentData:RebateStaticData()
	return {
		index = 0,
		need_charge_day = 0,
		award_list = {},
		btn_state = 0,
	}
end

-- 天天返利信息
function InvestmentData:SetRebateEveryDayInfo(protocol)
	self.rebate_every_day_is_open = false

	local cfg = EveryDayBackCfg and EveryDayBackCfg.AwardList
	if nil == cfg then return end
	local need_level = EveryDayBackCfg.needLevel
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local receive_state_list1 = bit:d2b(protocol.charge_state1)
	local receive_state_list2 =	bit:d2b(protocol.charge_state2)
	local charge_day = protocol.pay_money_day
	for k, v in pairs(cfg) do
		local rebate_data = self:RebateStaticData()
		for k1, v1 in pairs(v) do
			table.insert(rebate_data.award_list, ItemData.InitItemDataByCfg(v1))
		end
		rebate_data.index = k
		rebate_data.need_charge_day = k
		if need_level > role_level or charge_day < k then
			rebate_data.btn_state = 1
			self.rebate_every_day_is_open = true
		else
			local bool = false
			if k <= 32 then
				bool = receive_state_list1[#receive_state_list1 - k + 1] == 0
			else
				bool = receive_state_list2[(#receive_state_list1 + #receive_state_list2) - k + 1] == 0
			end

			rebate_data.btn_state = bool and 0 or 2

			if bool then
				self.rebate_every_day_is_open = true
			end
		end
		self.rebate_every_day_info.render_list[k] = rebate_data
	end

	RemindManager.Instance:DoRemind(RemindName.EveryDayRebate)
	self:DispatchEvent(InvestmentData.Everyrebate)
end

function InvestmentData:GetRebateEveryDayIsOpen()
	return self.rebate_every_day_is_open
end

-- 天天返利列表数据
function InvestmentData:GetRebateEveryDayDataList()
	local temp_data_list = DeepCopy(self.rebate_every_day_info.render_list)
	table.sort(temp_data_list, function(a, b)
			if a.btn_state ~= b.btn_state then
				return a.btn_state < b.btn_state
			else
				return a.index < b.index
			end
		end)
	return temp_data_list
end

-- 获取天天返利极品奖励显示
function InvestmentData:GetGourmetShow()
	local vip_award_cfg = {}

	local item_1 = {}
	local item_2 = {}
	for k1, v1 in pairs(EveryDayBackCfg.ShowItem) do
		if k1 % 2 == 0 then
			table.insert(item_2, ItemData.InitItemDataByCfg(v1))
		else
			table.insert(item_1, ItemData.InitItemDataByCfg(v1))
		end
	end

	for i = 1, math.ceil(#EveryDayBackCfg.ShowItem/2) do
		vip_award_cfg[i] = {}
		vip_award_cfg[i].item_1 = item_1[i]
		vip_award_cfg[i].item_2 = item_2[i]
	end

	return vip_award_cfg
end

function InvestmentData:SetLuxuryGiftsSign(protocol)
	self.luxury_gifts_sign = bit:d2b(protocol.sign, true)
	self.luxury_gifts_pay_day = protocol.pay_money_day
	self:DispatchEvent(InvestmentData.Everyrebate)
	RemindManager.Instance:DoRemind(RemindName.LuxuryGifts)
end

function InvestmentData:GetLuxuryGiftsSign(index)
	if index then
		return self.luxury_gifts_sign[65 - index]
	else
		return self.luxury_gifts_sign
	end
end

function InvestmentData:GetLuxuryGiftsCurIndex()
	local count = 0
	for i,v in ipairs(self.luxury_gifts_sign) do
		if v == 1 then
			count = count + 1
		end
	end

	return count
end

function InvestmentData:GetLuxuryGiftsPayDay()
	return self.luxury_gifts_pay_day
end

function InvestmentData.GetLuxuryGiftsRemindIndex()
	local luxury_gifts_pay_day = InvestmentData.Instance:GetLuxuryGiftsPayDay()
	local luxury_gifts_cur_index = InvestmentData.Instance:GetLuxuryGiftsCurIndex()
	local index = luxury_gifts_pay_day > luxury_gifts_cur_index and 1 or 0

	return index
end