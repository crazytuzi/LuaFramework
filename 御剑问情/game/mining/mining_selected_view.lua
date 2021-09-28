MiningSelectedView = MiningSelectedView or BaseClass(BaseView)

local delay_time = 0.3

function MiningSelectedView:__init()
	self.ui_config = {"uis/views/mining_prefab","MiningSelectedView"}
	self.play_audio = true
	self.mine_index = 0
	self.shwo_last_index = -1

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
end

function MiningSelectedView:__delete()
	self.close_deal_callback = nil
	self:RemoveCountDown()
end

function MiningSelectedView:ReleaseCallBack()
	for i = 0, 3 do
		if nil ~= self["mine_show_" .. i] then
			self["mine_show_" .. i]:DeleteMe()
			self["mine_show_" .. i] = nil
		end
	end

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end

	-- 清理变量和对象
	self.text_title_name = nil
	self.text_money = nil
	self.text_mine_num = nil
	self.text_tip = nil
end

function MiningSelectedView:LoadCallBack()
	self.text_title_name = self:FindVariable("text_title_name")
	self.text_money = self:FindVariable("text_money")
	self.text_mine_num = self:FindVariable("text_mine_num")
	self.text_tip = self:FindVariable("text_tip")
	self.text_tip:SetValue(Language.Mining.SelectedTip)

	for i = 0, 3 do
		self["mine_show_" .. i] = MiningSelectedMineItem.New(self:FindObj("mine_show_" .. i))
		self["mine_show_" .. i]:SetMineIndex(i)
	end

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickEnter",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickFlush", BindTool.Bind(self.OnClickFlush, self))
	self:ListenEvent("OnClickAdd", BindTool.Bind(self.OnClickAdd, self))

	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
end

function MiningSelectedView:OpenCallBack()
	self:Flush()
end

function MiningSelectedView:CloseCallBack()
	self.mine_index = 0
	self.shwo_last_index = -1
end

function MiningSelectedView:CloseWindow()
	self:Close()
end

function MiningSelectedView:OnClickEnter()
	local times = MiningData.Instance:GetMiningMineDayTimes()
	if times <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mining.NoTimeDesc)
	else
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_START_MINING)
	end
end

function MiningSelectedView:OnClickFlush()
	if self.mine_index == 3 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Mining.NoFlushDesc)
	else

		local mine_data = MiningData.Instance:GetMiningMineCfg(self.mine_index)
		if mine_data == nil then
			return
		else
			local function ok_callback()
				MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_REFLUSH_MINING)
			end
			local cost = mine_data.consume_gold or 0
			local des = string.format(Language.Mining.BuyFlushDesc, cost)
			TipsCtrl.Instance:ShowCommonAutoView("mining_mine_flush", des, ok_callback)
		end
	end
end

function MiningSelectedView:OnClickAdd()
	local today_buy_times = MiningData.Instance:GetMiningMineTodayBuyTimes()
	local limit_time = VipPower.Instance:GetParam(VIPPOWER.MINING_MINE) or 0
	local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.MINING_MINE, limit_time + 1) or 0

	if today_buy_times < limit_time then
		local func = function ()
			MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_BUY_TIMES)
		end

		local other_cfg = MiningData.Instance:GetOtherCfg()
		local buy_good = other_cfg.dm_buy_time_need_gold

		local str = string.format(Language.Mining.RestTimes, buy_good)
		TipsCtrl.Instance:ShowCommonAutoView("mining_mine_buy_time", str, func)

		-- TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, false, "chongzhi")
	else
		if limit_level == -1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Mining.RestTimesLimit)
		elseif PlayerData.Instance.role_vo.vip_level < limit_level then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.MINING_MINE)
		end
	end
end

function MiningSelectedView:SetMineIndex(index)
	self.mine_index = index
end

function MiningSelectedView:OnFlush()
	self:UpdataMiningMineDayTimes()
	self:UpdataMineList()
end

function MiningSelectedView:UpdataMineList()
	local info_data = MiningData.Instance:GetMiningMineMyInfo()

	self.mine_index = info_data.mining_type

	local mine_data = MiningData.Instance:GetMiningMineCfg(self.mine_index)
	if self.mine_index == 3 or mine_data == nil then
		self.text_money:SetValue("--")
	else
		self.text_money:SetValue(CommonDataManager.ConverMoney(mine_data.consume_gold))
	end

	if self.shwo_last_index == -1 or self.shwo_last_index == self.mine_index or self.mine_index == 0 then
		self:RemoveCountDown()
		for i = 0, 3 do
			if self["mine_show_" .. i] then
				self["mine_show_" .. i]:SetEffValue(false)
			end
		end
		if self["mine_show_" .. self.mine_index] then
			self["mine_show_" .. self.mine_index]:SetEffValue(true)
		end
		self.shwo_last_index = self.mine_index
	else
		if self.mine_index > self.shwo_last_index then
			self:FlushHighLight(self.shwo_last_index + 1, self.mine_index)
		else
			self:FlushHighLight(self.shwo_last_index, self.mine_index)
		end
		self.shwo_last_index = self.mine_index
	
	end
end

function MiningSelectedView:FlushHighLight(last_index, next_index)
	if last_index < 0 or next_index > 3 then return end
	self:RemoveCountDown()

	for i = 0, 3 do
		if self["mine_show_" .. i] then
			self["mine_show_" .. i]:SetEffValue(false)
		end
	end

	self.count_down = CountDown.Instance:AddCountDown((next_index - last_index + 1) * delay_time, delay_time,
		function()
			if self["mine_show_" .. (last_index - 1)] then
				self["mine_show_" .. (last_index - 1)]:SetEffValue(false)
			end
			if self["mine_show_" .. last_index] then
				self["mine_show_" .. last_index]:SetEffValue(true)
			end
			last_index = last_index + 1
		end)
end

function MiningSelectedView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-- 玩家钻石改变时
function MiningSelectedView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		--
	end
end

-- 剩余挖矿次数
function MiningSelectedView:UpdataMiningMineDayTimes()
	self.text_mine_num:SetValue(MiningData.Instance:GetMiningMineDayTimes())
end

-----------------------------------------矿石item
MiningSelectedMineItem = MiningSelectedMineItem or BaseClass(BaseRender)

function MiningSelectedMineItem:__init()
	self.show_selected = self:FindVariable("show_selected")
	self.text_show_1 = self:FindVariable("text_show_1")
	self.text_show_2 = self:FindVariable("text_show_2")

	self.mine_index = 0
end

function MiningSelectedMineItem:__delete()
	self.show_selected = nil
	self.text_show_1 = nil
	self.text_show_2 = nil
end

function MiningSelectedMineItem:OnFlush()
	local info_data = MiningData.Instance:GetMiningMineCfg(self.mine_index)
	if info_data == nil then return end

	local role_exp = MiningData.Instance:GetMiningExpValue(info_data.reward_exp, PlayerData.Instance.role_vo.level)
	-- 经验用万表示
	local format_exp = role_exp
	if format_exp > 99999 and format_exp <= 99999999 then
		format_exp = format_exp / 10000
		format_exp = math.floor(format_exp)
		self.text_show_1:SetValue(string.format(Language.Mining.SelectedExpText2, Language.Common.JingYan, format_exp,Language.Common.Wan))
	elseif format_exp > 99999999 then
		format_exp = format_exp / 100000000
		format_exp = math.floor(format_exp)
		self.text_show_1:SetValue(string.format(Language.Mining.SelectedExpText2, Language.Common.JingYan, format_exp,Language.Common.Yi))
	end
	local item = info_data.reward_item[0] or nil 
	if item then
		local item_name = ItemData.Instance:GetItemName(item.item_id)
		self.text_show_2:SetValue(string.format(Language.Mining.SelectedExpText, item_name, item.num))
	end
end

function MiningSelectedMineItem:SetMineIndex(index)
	self.mine_index = index
	self:Flush()
end

function MiningSelectedMineItem:SetEffValue(boo)
	self.show_selected:SetValue(boo)
end