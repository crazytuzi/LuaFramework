MarriageWeddingView = MarriageWeddingView or BaseClass(BaseRender)

local YanHuiType = {
	Normal = 1,			--普通婚宴
	Special = 2			--豪华婚宴
}

function MarriageWeddingView:__init()
	self.norma_item_id = 0
	self.special_item_id = 0
	self.show_yuyue = {}
	self:ListenEvent("HoldWedding", BindTool.Bind(self.HoldWeddingClick, self))
	self:ListenEvent("UseBindDiamondChange", BindTool.Bind(self.UseBindDiamondChange, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))

	self.is_holding = self:FindVariable("IsHolding")
	self.bind_reward_name = self:FindVariable("BindRewardName")
	self.bind_reward_num = self:FindVariable("BindRewardNum")
	self.reward_name = self:FindVariable("RewardName")
	self.reward_num = self:FindVariable("RewardNum")
	self.gold_text_1 = self:FindVariable("GoldText1")
	self.gold_text_2 = self:FindVariable("GoldText2")
	self.yuyue_time = self:FindVariable("YuYueTime")

	self.button_gray = self:FindObj("ButtonGray")

	for i = 1, 2 do
		self["toggle_" .. i] = 	self:FindObj("Toggle" .. i).toggle
		self["toggle_" .. i]:AddValueChangedListener(BindTool.Bind(self.WeddingType, self, i))
		self.show_yuyue[i] = self:FindVariable("ShowYuYue" .. i)
	end
	self.button_text = self:FindVariable("ButtonText")
	self.is_use_bind_diamond = 2
	self.gold_icon_1 = self:FindVariable("GoldIcon1")
	self.gold_icon_2 = self:FindVariable("GoldIcon2")

	self.show_icon_1 = self:FindVariable("ShowIcon1")
	self.show_icon_2 = self:FindVariable("ShowIcon2")
	self:Flush()

	if not self.item_change then
		self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end
end

function MarriageWeddingView:__delete()
	self.gold_icon_1 = nil
	self.gold_icon_2 = nil
	self.is_gray = nil

	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
end

function MarriageWeddingView:OpenCallBack()
	local wedding_type = MarriageData.Instance:GetMyWeddingType()
	for i = 1, 2 do
		if self["toggle_" .. i] then
			self["toggle_" .. i].isOn = wedding_type == i
		end
	end
	self:WeddingType(wedding_type)
end

function MarriageWeddingView:HelpClick()
	local tips_id = 70 -- 结婚帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageWeddingView:Flush()
	local is_holding_weeding = MarriageData.Instance:GetIsHoldingWeeding()
	self.is_holding:SetValue(is_holding_weeding)
	if is_holding_weeding then
		local yanhui_type = MarriageData.Instance:GetYanHuiType()
		toggle = (yanhui_type == 1)
		self.toggle_2.isOn = (yanhui_type == 2)
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
	local bind_gold = bind_cfg.need_gold
	self.norma_item_id = bind_cfg.consume_item_id
	local has_normal_item = ItemData.Instance:GetItemNumIsEnough(self.norma_item_id, 1)

	self.show_icon_1:SetValue(true)
	if bind_gold and bind_gold > 0 then
		self.gold_text_1:SetValue(bind_gold)
		local bunble, asset = ResPath.GetImages("icon_gold_1000")
		self.gold_icon_1:SetAsset(bunble, asset)
	else
		local bunble,asset = ResPath.GetImage("icon_gold_1001")
		self.gold_icon_1:SetAsset(bunble,asset)
	end

	if has_normal_item then
		self.gold_text_1:SetValue(Language.Marriage.TextYaoShi[1])
		self.show_icon_1:SetValue(false)
	end

	local gold_cfg = MarriageData.Instance:GetWeddingCfgByType(YanHuiType.Special) or {}
	local reward_data = MarriageData.Instance:GetHunYanReward()
	local item_name = ItemData.Instance:GetItemName(reward_data.item_id)
	local item_num = reward_data.num
	self.reward_name:SetValue(item_name)
	self.reward_num:SetValue(item_num)
	local gold = gold_cfg.need_gold
	self.special_item_id = gold_cfg.consume_item_id
	local has_special_item = ItemData.Instance:GetItemNumIsEnough(self.special_item_id, 1)

	self.show_icon_2:SetValue(true)
	if gold and gold > 0 then
		self.gold_text_2:SetValue(gold)
		local bunble, asset = ResPath.GetImages("icon_gold_1000")
		self.gold_icon_2:SetAsset(bunble, asset)
	else
		local bunble,asset = ResPath.GetImage("icon_gold_1001")
		self.gold_icon_2:SetAsset(bunble,asset)
	end

	if has_special_item then
		self.gold_text_2:SetValue(Language.Marriage.TextYaoShi[2])
		self.show_icon_2:SetValue(false)
	end
end

function MarriageWeddingView:DoHoldWedding(index, str1, str2)
	local cfg = MarriageData.Instance:GetWeddingCfgByType(index)
	local cost = (cfg.need_coin > 0) and cfg.need_coin or cfg.need_gold
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	local had_money = (cfg.need_coin > 0) and mainrole_vo.bind_gold or mainrole_vo.gold
	if had_money >= cost then
		local cost_text = ToColorStr(cost, TEXT_COLOR.BLUE)
		local name_text = ToColorStr(cfg.marry_name, TEXT_COLOR.GREEN)
		str = string.format(Language.Marriage[str1], cost_text, name_text)
		local click_func = function ()
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_HUNYAN, self.is_use_bind_diamond)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", str, click_func)
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
	ViewManager.Instance:Open(ViewName.WeddingYuYueView)
	if is_holding_weeding then
		-- local fb_key = MarriageData.Instance:GetFuBenKey()
		-- MarriageCtrl.Instance:SendEnterWeeding(fb_key)	-- 请求进入结婚宴会
	-- else
	-- 	if self.is_use_bind_diamond == 1 then
	-- 		self:DoHoldWedding(YanHuiType.Normal, "OpenBindDiamondWeeding", "NotEnoughBindDiamond")
	-- 	else
	-- 		self:DoHoldWedding(YanHuiType.Special, "OpenDiamondWeeding", "NotEnoughDiamond")
	-- 	end
	end
end

function MarriageWeddingView:WeddingType(index)
	local wedding_type = MarriageData.Instance:GetMyWeddingType()
	local item_seq = MarriageData.Instance:GetYuYueRoleInfo().param_ch4
	local item_data = {}
	local begin1, begin2 = 0, 0
	if item_seq > 0 then
		item_data = MarriageData.Instance:GetMarryYuYueTime()[item_seq + 1]
		begin1, begin2 = math.modf(item_data.begin_time / 100)
	end
	
	local begin_time = begin1 .. ":" .. begin2 * 100

	if self.button_gray == nil or wedding_type == nil or self.show_yuyue[index] == nil then return end

	if MarriageData.Instance:GetMyWeddingType() ~= -1 then  --没有预约的时候为-1
		self.button_gray.grayscale.GrayScale = index == wedding_type and 0 or 255 
		self.button_gray.button.interactable = index == wedding_type
		self.show_yuyue[index]:SetValue(index == wedding_type)
		self.yuyue_time:SetValue(begin_time .. "0")
	else
		self.button_gray.grayscale.GrayScale = 0
		self.button_gray.button.interactable = true
	end
end

function MarriageWeddingView:UseBindDiamondChange(isOn)
	self.is_use_bind_diamond = isOn and 1 or 2
	MarriageData.Instance:SetYanHuiType(self.is_use_bind_diamond)
end

function MarriageWeddingView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == self.norma_item_id or item_id == self.special_item_id then
		self:Flush()
	end
end