CampChangeView = CampChangeView or BaseClass(BaseView)

function CampChangeView:__init()
	self.ui_config = {"uis/views/camp", "ChangeCampView"}
	self:SetMaskBg(true)
	self.play_audio = true									-- 播放音效

	self.choose_camp = nil
	self.now_camp = nil
	self.cost_str = nil
end

function CampChangeView:__delete()
end

function CampChangeView:ReleaseCallBack()
	self.consume_str = nil
	self.choose_camp = nil
	self.now_camp = nil
	self.tip_str = nil
	self.cost_str = nil

	for i = 1, 3 do
		self["select_bg_" .. i] = nil
		self["can_select_" .. i] = nil
		self["show_max_" .. i] = nil
		self["camp_score_" .. i] = nil
	end
end

function CampChangeView:LoadCallBack()
	for i = 1, 3 do
		self:ListenEvent("OnClickCamp" .. i, BindTool.Bind(self.OnClickCamp, self, i))
		self["select_bg_" .. i] = self:FindVariable("Select" .. i)
		self["can_select_" .. i] = self:FindVariable("CanSelect" .. i)
		self["show_max_" .. i] = self:FindVariable("ShowMax" .. i)
		self["camp_score_" .. i] = self:FindVariable("CampScore" .. i)
	end

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickChoose", BindTool.Bind(self.OnClickChoose, self))
	self:ListenEvent("OnClickTip", BindTool.Bind(self.OnClickTip, self))

	self.consume_str = self:FindVariable("Consume")
	self.tip_str = self:FindVariable("TipStr")
end

function CampChangeView:OpenCallBack()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_CAMP_SCORE_INFO)
end

function CampChangeView:CloseCallBack()
	self.choose_camp = nil
	self.now_camp = nil
	self.cost_str = nil
end

function CampChangeView:ShowIndexCallBack()
	self:Flush()
end

function CampChangeView:OnClickCamp(camp)
	if self.now_camp == nil or self.now_camp == camp then
		return
	end

	self.choose_camp = camp
	self:Flush()
end

function CampChangeView:OnClickClose()
	self:Close()
end

function CampChangeView:OnClickChoose()
	if self.choose_camp ~= nil and self.cost_str ~= nil then
		TipsCtrl.Instance:ShowCommonTip(function() 
				CampCtrl.Instance:SendChangeCamp(self.choose_camp)
				self:Close()
			end, nil, string.format(Language.Common.ChangeCampTip, self.cost_str, Language.Common.CampName[self.choose_camp]))
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NeedSelectCamp)
	end
end

function CampChangeView:OnFlush()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.now_camp = role_vo.camp

	for i = 1, 3 do
		if self["select_bg_" .. i] ~= nil then
			self["select_bg_" .. i]:SetValue(self.choose_camp ~= nil and i == self.choose_camp)
		end

		local is_now = false
		if role_vo.camp == i then
			is_now = true
		end

		if self["can_select_" .. i] ~= nil then
			self["can_select_" .. i]:SetValue(not is_now)
		end

		local data = CampData.Instance:GetCampScoreInfoByCamp(i)
		if data ~= nil and next(data) ~= nil then
			if self["show_max_" .. i] ~= nil then
				self["show_max_" .. i]:SetValue(data.is_max)
			end

			if self["camp_score_" .. i] ~= nil then
				self["camp_score_" .. i]:SetValue(data.score)
			end

			if self.choose_camp ~= nil and i == self.choose_camp then
				self:FlushViewConsume(data)
			end
		end
	end

	if self.choose_camp == nil then
		self:FlushViewConsume(nil)
	end
end

function CampChangeView:FlushViewConsume(data)
	if data == nil or next(data) == nil then
		if self.consume_str ~= nil then
			self.consume_str:SetValue("")
		end

		if self.tip_str ~= nil then
			self.tip_str:SetValue("")
		end

		self.cost_str = nil
		return
	end

	local need_item = nil
	local need_limit_item = nil
	local need_gold = nil
	local has_num = 0
	local cost_num = 0
	local need_check = true
	local color = TEXT_COLOR.GREEN_5
	local consume_item_id = nil
	if data.consume == 0 then
		need_limit_item = CampData.Instance:GetOtherByStr("change_camp_need_limit_item_weak")
		need_item = CampData.Instance:GetOtherByStr("change_camp_need_item_weak")
		need_gold = CampData.Instance:GetOtherByStr("change_camp_need_gold_weak")
	elseif data.consume == 1 then
		need_limit_item = CampData.Instance:GetOtherByStr("change_camp_need_limit_item_stronge")
		need_item = CampData.Instance:GetOtherByStr("change_camp_need_item_stronge")
		need_gold = CampData.Instance:GetOtherByStr("change_camp_need_gold_stronge")
	end


	if need_limit_item ~= nil and next(need_limit_item) ~= nil then
		local num = ItemData.Instance:GetItemNumInBagById(need_limit_item.item_id)
		has_num = has_num + num
		cost_num = need_limit_item.num

		if has_num >= cost_num then
			need_check = false
		end

		consume_item_id = need_limit_item.item_id
	end

	if need_item and next(need_item) ~= nil and need_check then
		local num = ItemData.Instance:GetItemNumInBagById(need_item.item_id)
		has_num = has_num + num
		cost_num = need_item.num	
		if has_num < cost_num then
			color = TEXT_COLOR.RED_1
		end		

		consume_item_id = need_item.item_id
	end

	local real_str = ""
	local real_tip_str = ""
	if has_num <= 0 and need_gold ~= nil then
		if data.consume == 0 then
			real_str = ToColorStr(need_gold .. Language.Task.QuickDoneRedText, TEXT_COLOR.YELLOW)
			self.cost_str = string.format(Language.Common.ChangeCampCostGold, need_gold .. Language.Task.QuickDoneRedText)
		elseif data.consume == 1 then
			real_str = ToColorStr(need_gold, TEXT_COLOR.YELLOW)
			self.cost_str = string.format(Language.Common.ChangeCampCostGold, need_gold)
		end

		real_tip_str = Language.KuafuGuildBattle.KfGuildConsumeGold
	else
		real_str = ToColorStr(has_num, color) .. ToColorStr("/" .. cost_num, TEXT_COLOR.WHITE)

		if consume_item_id ~= nil then
			local item_cfg = ItemData.Instance:GetItemConfig(consume_item_id)
			if item_cfg ~= nil then
				real_tip_str = string.format(Language.Common.NeedConsumeStr, item_cfg.name)
				self.cost_str = string.format(Language.Common.ChangeCampCostItem, item_cfg.name .. "*" .. cost_num)
			end
		end
	end

	if self.consume_str ~= nil then
		self.consume_str:SetValue(real_str)
	end

	if self.tip_str ~= nil then
		self.tip_str:SetValue(real_tip_str)
	end
end

function CampChangeView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(244)
end