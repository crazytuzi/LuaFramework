ChargeRewardData = ChargeRewardData or BaseClass()

function ChargeRewardData:__init()
	if ChargeRewardData.Instance then
		ErrorLog("[ChargeRewardData] Attemp to create a singleton twice !")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	ChargeRewardData.Instance = self
	self.charge_award_sign = 0
	self.charge_day_list = {}
	self.first_charge_state_list = {0, 0, 0}
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.FirstChargeIsAllGet, BindTool.Bind(self.CheckFirstChargeIsAllGet, self))
end

function ChargeRewardData:__delete()
	ChargeRewardData.Instance = nil
end

ChargeRewardData.EverydayDataChangeEvent = "everyday_data_change_event"
ChargeRewardData.FirstDataChangeEvent = "first_data_change_event"

--------------------------------------
-- 协议
--------------------------------------
function ChargeRewardData:SetFirstChargeState(protocol)
	self.first_charge_state_tag = protocol.first_charge_state
	local first_charge_state1 = bit:_and(7, self.first_charge_state_tag)
	local first_charge_state2 = bit:_and(7, bit:_rshift(self.first_charge_state_tag, 8))
	local temp_state_list = bit:d2b(first_charge_state2)
	for i = 1, 3 do
		if i <= first_charge_state1 then
			self.first_charge_state_list[i] = temp_state_list[#temp_state_list - i + 1] + 1
		end
	end

	self:DispatchEvent(ChargeRewardData.FirstDataChangeEvent)
	GameCondMgr.Instance:CheckCondType(GameCondType.FirstChargeIsAllGet)
end

function ChargeRewardData:SetChargeEveryDayState(protocol)
	self.every_day_info = {}
	self.every_day_info.receive_state = protocol.receive_state
	self.every_day_info.today_charge_money = protocol.today_charge_money
	self:DispatchEvent(ChargeRewardData.EverydayDataChangeEvent)
end

function ChargeRewardData:SetChargeEveryDayTreasureState(protocol)
	if protocol.data_type == 1 then
		self.treasure_total_grade = protocol.treasure_total_grade
		self.charge_day_list = protocol.charge_day_list
		self:DispatchEvent(ChargeRewardData.EverydayDataChangeEvent)
	elseif protocol.data_type == 2 then
		local award = ActivityGiftConfig.hundredReward[protocol.award_index].award[1]
		local item_name = ItemData.Instance:GetItemName(award.id)
		SysMsgCtrl.Instance:FloatingTopRightText("获得物品" .. item_name)
	end
end

-- function ChargeRewardData:GetContinuousChargeDay()
-- 	return self.charge_day or 0
-- end

function ChargeRewardData:GetEveryDayTreasureState()
	-- local reverse_state = bit:d2b(self.charge_treasure_state)
	-- local positive_state = {}
 --    for i = 1, #reverse_state do  
 --        local key = #reverse_state
 --        positive_state[i] = table.remove(reverse_state)
 --    end
	-- return positive_state
	for k, v in pairs(self.charge_day_list) do
		if 0 ~= v then
			return v
		end
	end
	return 0
end


function ChargeRewardData:IsShouChong()
	if self:GetFirstChargeIsAllGet() then
		return true
	end
	for k, v in pairs(self.first_charge_state_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

--得到当前档位是否已领取
function ChargeRewardData:GetChargeRewardHadGet(index)
	local data = self.first_charge_state_list[index]
	if data and data == 2 then
		return true
	end
	return false
end
-- function ChargeRewardData:GetEveryDayTreasureGrade()
-- 	for k, v in pairs(self.charge_day_list) do 
-- 		if 0 ~= v then
-- 			return k
-- 		end
-- 	end
-- end

-- function ChargeRewardData:GetFirstChargeIconOpen()
-- 	-- return self.first_charge_state_tag ~= 2
-- 	for k, v in pairs(self.first_charge_state_list) do
-- 		if 0 ~= v then return true end
-- 	end
-- 	return false
-- end

-- function ChargeRewardData:GetEveryDayChargeIconOpen()
-- 	return not self:GetFirstChargeIconOpen() and not self:GetEveryDayChargeIsAllGet()
-- end

--------------------------------------
-- 首充
--------------------------------------
-- function ChargeRewardData:GetWuqiResId(index, profession_id)
-- 	local item_id = 0
-- 	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift and ActivityGiftConfig.RechargeGift[1] and ActivityGiftConfig.RechargeGift[1].rewardGrade[index].award
-- 	if nil == cfg then return end
-- 	for i=1,3 do
-- 		if cfg[i] and cfg[i].job == profession_id then
-- 			item_id = cfg[i].id or item_id
-- 			break
-- 		end
-- 	end
-- 	if item_id == 832 then
-- 		return 1010
-- 	elseif item_id == 833 then
-- 		return 1020
-- 	elseif item_id == 834 then
-- 		return 1030
-- 	end
-- end

function ChargeRewardData:GetWuqiResId(index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if 1 == index then
		if 1 == prof then
			return 264
		elseif 2 == prof then
			return 265
		else
			return 266
		end
	elseif 2 == index then
		return 267
	else
		return 70
	end
end

-- function ChargeRewardData:GetFirstChargeRewardData()
-- 	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
-- 	if not cfg or not cfg[1] or not cfg[1].reward then return end
-- 	local prof = RoleData.Instance:GetRoleBaseProf()

-- 	local data_list = {}
-- 	local top_flag = 0
-- 	if cfg[1].headtitleItemId then
-- 		data_list[1] = {item_id = cfg[1].headtitleItemId, num = 1, is_bind = 0}
-- 	end
-- 	for k,v in pairs(cfg[1].reward) do
-- 		if v.id then
-- 			local add_flag = true
-- 			if v.job then
-- 				if v.job == prof then top_flag = #data_list + 1 end
-- 				if v.job ~= prof then add_flag = false end
-- 			end
-- 			if add_flag then
-- 				data_list[#data_list + 1] = {item_id = v.id, num = v.count, is_bind = v.bind}
-- 			end
-- 		end
-- 	end

-- 	if top_flag ~= 0 then
-- 		local temp = data_list[1]
-- 		data_list[1] = data_list[top_flag]
-- 		data_list[top_flag] = temp
-- 	end
	
-- 	return data_list
-- end

function ChargeRewardData:GetFirstChargeRewardData(index)
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if not cfg or not cfg[1] or not cfg[1].rewardGrade or not index then return end
	local prof = RoleData.Instance:GetRoleBaseProf()
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)

	local data_list = {}
	local top_flag = 0
	local cur_award = cfg[1].rewardGrade[index] and cfg[1].rewardGrade[index].award or {}
	for k,v in pairs(cur_award) do
		if v.id then
			local add_flag = true
			if v.job then
				if v.job == prof then 
					top_flag = #data_list + 1
				else
					add_flag = false
				end
			end
			if v.sex then
				if v.sex == sex then
					top_flag = #data_list + 1
				else
					add_flag = false
				end
			end
			if add_flag then
				data_list[#data_list + 1] = {item_id = v.id, num = v.count, is_bind = v.bind, show_eff = v.show_eff}
			end
		end
	end

	if top_flag ~= 0 then
		local temp = data_list[1]
		data_list[1] = data_list[top_flag]
		data_list[top_flag] = temp
	end
	
	return data_list

end

function ChargeRewardData:GetFirstChargeGiftIdentificationData()
	return self.first_charge_state_list
end

function ChargeRewardData:GetFirstChargeRemindNum()
	if not self.first_charge_state_list then return 0 end
	local remind_num = 0
	for k, v in pairs(self.first_charge_state_list) do
		if 1 == v then remind_num = remind_num + 1 end
	end
	return remind_num
end

function ChargeRewardData:GetFirstChargeIsAllGet()
	local data = self.first_charge_state_list
	if not data then return false end
	return self:GetFirstChargeAutoJumpIndex() == nil
end

function ChargeRewardData:GetFirstChargeAutoJumpIndex()
	local state = self.first_charge_state_list
	if nil == state then return end
	local is_charge = false
	local not_charge_index = 0
	for k, v in pairs(state) do
		if 0 == v and 0 == not_charge_index then not_charge_index = k end
		if 1 == v then return k end
		if 2 == v then is_charge = true end
	end
	if not is_charge then return 0 end
	if 0 ~= not_charge_index then return not_charge_index end
end

function ChargeRewardData:CheckFirstChargeIsAllGet(param)
	return self:GetFirstChargeIsAllGet() == param
end

--------------------------------------
-- 每日充值
--------------------------------------
function ChargeRewardData:GetEveryDayChargeRewardData()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg then return {} end

	local prof = RoleData.Instance:GetRoleBaseProf() 			-- 职业

	local data_list = {}
	for _, v in pairs(cfg) do
		if v.Isrepeat == 2 then
			local item_list = {}
			for _, item_data in pairs(v.reward or {}) do
				if item_data.job == nil or item_data.job == prof then
					table.insert(item_list, ItemData.FormatItemData(item_data))
					item_list[#item_list].show_eff = item_data.show_eff
				end
			end
			table.insert(data_list, item_list)	
		end
	end
	return data_list
end

function ChargeRewardData.GetEveryDayChargeTabNameList()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg then return {} end

	local list = {}
	for _, v in pairs(cfg) do
		if v.Isrepeat == 2 then
			list[#list + 1] = string.format(Language.Charge.ChargeXXYuan, v.money / 100)	
		end
	end

	return list
end

function ChargeRewardData:GetEveryDayChargeGiftIdentificationData()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg or nil == self.every_day_info then return end

	local gift_state_t = bit:d2b(self.every_day_info.receive_state)

	local data = {}
	for i=2, #cfg do
		data[#data + 1] = {}
		data[#data].gift_state = gift_state_t[#gift_state_t - (i - 1) + 1]
		data[#data].money = cfg[i].money - self.every_day_info.today_charge_money
		data[#data].can_get_tag = data[#data].money <= 0 and data[#data].gift_state ~= 1
		data[#data].need_money = cfg[i].money
		data[#data].award = cfg[i].reward
		data[#data].index = i-1
		data[#data].lq_state = self:GetGiftState(data[#data].money, data[#data].gift_state)
	end

	table.sort(data, function (a, b)
		
		if a.lq_state ~= b.lq_state then
			return a.lq_state < b.lq_state
		else
			return a.index < b.index
		end
	end)

	return data
end

-- 获取礼包领取逇状态
function ChargeRewardData:GetGiftState(money, state)
	local index = 0
	if money > 0 then
		index = 2
	else
		index = (state == 0) and 1 or 3
	end

	return index
end

function ChargeRewardData:GetChargeCfg()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg then return end
	return cfg 
end

function ChargeRewardData:GetEveryDayChargeGiftNowGetIndex()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg or nil == self.every_day_info or nil == self.every_day_info.receive_state then return end

	local gift_state_t = bit:d2b(self.every_day_info.receive_state)
	local index = 1
	for i = 1, #cfg - 1 do
		local state = gift_state_t[#gift_state_t - i + 1]
		index = state == 1 and index + 1 or index
	end

	index = index > #cfg - 1 and #cfg - 1 or index
	return index
end

function ChargeRewardData:GetEveryDayChargeMaxLevel()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.RechargeGift
	if nil == cfg then return 0 end
	return #cfg - 1
end

function ChargeRewardData:GetEveryDayChargeRemindNum()
	local data = self:GetEveryDayChargeGiftIdentificationData()
	if not data then return 0 end
	local remind_num = 0
	for k, v in pairs(data) do
		if v.can_get_tag then remind_num = remind_num + 1 end
	end
	if not self:IsRightRewardGet() then
		remind_num = remind_num + 1
	end
	return remind_num
end

function ChargeRewardData:GetEveryDayChargeIsAllGet()
	local data = self:GetEveryDayChargeGiftIdentificationData()
	if not data then return false end
	return self:GetEveryDayChargeAutoJumpIndex() == nil and self:IsRightRewardGet()
end

function ChargeRewardData:GetEveryDayChargeAutoJumpIndex()
	local data = self:GetEveryDayChargeGiftIdentificationData()
	if not data then return end
	for k,v in pairs(data) do
		if v.gift_state ~= 1 then return k end
	end
end

function ChargeRewardData:GetChargeRewardData()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.hundredReward
	if nil == cfg or nil == self.charge_award_sign then return end
	local data_list = {}
	for i=1, #cfg do
		local is_lingqu = bit:_and(1, bit:_rshift(self.charge_award_sign , i - 1))
		local vo = {
			index = i,
			cfg = cfg[i],
			sign = is_lingqu
		}
		data_list[i] = vo
	end

	table.sort(data_list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	return data_list
end

function ChargeRewardData:IsRightRewardGet()
	return self:GetEveryDayTreasureState() <= 3
end

-- function ChargeRewardData:IsRightRewardGet()
-- 	local cfg = ActivityGiftConfig and ActivityGiftConfig.hundredReward
-- 	local day = cfg.times
-- 	if self.charge_day >= day then
-- 		return false
-- 	end
-- 	return true
-- end

function ChargeRewardData:GetChargeRewardMoney()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.hundredReward
	if nil == cfg then return end
	return cfg.money
end

function ChargeRewardData:GetBoxData()
	local cfg = ActivityGiftConfig and ActivityGiftConfig.hundredReward
	if nil == cfg then return end
	local open_server_day = OtherData.Instance:GetOpenServerDays() -- 开服天数
	local award = {}
	for i = 1, self.treasure_total_grade do
		if self.charge_day_list[i] > 0 then
			award = cfg[i].award[1]
			return {item_id = award.id, num = award.count, is_bind = award.bind}
		end
	end
	for i = 1, self.treasure_total_grade do
		if open_server_day >= cfg[i].openServerMinDay and (nil == cfg[i].openServerMaxDay or open_server_day <= cfg[i].openServerMaxDay ) then
			award = cfg[i].award[1]
		end
	end
	return {item_id = award.id, num = award.count, is_bind = award.bind}
end
