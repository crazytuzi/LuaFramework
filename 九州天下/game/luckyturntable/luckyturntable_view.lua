LuckyTurntableView = LuckyTurntableView or BaseClass(BaseView)

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

function LuckyTurntableView:__init()
	self.ui_config = {"uis/views/luckyturntable", "LuckyTurntable"}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
	self.click_reward = -1
	self.is_first_open = false  
	self:SetMaskBg()
end

function LuckyTurntableView:__delete()
	
end

function LuckyTurntableView:ReleaseCallBack()
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
	self.play_ani_toggle = nil
	self.ShenYuTime = nil
	self.is_click_once = false
	self.last_chance = nil
	self.text_info = nil

	for i = 1, 8 do
		self.item_list[i]:DeleteMe()
		self.item_list[i] = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function LuckyTurntableView:LoadCallBack()
	self.center_point = self:FindObj("center_point")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("close_button", BindTool.Bind(self.close_button, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))

	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
	end

	self.ShenYuTime = self:FindVariable("ShenYuTime")
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
	self.last_chance = self:FindVariable("last_chance")
	self.text_info = self:FindVariable("text_info")
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:Flush()
end

function LuckyTurntableView:OnToggleChange(is_on)
	LuckyTurntableData.Instance:SetAniState(is_on)
end

function LuckyTurntableView:TipsClick()
	local tips_id = 242 -- 幸运转盘玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function LuckyTurntableView:SetItemImage()
	if not self.is_first_open then
		local reward_list = LuckyTurntableData.Instance:GetLuckyTurntableRewardList()
		local cur_index = 0
		for i = 1, #reward_list do
			self.item_list[i]:SetData(reward_list[i].reward_item)
		end
		self.is_first_open = true
	end

end

function LuckyTurntableView:OpenCallBack()
	if nil == self.least_time_timer then
		local rest_time = LuckyTurntableData.Instance:GetActEndTime()
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)
	end
	self:FlushText()
end

function LuckyTurntableView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self.click_reward = -1
	self.is_click_once = false
	self.is_first_open = false
end

function LuckyTurntableView:OnFlush()
	self:FlushText()
	self:SetItemImage()
	if self.click_reward > -1 then
		if self.play_ani_toggle.isOn then
			if self.click_reward == CHEST_SHOP_MODE.CHEST_RAN_LUCKY_TURNTABLE and LuckyTurntableData.Instance:GetRewardIndex() ~= -1 then
				self:TurnCellOne()
			end
		elseif self.click_reward and LuckyTurntableData.Instance:GetRewardIndex() ~= -1 then
			self:TurnCell()
		end
	end
end

function LuckyTurntableView:FlushText()
	local last_chance = LuckyTurntableData.Instance:GetChance()
	local total_charge = LuckyTurntableData.Instance:GetTotalCharge()
	local need_charge = LuckyTurntableData.Instance:GetNeedCharge()

	local str = string.format(Language.LuckyTurntable.TextInfo, total_charge, need_charge)
	self.text_info:SetValue(str)
	self.last_chance:SetValue(last_chance)
end

function LuckyTurntableView:SetTime(rest_time)
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
function LuckyTurntableView:TurnCell()
	local reward_index = LuckyTurntableData.Instance:GetRewardIndex()
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
				TipsCtrl.Instance:ShowTreasureView(self.click_reward)
				ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKY_TURNTABLE_REWARD)
			end)
		end
	end)
end

--无动画
function LuckyTurntableView:TurnCellOne()
	self:ResetVariable()
	self:ResetHighLight()
	self.is_rolling = false
	self:ShowHightLight()
	TipsCtrl.Instance:ShowTreasureView(self.click_reward)
	ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKY_TURNTABLE_REWARD)	
	local reward_index = LuckyTurntableData.Instance:GetRewardIndex()
	local angle = POINTER_ANGLE_LIST[reward_index % 8 + 1]
	self.center_point.gameObject.transform.localRotation = Quaternion.Euler(0, 0, angle)
end

function LuckyTurntableView:ShowHightLight()
	local reward_index = LuckyTurntableData.Instance:GetRewardIndex()
	local hight_light_index = reward_index % 10 + 1 
	self["show_hight_light_"..hight_light_index]:SetValue(true)
end

function LuckyTurntableView:OnClickOnce()
	if self.is_rolling then
		return
	end
	local chance = LuckyTurntableData.Instance:GetChance()
	if chance > 0 then
		self.is_click_once = true
		LuckyTurntableData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RAN_LUCKY_TURNTABLE
		self:PointerTrunAround()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.LuckyTurntable.CantGet)
	end
end

function LuckyTurntableView:close_button()
	if self.is_rolling then
		return
	end
	self:Close()
end

function LuckyTurntableView:PointerTrunAround()
	if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE, RA_ONE_YUAN_DRAW_OPERA_TYPE.RA_ONE_YUAN_DRAW_OPERA_TYPE_DRAW_REWARD)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function LuckyTurntableView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function LuckyTurntableView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function LuckyTurntableView:ResetHighLight()
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