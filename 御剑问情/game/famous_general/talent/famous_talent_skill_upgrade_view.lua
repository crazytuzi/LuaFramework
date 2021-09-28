FamousTalentSkillUpgradeView = FamousTalentSkillUpgradeView or BaseClass(BaseView)

function FamousTalentSkillUpgradeView:__init()
	self.ui_config = {"uis/views/famous_general_prefab","FamousTalentSkillTips"}
	self.play_audio = true
end

function FamousTalentSkillUpgradeView:__delete()
	
end
-- 创建完调用
function FamousTalentSkillUpgradeView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickUpgradeButton",
		BindTool.Bind(self.OnClickUpgradeButton, self))

	self.level = self:FindVariable("Level")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.skill_name = self:FindVariable("SkillName")
	self.need_pro_name = self:FindVariable("NeedProName")
	self.need_pro_num = self:FindVariable("NeedProNum")
	self.is_show_next_effect = self:FindVariable("IsShowNextEffect")
	self.show_max_level_tip = self:FindVariable("ShowMaxLevelTip")
	self.condition_name = self:FindVariable("ConditionName")
	self.active_condition = self:FindVariable("ActiveCondition")
	self.is_show_level = self:FindVariable("IsShowLevel")
end

function FamousTalentSkillUpgradeView:ReleaseCallBack()
	-- 清理变量和对象
	self.level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.skill_icon = nil
	self.skill_name = nil
	self.need_pro_name = nil
	self.need_pro_num = nil
	self.is_show_next_effect = nil
	self.show_max_level_tip = nil
	self.normal_skill_up_view = nil
	self.gray_up_level_btn = nil
	self.condition_name = nil
	self.active_condition = nil
	self.is_show_level = nil
end

function FamousTalentSkillUpgradeView:OpenCallBack()
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FamousTalentSkillUpgradeView:CloseCallBack()
	self.select_info = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function FamousTalentSkillUpgradeView:ItemDataChangeCallback()
	self:Flush()
end

function FamousTalentSkillUpgradeView:OnClickUpgradeButton()
	if nil == self.select_info then
		return
	end

	FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_SKILL_UPLEVEL, self.select_info.talent_type,  self.select_info.grid_index, 0)
end

function FamousTalentSkillUpgradeView:SetSelectInfo(select_info)
	self.select_info = select_info
end

function FamousTalentSkillUpgradeView:OnFlush(param_list)
	local talent_info_list = FamousTalentData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]

	local skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local next_skill_cfg = FamousTalentData.Instance:GetTalentSkillNextConfig(talent_info.skill_id, talent_info.skill_star)

	self.is_show_next_effect:SetValue(0 ~= talent_info.skill_id)
	self.condition_name:SetValue(nil == skill_cfg and Language.TalentTypeName.JiHuo or Language.TalentTypeName.ShengJi)

	local cond_str = FamousTalentData.Instance:GetTalentGridActiveCondition(self.select_info.talent_type, self.select_info.grid_index)
	self.active_condition:SetValue(0 == talent_info.is_open and cond_str or "")

	local is_active = true
	if nil == skill_cfg then
		local talent_type_cfg = FamousTalentData.Instance:GetTalentConfig(self.select_info.talent_type)
		skill_cfg = FamousTalentData.Instance:GetTalentTypeFirstConfigBySkillType(talent_type_cfg.skill_type)
		is_active = false
	end
	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.skill_icon:SetAsset(bundle, asset)
	self.skill_name:SetValue(ToColorStr(item_cfg.name, SKILL_ITEM_COLOR[item_cfg.color or 0]))

	self.level:SetValue(skill_cfg.skill_quality)
	self.current_effect:SetValue(skill_cfg.description)

	local need_item_cfg = ItemData.Instance:GetItemConfig(is_active and skill_cfg.need_item_id or skill_cfg.book_id)
	self.need_pro_name:SetValue(ToColorStr(need_item_cfg.name, SKILL_ITEM_COLOR[need_item_cfg.color or 0]))

	local item_num = ItemData.Instance:GetItemNumInBagById(is_active and skill_cfg.need_item_id or skill_cfg.book_id)
	local txt_color = item_num >= skill_cfg.need_item_count and TEXT_COLOR.YELLOW1 or TEXT_COLOR.RED
	local str = ToColorStr(item_num, txt_color)
	str = ToColorStr("(" .. str .. " / " .. skill_cfg.need_item_count .. ")", TEXT_COLOR.BLACK_1)
	self.need_pro_num:SetValue(str)

	self.show_max_level_tip:SetValue(0 ~= talent_info.skill_id and nil == next_skill_cfg)
	self.next_effect:SetValue(next_skill_cfg and next_skill_cfg.description or "		" ..Language.TalentTypeName.SkillMaxLevel)

	self.is_show_level:SetValue(0 ~= talent_info.skill_id)
end