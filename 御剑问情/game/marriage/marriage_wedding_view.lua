MarriageWeddingView = MarriageWeddingView or BaseClass(BaseView)

local YanHuiType = {
	Normal = 1,			--普通婚宴
	Special = 2			--豪华婚宴
}

function MarriageWeddingView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","MarriageWeddingView"}
	self.play_audio = true
end

function MarriageWeddingView:__delete()

end

function MarriageWeddingView:LoadCallBack()
	self:ListenEvent("HoldWedding", BindTool.Bind(self.HoldWeddingClick, self))
	self:ListenEvent("UseBindDiamondChange", BindTool.Bind(self.UseBindDiamondChange, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))

	self.is_holding = self:FindVariable("IsHolding")
	self.bind_reward_name = self:FindVariable("BindRewardName")
	self.bind_reward_num = self:FindVariable("BindRewardNum")
	self.reward_name = self:FindVariable("RewardName")
	self.reward_num = self:FindVariable("RewardNum")
	self.gold_text_1 = self:FindVariable("GoldText1")
	self.gold_text_2 = self:FindVariable("GoldText2")

	self.toggle_1 = self:FindObj("Toggle1").toggle
	self.toggle_2 = self:FindObj("Toggle2").toggle

	self.toggle_1:AddValueChangedListener(BindTool.Bind(self.HighLight,self))

	self.button_text = self:FindVariable("ButtonText")
	self.has_free_times = self:FindVariable("HasFreeTimes")
	self.is_use_bind_diamond = 2

	self.item_cell_list = {}
	self.anim_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
		self.anim_list[i] = self:FindObj("Anim"..i)
	end
	self.toggle_2.isOn = true
end

function MarriageWeddingView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	self.anim_list = {}
	self.is_holding = nil
	self.bind_reward_name = nil
	self.bind_reward_num = nil
	self.reward_name = nil
	self.reward_num = nil
	self.gold_text_1 = nil
	self.gold_text_2 = nil
	self.toggle_1 = nil
	self.toggle_2 = nil
	self.button_text = nil
	self.has_free_times = nil
end

function MarriageWeddingView:OpenCallBack()
	self:Flush()
end

function MarriageWeddingView:HighLight()
	if self.toggle_1.isOn then
		self:UseBindDiamondChange(true)
		self.is_use_bind_diamond = 1
	else
		self:UseBindDiamondChange(false)
		self.is_use_bind_diamond = 2
	end
	MarriageData.Instance:SetYanHuiType(self.is_use_bind_diamond)
end

function MarriageWeddingView:HelpClick()
	local tips_id = 70 -- 结婚帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageWeddingView:ClickClose()
	self:Close()
end

function MarriageWeddingView:OnFlush()
	local is_holding_weeding = MarriageData.Instance:GetIsHoldingWeeding()
	self.is_holding:SetValue(is_holding_weeding)
	if is_holding_weeding then
		local yanhui_type = MarriageData.Instance:GetYanHuiType()
		self.toggle_1.isOn = (yanhui_type == 1)
		self.toggle_2.isOn = (yanhui_type == 2)
	else
		self:HighLight()
	end

	if is_holding_weeding then
		self.button_text:SetValue(Language.Marriage.EnterDes)
	else
		self.button_text:SetValue(Language.Marriage.OpenDes)
	end

	local bind_cfg = MarriageData.Instance:GetWeddingCfgByType(YanHuiType.Normal) or {}
	local bind_reward_data = MarriageData.Instance:GetHunYanReward(true)
	local bind_item_name = ItemData.Instance:GetItemName(bind_reward_data.item_id)
	local bind_item_num = bind_reward_data.num
	self.bind_reward_name:SetValue(bind_item_name)
	self.bind_reward_num:SetValue(bind_item_num)
	local bind_gold = bind_cfg.need_coin
	if bind_gold and bind_gold > 0 then
		self.gold_text_1:SetValue(bind_gold)
	end
	self.item_cell_list[1]:SetData({item_id = bind_reward_data.item_id, num = 0})

	local gold_cfg = MarriageData.Instance:GetWeddingCfgByType(YanHuiType.Special) or {}
	local reward_data = MarriageData.Instance:GetHunYanReward()
	local item_name = ItemData.Instance:GetItemName(reward_data.item_id)
	local item_num = reward_data.num
	self.reward_name:SetValue(item_name)
	self.reward_num:SetValue(item_num)
	local gold = gold_cfg.need_gold
	if gold and gold > 0 then
		self.gold_text_2:SetValue(gold)
	end
	self.item_cell_list[2]:SetData({item_id = reward_data.item_id, num = 0})

	self.has_free_times:SetValue(MarriageData.Instance:GetPutongHunyanTimes() < 1)
end

function MarriageWeddingView:DoHoldWedding(index, str1, str2)
	local cfg = MarriageData.Instance:GetWeddingCfgByType(index)
	if nil == cfg then
		return
	end

	local cost = 0
	local had_money = 0
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	if index == YanHuiType.Normal then
		cost = cfg.need_coin
		had_money = mainrole_vo.bind_gold
	elseif index == YanHuiType.Special then
		cost = cfg.need_gold
		had_money = mainrole_vo.gold
	end

	if had_money >= cost then
		ViewManager.Instance:Open(ViewName.WeddingYuYueView)
		self:Close()		
	else
		if index == YanHuiType.Normal then
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage[str2])
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end		
	end
end

--开启宴会按下后
function MarriageWeddingView:HoldWeddingClick()
	local is_holding_weeding = MarriageData.Instance:GetIsHoldingWeeding()
	if is_holding_weeding then
		local fb_key = MarriageData.Instance:GetFuBenKey()
		MarriageCtrl.Instance:SendEnterWeeding(fb_key)
	else
		if self.is_use_bind_diamond == 1 then
			self:DoHoldWedding(YanHuiType.Normal, "OpenBindDiamondWeeding2", "NotEnoughBindDiamond")
		else
			self:DoHoldWedding(YanHuiType.Special, "OpenDiamondWeeding", "NotEnoughDiamond")
		end
	end
end

function MarriageWeddingView:UseBindDiamondChange(isOn)
	if isOn then
		self.is_use_bind_diamond = 1
		self:OnSelect(1)
		self:OnUnSelect(2)
	else
		self.is_use_bind_diamond = 2
		self:OnSelect(2)
		self:OnUnSelect(1)
	end
end

function MarriageWeddingView:OnSelect(index)
	GlobalTimerQuest:AddDelayTimer(function()
		self.anim_list[index].animator:SetBool("fold", true)
	end, 0)
end

function MarriageWeddingView:OnUnSelect(index)
	GlobalTimerQuest:AddDelayTimer(function()
		self.anim_list[index].animator:SetBool("fold", false)
	end, 0)
end