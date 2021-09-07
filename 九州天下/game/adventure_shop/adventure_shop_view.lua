AdventureShopView = AdventureShopView or BaseClass(BaseView)

local POINTER_ANGLE_LIST = {
	[1] = 2,
	[2] = -42,
	[3] = -88,
	[4] = -132,
	[5] = -178,
	[6] = -222,
	[7] = -266,
	[8] = -311,
	[9] = -288,
	[10] = -324,
}

function AdventureShopView:__init()
	self.ui_config = {"uis/views/adventureshopview", "AdventureShopView"}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
	self.click_reward = -1
	self.is_first_open = false  
	self:SetMaskBg()
end

function AdventureShopView:__delete()
	
end

function AdventureShopView:ReleaseCallBack()
	self.center_point = nil
	self.show_hight_light_1 = nil
	self.show_hight_light_2 = nil
	self.show_hight_light_3 = nil
	self.show_hight_light_4 = nil
	self.show_hight_light_5 = nil
	self.show_hight_light_6 = nil
	self.show_hight_light_7 = nil
	self.show_hight_light_8 = nil
	self.show_hight_light_9 = nil
	self.show_hight_light_10 = nil
	self.ShenYuTime = nil
	self.is_click_once = false
	self.charge_btn = nil
	self.btn_text = nil
	for i = 1, 8 do
		self.item_list[i]:DeleteMe()
		self.item_list[i] = nil
	end
end

function AdventureShopView:LoadCallBack()
	self.center_point = self:FindObj("center_point")
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("close_button", BindTool.Bind(self.close_button, self))
	self:ListenEvent("OnClickCharge", BindTool.Bind(self.OnClickCharge, self))
	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
	end

	self.ShenYuTime = self:FindVariable("ShenYuTime")
	self.btn_text = self:FindVariable("btn_text")
	self.charge_btn = self:FindVariable("charge_btn")
	self.show_hight_light_1 = self:FindVariable("show_hight_light_1")
	self.show_hight_light_2 = self:FindVariable("show_hight_light_2")
	self.show_hight_light_3 = self:FindVariable("show_hight_light_3")
	self.show_hight_light_4 = self:FindVariable("show_hight_light_4")
	self.show_hight_light_5 = self:FindVariable("show_hight_light_5")
	self.show_hight_light_6 = self:FindVariable("show_hight_light_6")
	self.show_hight_light_7 = self:FindVariable("show_hight_light_7")
	self.show_hight_light_8 = self:FindVariable("show_hight_light_8")
	self.show_hight_light_9 = self:FindVariable("show_hight_light_9")
	self.show_hight_light_10 = self:FindVariable("show_hight_light_10")
end

function AdventureShopView:SetItemImage()
	if not self.is_first_open then
		local reward_list = AdventureShopData.Instance:GetAdventureShopRewards()
		for i = 1, 8 do
			self.item_list[i]:SetData(reward_list[i].reward_item)

			if reward_list[i].reward_item.item_id == COMMON_CONSTS.VIRTUAL_ITEM_GOLD then
				local str = string.format(Language.AdventureShop.YellowText, reward_list[i].show_string)
				self.item_list[i]:SetItemNum(str)
				self.item_list[i]:QualityColor(5)
				self.item_list[i]:SetItemNumVisible(true)
				self.item_list[i]:SetNumberSize(18)
			end
		end
		self.is_first_open = true
	end

end

function AdventureShopView:OpenCallBack()
	AdventureShopCtrl.Instance:SendAdventureShopReq(RA_ADVENTURE_OPERA_TYPE.ADVENTURE_SHOP_OPERA_TYPE)
	if nil == self.least_time_timer then
		local rest_time = AdventureShopData.Instance:GetActEndTime()
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)
	end
end

function AdventureShopView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self.click_reward = -1
	self.is_click_once = false
	self.is_first_open = false
end

function AdventureShopView:OnFlush()
	self:SetItemImage()
	self:FlushChargeBtn()

	local reward_index = AdventureShopData.Instance:GetRewardIndex()
	if reward_index ~= -1 then
		self:TurnCell()
	end
end

function AdventureShopView:FlushChargeBtn()
	local can_get = AdventureShopData.Instance:GetAdventureShopCanGet()
	local has_get = AdventureShopData.Instance:GetAdventureShopHasGet()
	self.charge_btn:SetValue(AdventureShopData.Instance:GetAdventureShopCanGet() == 0)
	local str = string.format(Language.AdventureShop.NeedCharge, AdventureShopData.Instance:GetAdventureShopNeedChongzhi())

	if can_get > 0 and has_get > 0 then
		str = Language.AdventureShop.DrawLater
	elseif can_get > 0 and has_get == 0 then
		str = Language.AdventureShop.StarDraw
	end

	self.btn_text:SetValue(str)
end

function AdventureShopView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end

	if self.ShenYuTime then
		self.ShenYuTime:SetValue(str)
	end
end

--转盘转动
function AdventureShopView:TurnCell()
	local reward_index = AdventureShopData.Instance:GetRewardIndex()
	self:ResetVariable()
	self:ResetHighLight()
	self.is_rolling = true 
	local time = 0
	local tween = self.center_point.transform:DORotate(
	Vector3(0, 0, -360 * 20),20,
	DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local angle = POINTER_ANGLE_LIST[reward_index % 8 + 1]
			local tween1 = self.center_point.transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self.is_rolling = false
				self:ShowHightLight()
				local reward_list = AdventureShopData.Instance:GetAdventureShopRewards()
				if reward_list[reward_index + 1].reward_item.item_id ~= COMMON_CONSTS.VIRTUAL_ITEM_GOLD then
					TipsCtrl.Instance:ShowTreasureView(self.click_reward)
				else
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.AdventureShop.SendGoldTip, reward_list[reward_index + 1].give_gold), 0.5)
				end

				ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ADVENTURE_SHOP_REWARD)
			end)
		end
	end)
end

function AdventureShopView:ShowHightLight()
	local reward_index = AdventureShopData.Instance:GetRewardIndex()
	local hight_light_index = reward_index % 10 + 1 
	self["show_hight_light_"..hight_light_index]:SetValue(true)
end

function AdventureShopView:OnClickOnce()
	if self.is_rolling then
		return
	end
	local has_get = AdventureShopData.Instance:GetAdventureShopHasGet()
	local can_get = AdventureShopData.Instance:GetAdventureShopCanGet()
	if can_get > 0 and has_get == 0 then
		self.is_click_once = true
		self.click_reward = CHEST_SHOP_MODE.CHEST_RAN_ADVENTURE_SHOP
		self:PointerTrunAround()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.AdventureShop.CantGet)
	end
end

function AdventureShopView:close_button()
	if self.is_rolling then
		return
	end
	self:Close()
end

function AdventureShopView:OnClickCharge()
	local can_get = AdventureShopData.Instance:GetAdventureShopCanGet()
	local has_get = AdventureShopData.Instance:GetAdventureShopHasGet()
	if can_get == 0 and has_get == 0 then
		local charge_id = AdventureShopData.Instance:GetChargeLevel()
		local recharge_cfg = RechargeData.Instance:GetRechargeInfo(charge_id)
		local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
		local vip_chongzhi_num = DailyChargeData.Instance:CheckIsFirstRechargeById(charge_id)
		local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
		if (nil == reward_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID) or not recharge_cfg then return end
		local discretion = ""
		if recharge_cfg.id == RechargeData.SPEC_ID then
			local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
			if has_buy_7day_rechange then
				RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
				return
			end
			discretion = string.format(Language.Recharge.RechargeDes, reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold)
			str_recharge = string.format(Language.Recharge.FirstBing, 18)
		else
			discretion = reward_cfg.discretion
			str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
		end
		if vip_chongzhi_num == true then
			chongzhi_show_str = str_recharge .. "\n\n" .. string.format(discretion) .. "\n\n" .. Language.Recharge.WarmPrompt
		else
			chongzhi_show_str = str_recharge .. "\n\n" .. Language.Recharge.WarmPrompt
		end
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind2(self.SendRecharge, self, recharge_cfg), nil, chongzhi_show_str)
	end
end

function AdventureShopView:SendRecharge(recharge_cfg)
	RechargeCtrl.Instance:Recharge(recharge_cfg.money)
end

function AdventureShopView:PointerTrunAround()
	if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		AdventureShopCtrl.Instance:SendAdventureShopReq(RA_ADVENTURE_OPERA_TYPE.ADVENTURE_SHOP_REQ_TYPE)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function AdventureShopView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function AdventureShopView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function AdventureShopView:ResetHighLight()
	self.show_hight_light_5:SetValue(false)
	self.show_hight_light_6:SetValue(false)
	self.show_hight_light_7:SetValue(false)
	self.show_hight_light_8:SetValue(false)
	self.show_hight_light_9:SetValue(false)
	self.show_hight_light_10:SetValue(false)
	self.show_hight_light_1:SetValue(false)
	self.show_hight_light_2:SetValue(false)
	self.show_hight_light_3:SetValue(false)
	self.show_hight_light_4:SetValue(false)
end