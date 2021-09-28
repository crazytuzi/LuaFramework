FamousTalentUpgradeView = FamousTalentUpgradeView or BaseClass(BaseView)

function FamousTalentUpgradeView:__init()
	self.ui_config = {"uis/views/famous_general_prefab", "FamousTalentUpgradeView"}
	self.play_audio = true
	self.fight_info_view = true
	self.is_from_bag = true
end

function FamousTalentUpgradeView:__delete()
	
end

function FamousTalentUpgradeView:ReleaseCallBack()
	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	if nil ~= self.next_item then
		self.next_item:DeleteMe()
		self.next_item = nil
	end

	-- 清理变量
	self.is_show_next = nil

	self.name = nil
	self.next_name = nil
		
	self.cur_attr = nil
	self.next_attr = nil

	self.need_fragment = nil
	self.forget_gold = nil

	self.show_cur_attr_1 = nil
	self.show_cur_attr_2 = nil

	self.var_show_cur_icon_1 = nil
	self.var_show_cur_icon_2 = nil
	
	self.asset_show_cur_icon_1 = nil
	self.asset_show_cur_icon_2 = nil

	self.cur_attr_str1 = nil
	self.cur_attr_str2 = nil

	self.show_next_attr_1 = nil
	self.show_next_attr_2 = nil

	self.var_show_next_icon_1 = nil
	self.var_show_next_icon_2 = nil
	
	self.asset_show_next_icon_1 = nil
	self.asset_show_next_icon_2 = nil

	self.next_attr_str1 = nil
	self.next_attr_str2 = nil

	self.cur_skill_desc = nil
	self.next_skill_desc = nil

	self.auto_toggle = nil
	self.is_show_toggle = nil
	
	if self.delay_button_timer then
		GlobalTimerQuest:CancelQuest(self.delay_button_timer)
	end

end

function FamousTalentUpgradeView:LoadCallBack()
	self:ListenEvent("OnClickUpgrade",BindTool.Bind(self.OnClickUpgrade, self))
	self:ListenEvent("OnClickTakeOff",BindTool.Bind(self.OnClickTakeOff, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.Close, self))

	self.is_show_next = self:FindVariable("Is_Show_Next")

	self.name = self:FindVariable("CurName")
	self.next_name = self:FindVariable("NextName")

	self.cur_attr = self:FindVariable("CurAtt")
	self.next_attr = self:FindVariable("NextAttr")

	self.need_fragment = self:FindVariable("NeedFragments")
	self.forget_gold = self:FindVariable("Forget_Gold")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("ItemCell"))
	self.item:SetData()

	self.next_item = ItemCell.New()
	self.next_item:SetInstanceParent(self:FindObj("NextItemCell"))
	self.next_item:SetData()

	self.show_cur_attr_1 = self:FindVariable("Show_Cur_Attr_1")
	self.show_cur_attr_2 = self:FindVariable("Show_Cur_Attr_2")

	self.var_show_cur_icon_1 = self:FindVariable("Show_Cur_Icon_1")
	self.var_show_cur_icon_2 = self:FindVariable("Show_Cur_Icon_2")
	
	self.asset_show_cur_icon_1 = self:FindVariable("Cur_Icon_1")
	self.asset_show_cur_icon_2 = self:FindVariable("Cur_Icon_2")

	self.cur_attr_str1 = self:FindVariable("Cur_Attr_Str1")
	self.cur_attr_str2 = self:FindVariable("Cur_Attr_Str2")

	self.show_next_attr_1 = self:FindVariable("Show_Next_Attr_1")
	self.show_next_attr_2 = self:FindVariable("Show_Next_Attr_2")

	self.var_show_next_icon_1 = self:FindVariable("Show_Next_Icon_1")
	self.var_show_next_icon_2 = self:FindVariable("Show_Next_Icon_2")
	
	self.asset_show_next_icon_1 = self:FindVariable("Next_Icon_1")
	self.asset_show_next_icon_2 = self:FindVariable("Next_Icon_2")

	self.next_attr_str1 = self:FindVariable("Next_Attr_Str1")
	self.next_attr_str2 = self:FindVariable("Next_Attr_Str2")

	self.cur_skill_desc = self:FindVariable("Cur_Skill_Desc")
	self.next_skill_desc = self:FindVariable("Next_Skill_Desc")

	self.auto_toggle = self:FindObj("AutoToggle")
	self.auto_toggle.toggle.isOn = self.is_auto_buy
	self.auto_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))

	self.is_show_toggle = self:FindVariable("IsShowToggle")
end

function FamousTalentUpgradeView:OpenCallBack()
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FamousTalentUpgradeView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function FamousTalentUpgradeView:OnAutoBuyToggleChange(isOn)
	self.is_auto_buy = isOn
end

function FamousTalentUpgradeView:ItemDataChangeCallback()
	self:FlushNextAttr()
end

function FamousTalentUpgradeView:OnFlush(param_t)
	if not self:IsRealOpen() then
		return
	end
	self:FlushCurAttr()
	self:FlushNextAttr()
end

function FamousTalentUpgradeView:SetSelectInfo(select_info)
	self.select_info = select_info
end

function FamousTalentUpgradeView:OnClickUpgrade()
	if nil == self.select_info then
		return
	end
	-- 阻止玩家操作过于频繁导致的错误
	if self.upgrade_button_flag then
		return
	end
	local talent_info_list = FamousTalentData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]
	local skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)
	local need_item_data = ShopData.Instance:GetShopItemCfg(skill_cfg.need_item_id)
	if item_num < skill_cfg.need_item_count and not self.is_auto_buy and need_item_data ~= nil then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, skill_cfg.need_item_id, nil, skill_cfg.need_item_count - item_num)
		return
	end
	
	local is_auto = (self.is_auto_buy and nil ~= need_item_data) and 1 or 0
	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_SKILL_UPLEVEL, self.select_info.talent_type,  self.select_info.grid_index, is_auto)
	self.upgrade_button_flag = true
	if self.delay_button_timer then
		GlobalTimerQuest:CancelQuest(self.delay_button_timer)
	end
	self.delay_button_timer = GlobalTimerQuest:AddDelayTimer(function ()
		if self.upgrade_button_flag then
			self.upgrade_button_flag = false
		end
	end,0.5)
end

function FamousTalentUpgradeView:OnClickTakeOff()
	if nil == self.select_info then
		return
	end
	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_PUTOFF, self.select_info.talent_type,  self.select_info.grid_index)
	self:Close()
end

function FamousTalentUpgradeView:FlushCurAttr()
	local talent_info_list = FamousTalentData.Instance:GetTalentAllInfo()
	if next(talent_info_list) == nil or talent_info_list == nil then
		print_error("协议异常")
		return
	end

	if self.select_info == nil then
		print_error("数据被清空")
		return
	end

	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]
	local skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)

	if skill_cfg == nil then
		return
	end
	
	if 1 == talent_info.is_open then
		self.item:SetCellLock(false)
		if 0 ~= talent_info.skill_id then
			self.item:ShowQuality(true)
			self.item:SetData({item_id = skill_cfg.book_id})
			self.item:SetShowStar(skill_cfg.skill_star)
		else
			self.item:SetData(nil)
			self.item:ShowQuality(false)
		end
	else
		self.item:SetCellLock(true)
		self.item:SetData(nil)
		self.item:ShowQuality(false)
	end

	self.forget_gold:SetValue(skill_cfg.forget_gold)

	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	local item_name_color = ITEM_COLOR[item_cfg.color or 0]
	if item_cfg.color == GameEnum.ITEM_COLOR_GREEN then
		item_name_color = TEXT_COLOR.GREEN
	end
	self.name:SetValue(ToColorStr(item_cfg.name, item_name_color))

	local attr_data = FamousTalentData.Instance:GetTalentAttrDataList(skill_cfg, self.select_info.talent_type)
	if nil ~= attr_data and nil ~= attr_data.desc then
		self.cur_skill_desc:SetValue(attr_data.desc)
		self.show_cur_attr_1:SetValue(false)
		self.show_cur_attr_2:SetValue(false)
		return
	else
		self.cur_skill_desc:SetValue("")
	end

	self.show_cur_attr_1:SetValue(nil ~= attr_data[1])
	self.show_cur_attr_2:SetValue(nil ~= attr_data[2])

	if nil ~= attr_data[1] then
		self.var_show_cur_icon_1:SetValue(nil ~= attr_data[1].icon)
		if nil ~= attr_data[1].icon then
			self.asset_show_cur_icon_1:SetAsset("uis/images_atlas", attr_data[1].icon)
		end
		self.cur_attr_str1:SetValue(attr_data[1].str or "")
	end

	if nil ~= attr_data[2] then
		self.var_show_cur_icon_2:SetValue(nil ~= attr_data[2].icon)
		self.asset_show_cur_icon_2:SetAsset("uis/images_atlas", attr_data[2].icon)
		self.cur_attr_str2:SetValue(attr_data[2] and attr_data[2].str or "")
	end
end

function FamousTalentUpgradeView:FlushNextAttr()
	local talent_info_list = FamousTalentData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]

	local skill_cfg = FamousTalentData.Instance:GetTalentSkillNextConfig(talent_info.skill_id, talent_info.skill_star)
	if nil == skill_cfg then
		self.is_show_next:SetValue(false)
		return
	else
		self.is_show_next:SetValue(true)
	end

	if 1 == talent_info.is_open then
		self.next_item:SetCellLock(false)
		if 0 ~= talent_info.skill_id then
			self.next_item:ShowQuality(true)
			self.next_item:SetData({item_id = skill_cfg.book_id})
			self.next_item:SetShowStar(skill_cfg.skill_star)
		else
			self.next_item:SetData(nil)
			self.next_item:ShowQuality(false)
		end
	else
		self.next_item:SetCellLock(true)
		self.next_item:SetData(nil)
		self.next_item:ShowQuality(false)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	local item_name_color = ITEM_COLOR[item_cfg.color or 0]
	if item_cfg.color == GameEnum.ITEM_COLOR_GREEN then
		item_name_color = TEXT_COLOR.GREEN
	end
	self.next_name:SetValue(ToColorStr(item_cfg.name, item_name_color))

	local cur_skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local need_item_cfg = ItemData.Instance:GetItemConfig(cur_skill_cfg.need_item_id)
	local need_item_name = ToColorStr(need_item_cfg.name, ITEM_COLOR[need_item_cfg.color or 0])

	local item_num = ItemData.Instance:GetItemNumInBagById(cur_skill_cfg.need_item_id)
	local txt_color = item_num >= cur_skill_cfg.need_item_count and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	item_num = ToColorStr(item_num, txt_color)
	local str = need_item_name .. string.format(Language.Common.CurNumAndNextNum, item_num, cur_skill_cfg.need_item_count)
	self.need_fragment:SetValue(string.format(Language.TalentTypeName.NeedFragments, str))

	local need_item_data = ShopData.Instance:GetShopItemCfg(cur_skill_cfg.need_item_id)
	self.is_show_toggle:SetValue(nil ~= need_item_data)

	local attr_data = FamousTalentData.Instance:GetTalentAttrDataList(skill_cfg, self.select_info.talent_type)
	if nil ~= attr_data and nil ~= attr_data.desc then
		self.next_skill_desc:SetValue(attr_data.desc)
		self.show_next_attr_1:SetValue(false)
		self.show_next_attr_2:SetValue(false)
		return
	else
		self.next_skill_desc:SetValue("")
	end

	self.show_next_attr_1:SetValue(nil ~= attr_data[1])
	self.show_next_attr_2:SetValue(nil ~= attr_data[2])

	if nil ~= attr_data[1] then
		self.var_show_next_icon_1:SetValue(nil ~= attr_data[1].icon)
		if nil ~= attr_data[1].icon then
			self.asset_show_next_icon_1:SetAsset("uis/images_atlas", attr_data[1].icon)
		end
		self.next_attr_str1:SetValue(attr_data[1].str or "")
	end

	if nil ~= attr_data[2] then
		self.var_show_next_icon_2:SetValue(nil ~= attr_data[2].icon)
		self.asset_show_next_icon_2:SetAsset("uis/images_atlas", attr_data[2].icon)
		self.next_attr_str2:SetValue(attr_data[2] and attr_data[2].str or "")
	end
end

