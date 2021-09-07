TeamSkillView = TeamSkillView or BaseClass(BaseRender)
function TeamSkillView:__init()
	self.skill_list = {}

	self.client_index = 1
	self.skill_type = 0
	self.server_index = 0
	self.jinjie_next_time = 0
	self.is_auto = false
end

function TeamSkillView:__delete()
	self.skill_list = {}

	if self.stuff_item_1 then
		self.stuff_item_1:DeleteMe()
		self.stuff_item_1 = nil
	end

	if self.stuff_item_2 then
		self.stuff_item_2:DeleteMe()
		self.stuff_item_2 = nil
	end
end

function TeamSkillView:ReleaseCallBack()
	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
	self.item_num2 = nil
end

function TeamSkillView:LoadCallBack()
	for i = 1, TEAM_SKILL.TOTLE_NUM do
		local temp = {}
		local skill_obj = self:FindObj("Skill_" .. i)
		local arrow = skill_obj:FindObj("Arrow")
		temp.obj = skill_obj
		temp.level = skill_obj:FindObj("Level")
		temp.icon = skill_obj:FindObj("Icon")
		temp.arrow = arrow
		temp.animator = arrow.animator
		self.skill_list[i] = temp
	end

	-- 右边信息面板
	self.top_name_icon = self:FindVariable("TopNameIcon")
	self.can_up = self:FindVariable("CanUp")
	self.up_string = self:FindVariable("UpString")
	self.top_icon = self:FindVariable("TopIcon")
	self.top_name = self:FindVariable("TopName")
	self.select_level = self:FindVariable("SelectLevel")
	self.skill_other_info = self:FindVariable("SkillInfo")
	self.skill_desc = self:FindVariable("SkillDesc")
	self.exp_text = self:FindVariable("SkillExp")
	self.exp_progress = self:FindVariable("Progress")
	self.attr_obj = self:FindObj("AttrObj")
	self.in_auto = self:FindVariable("InAuto")
	self.special_desc = self:FindVariable("SpecialDesc")
	self.btn_auto_text = self:FindVariable("BtnAutoText")
	self.btn_auto_text:SetValue(Language.Common.AutoUpgrade)

	self.cap_value = self:FindVariable("Cap")
	self.is_max = self:FindVariable("IsMax")

	self.stuff_item_1 = ItemCell.New()
	self.stuff_item_1:SetInstanceParent(self:FindObj("Item_1"))
	self.stuff_item_2 = ItemCell.New()
	self.stuff_item_2:SetInstanceParent(self:FindObj("Item_2"))

	self.item_num = self:FindVariable("ItemNum")
	self.item_num2 = self:FindVariable("ItemNum2")

	self:ListenEvent("OnClickUpGrade", BindTool.Bind(self.OnClickUpGradeOnce, self))
	self:ListenEvent("OnClickAutoUpGrade", BindTool.Bind(self.OnClickAutoUpGrade, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	local skill_data_list = RoleSkillData.Instance:GetTeamSkillClientList()

	for k, v in pairs(self.skill_list) do
		local data = skill_data_list[k]
		v.obj.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickSkill, self, k, data.skill_type, data.index))
		local bundle, asset = ResPath.GetRoleSkillIcon(data.skill_icon)
		v.icon.image:LoadSprite(bundle, asset)
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").other[1]
	self.stuff_item_1:SetData({item_id = other_cfg.uplevel_skill_stuff_id})
	self.stuff_item_2:SetData({item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN})
	local coin = GameVoManager.Instance:GetMainRoleVo().coin
	local item_num2_str = ""
	if coin < other_cfg.uplevel_skill_need_coin then
		item_num2_str = ToColorStr(CommonDataManager.ConverMoney(other_cfg.uplevel_skill_need_coin), COLOR.RED)
	else
		item_num2_str = ToColorStr(CommonDataManager.ConverMoney(other_cfg.uplevel_skill_need_coin), COLOR.GREEN)
	end
	self.item_num2:SetValue(item_num2_str)
	RoleSkillData.Instance:ChangeClick(self.client_index)

	if not self.item_change then
		self.item_change = BindTool.Bind(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end
end

function TeamSkillView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			for k,v in pairs(self.skill_list) do
				local data = RoleSkillData.Instance:GetSkillInfo(k)
				v.level.text.text = data and data.level or 0
				local flag = RoleSkillData.Instance:IsShowTeamSkillRedPoint(k)
				v.arrow:SetActive(flag)
			end

			self:FlushBlessInfo()
			self:FlushSkillInfo()	
		elseif k == "add_exp" then
			self:FlushBlessInfo()
			self:FlushConsume()
			self:CheckCanUp()		
		elseif k == "item_change" then
			self:FlushConsume()		
		end
	end
end

function TeamSkillView:OnClickUpGradeOnce()
	RoleSkillCtrl:SendTeamSkillOperateReq(TEAM_SKILL_OPERA_REQ_TYPE.TEAM_SKILL_OPERA_REQ_TYPE_UPLEVEL_SKILL, self.skill_type, self.server_index)
end

function TeamSkillView:OnClickAutoUpGrade()
	if self.is_auto then
		self:StopAutoUpGrade()
	else
		self.is_auto = true
		self.btn_auto_text:SetValue(Language.Common.Stop)
		self.in_auto:SetValue(true)
		self.jinjie_next_time = Status.NowTime + 0.3
		self:AutoUpGradeTimeQuest()
	end
end

function TeamSkillView:AutoUpGradeTimeQuest()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnAutoUpGradeOnce, self), jinjie_next_time)
	end
end

function TeamSkillView:OnAutoUpGradeOnce()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(self.client_index)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(self.skill_type, self.server_index, skill_info.level or 0)
	local pack_num = skill_level_cfg.pack_num or 1
	RoleSkillCtrl:SendTeamSkillOperateReq(TEAM_SKILL_OPERA_REQ_TYPE.TEAM_SKILL_OPERA_REQ_TYPE_AUTO_UPLEVEL_SKILL, self.skill_type, self.server_index, pack_num)
end

function TeamSkillView:StopAutoUpGrade()
	self.is_auto = false
	self.btn_auto_text:SetValue(Language.Common.AutoUpgrade)
	self.in_auto:SetValue(false)
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function TeamSkillView:OnClickSkill(client_index, skill_type, server_index, ison)
	if self.skill_type ~= skill_type then
		self:StopAutoUpGrade()
	end
	if ison then
		self.client_index = client_index
		self.skill_type = skill_type
		self.server_index = server_index
		self:FlushSkillInfo()
		self:FlushBlessInfo()
		RoleSkillData.Instance:ChangeClick(client_index)
	end
end

function TeamSkillView:FlushSkillInfo()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(self.client_index)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(self.skill_type, self.server_index, skill_info.level or 0)
	local next_cfg = RoleSkillData.Instance:GetTeamSingleCfg(self.skill_type, self.server_index, skill_info.level and skill_info.level + 1 or 0)

	local show_cfg = skill_info.level > 0 and skill_level_cfg or next_cfg
	CommonDataManager.SetRoleAttr(self.attr_obj, show_cfg, next_cfg)
	-- self.exp_text:SetValue(skill_info.exp .. "/" .. skill_level_cfg.exp)
	-- local percent = skill_info.exp / skill_level_cfg.exp
	-- if skill_level_cfg.exp <= 0 then
	-- 	percent = 0
	-- end
	-- self.exp_progress:SetValue(percent)
	self.select_level:SetValue(skill_info.level)

	local skill_id = skill_level_cfg.active_skill_id > 0 and skill_level_cfg.active_skill_id or next_cfg.active_skill_id
	local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
	local role_skill_cfg = SkillData.GetSkillConfigByIdLevel(skill_id, skill_info.level)
	if not skill_cfg then print_error("cannot find skill config, id :", skill_id) return end

	if skill_info.level > 0 then
		self.is_max:SetValue(next_cfg == nil or next(next_cfg) == nil)
	end

	self.top_name:SetValue(skill_cfg.skill_name)

	local skill_desc = string.gsub(skill_cfg.skill_desc2, "%b()%%", function (str)
			return  role_skill_cfg and (tonumber(role_skill_cfg[string.sub(str, 2, -3)])) .. "%" or "0%"
		end)
		skill_desc = string.gsub(skill_desc, "%b[]%%", function (str)
			return role_skill_cfg and (tonumber(role_skill_cfg[string.sub(str, 2, -3)]) / 100) .. "%" or "0%"
		end)
		skill_desc = string.gsub(skill_desc, "%[.-%]", function (str)
			return role_skill_cfg and role_skill_cfg[string.sub(str, 2, -2)] or 0
		end)
		skill_desc = string.gsub(skill_desc, "%(.-%)", function (str)
			return role_skill_cfg and role_skill_cfg[string.sub(str, 2, -2)] / 1000 or 0
		end)

	local skill_other_info = string.gsub(skill_cfg.skill_desc, "%(.-%)" , function(str)
			return role_skill_cfg and role_skill_cfg[string.sub(str, 2, -2)] / 1000 or 0
		end)

	skill_other_info = string.gsub(skill_other_info, "%[.-%]" , function(str)
			return role_skill_cfg and role_skill_cfg[string.sub(str, 2, -2)] or 0
		end)


	self.skill_other_info:SetValue(skill_other_info)
	self.skill_desc:SetValue(skill_desc)
	local bundle, asset = ResPath.GetRoleSkillIcon(skill_cfg.skill_icon)
	self.top_icon:SetAsset(bundle, asset)
	self.top_name_icon:SetAsset(ResPath.GetRoleSkillName(skill_cfg.skill_icon))
	self:FlushConsume()
	self:CheckCanUp()
	if self.cap_value ~= nil then
		self.cap_value:SetValue(RoleSkillData.Instance:GetTeamAllCap())
	end
end

function TeamSkillView:FlushConsume()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(self.client_index)
	if skill_info == nil or next(skill_info) == nil then
		return
	end

	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(self.skill_type, self.server_index, skill_info.level or 0)
	if skill_level_cfg == nil or next(skill_level_cfg) == nil then
		return
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").other[1]
	local own_num = ItemData.Instance:GetItemNumInBagById(other_cfg.uplevel_skill_stuff_id)
	local color = own_num >= 1 and COLOR.GREEN or COLOR.RED
	own_num = ToColorStr(own_num, color)
	self.item_num:SetValue(own_num .. "/1")
	self.special_desc:SetValue(skill_level_cfg.upgrade_explain or "")
end

function TeamSkillView:FlushBlessInfo()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(self.client_index)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(self.skill_type, self.server_index, skill_info.level or 0)
	self.exp_text:SetValue(skill_info.exp .. "/" .. skill_level_cfg.exp)
	local percent = skill_info.exp / skill_level_cfg.exp
	if skill_level_cfg.exp <= 0 then
		percent = 0
	end
	self.exp_progress:SetValue(percent)
end

-- 恶心策划的限制条件
-- 条件写死 数值读配置
function TeamSkillView:CheckCanUp()
	local check_list = RoleSkillData.Instance:GetTeamSkillCheckList()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("teamskill_cfg_auto").other[1]
	local skill_info = RoleSkillData.Instance:GetSkillInfo(self.client_index)
	local high_skill = RoleSkillData.Instance:GetSkillInfo(1)

	local can_up = true
	local up_string = ""
	if TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_HIGH == self.skill_type then	
	elseif TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_MEDIAN == self.skill_type then
		local info_list = check_list[TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_MEDIAN]

		if high_skill.level < other_cfg.learn_median_skill_cond then
			local high_level = high_skill.level > 0 and high_skill.level or 1
			local high_skill_cfg = RoleSkillData.Instance:GetTeamSingleCfg(TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_HIGH, 0, high_level)
			local role_skill_cfg = SkillData.GetSkillinfoConfig(high_skill_cfg.active_skill_id)
			-- up_string = string.format(Language.TeamSkill.SingleSkillNotEnough, role_skill_cfg.skill_name)
			up_string = string.format(Language.TeamSkill.CanNotLearnSkill, role_skill_cfg.skill_name, high_skill.level, other_cfg.learn_median_skill_cond)
			can_up = false
		end

	elseif TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_PRIMARY == self.skill_type then
		-- 要检查对应父节点等级
		local info_list = check_list[TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_PRIMARY]
		local median_list = check_list[TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_MEDIAN]
		local median_check_index = math.floor(self.server_index / TEAM_SKILL.MEDIAN)

		if median_check_index < 0 or median_check_index >= TEAM_SKILL.MEDIAN then
			can_up = false
		end

		if median_list[median_check_index].level < other_cfg.learn_base_skill_cond then
			local median_level = median_list[median_check_index].level > 0 and median_list[median_check_index].level or 1
			local median_skill_cfg = RoleSkillData.Instance:GetTeamSingleCfg(TEAM_SKILL_SKILL_TYPE.TEAM_SKILL_SKILL_TYPE_MEDIAN, median_check_index, median_level)
			local role_skill_cfg = SkillData.GetSkillinfoConfig(median_skill_cfg.active_skill_id)
			-- up_string = string.format(Language.TeamSkill.SingleSkillNotEnough, role_skill_cfg.skill_name)
			up_string = string.format(Language.TeamSkill.CanNotLearnSkill, role_skill_cfg.skill_name, median_list[median_check_index].level, other_cfg.learn_base_skill_cond)
			can_up = false
		end
	end
	self.can_up:SetValue(can_up)
	self.up_string:SetValue(up_string)
end

function TeamSkillView:GetIsInAuto()
	return self.is_auto
end

function TeamSkillView:OnClickHelp()
	local help_id = 205
	TipsCtrl.Instance:ShowHelpTipView(help_id)
end

function TeamSkillView:ItemDataChangeCallback()
	self:Flush("item_change")
end