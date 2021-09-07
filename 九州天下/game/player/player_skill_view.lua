PlayerSkillView = PlayerSkillView or BaseClass(BaseRender)

local EFFECT_CD = 0.8
local PROFESSOIN_SKILL_NUM = 5 	-- 主动技能数
local PASSIVE_SKILL_NUM = 7 	-- 被动技能数
local KILL_SKILL_ID = 5			-- 必杀技ID

local PASSVIE_SKILL_ID_STAR = 41	-- 被动技能起始ID
local PASSVIE_SKILL_ID_END = 47		-- 被动技能结束ID

function PlayerSkillView:__init(instance, parent_view)
	self.parent_view = parent_view
	self:ListenEvent("OnClickUpgradeButton",
		BindTool.Bind(self.OnClickUpgradeButton, self))
	self:ListenEvent("OnClickProfessionButton",
		BindTool.Bind(self.OnClickProfessionButton, self))
	self:ListenEvent("OnClickPassiveButton",
		BindTool.Bind(self.OnClickPassiveButton, self))
	self:ListenEvent("StopLevelUp",
		BindTool.Bind(self.StopLevelUp, self))

	self.miehsi_skill_list = {}
	for i = 8, 10 do
		self:ListenEvent("OnClickMieShi"..i, BindTool.Bind(self.OnClickMieShi, self, i))
		self.miehsi_skill_list[i] = {icon = self:FindVariable("MieShiSkillIcon"..i), gray = self:FindVariable("MieShiSkillIconGray"..i)}
	end

	self.skill_type = self:FindVariable("Type")
	self.skill_cur_level = self:FindVariable("CurrentLevel")
	self.skill_max_level = self:FindVariable("MaxLevel")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.skill_name = self:FindVariable("SkillName")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.exp_current_num = self:FindVariable("ExpCurValue")
	self.exp_max_num = self:FindVariable("ExpMaxValue")
	self.is_show_curr_effect = self:FindVariable("IsShowCurrentEffect")
	self.is_show_next_effect = self:FindVariable("IsShowNextEffect")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_progress = self:FindVariable("ShowProgress")

	self.up_need_material = self:FindVariable("NeedMaterial")
	self.up_need_material_num = self:FindVariable("NeedMaterialNum")
	self.up_have_material_num = self:FindVariable("HaveMaterialNum")
	self.current_fightpower = self:FindVariable("CurrentFightPower")
	self.next_fightpower = self:FindVariable("NextFightPower")
	self.next_fightpower = self:FindVariable("NextFightPower")
	self.show_stop = self:FindVariable("ShowStop")
	self.show_stop:SetValue(false)
	self.show_material = self:FindVariable("ShowMaterial")
	self.show_fight_power = self:FindVariable("ShowFightPower")
	self.show_mieshi_info = self:FindVariable("ShowMieshiInfo")
	self.mieshi_info_text = self:FindVariable("MieShiInfoText")
	self.show_mieshi_level = self:FindVariable("ShowMieShiLevel")
	self.mieshi_level = self:FindVariable("MieShiLevel")

	self.pro_skill_btn = self:FindObj("ProfessionSkilButton")
	self.passive_skill_btn = self:FindObj("PassiveSkilButton")
	self.upgrade_button = self:FindObj("UpgradeButton")

	self.passive_index = 7
	self.last_passive_index = 7
	self.profession_skill = {}							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.passive_skill = {}								-- 被动技能
	self.profession_skill_data = {}
	self.passive_skill_data = {}
	for i = 1, PROFESSOIN_SKILL_NUM do
		local skill = self:FindObj("ProSkill"..i)
		local icon = skill:FindObj("Icon")
		local name_lable = skill:FindObj("SkillNameLable")
		local skill_name = name_lable:FindObj("Name")
		local skill_level = name_lable:FindObj("Level")
		table.insert(self.profession_skill, {skill = skill, icon = icon,
					 name_lable = name_lable, skill_name = skill_name, skill_level = skill_level})
	end

	for i = 1, PASSIVE_SKILL_NUM do
		local skill = self:FindObj("PassiveSkill"..i)
		local icon = skill:FindObj("Icon")
		local arrow = skill:FindObj("Arrow")
		local effect = skill:FindObj("UI_Effect")
		local animator = arrow.animator
		table.insert(self.passive_skill, {skill = skill, icon = icon, arrow = arrow, animator = animator, effect = effect})
	end

	self.profession_skill_data, self.passive_skill_data = self:InitAllSkillList()
	self.index = 1
	self.temp_skill_id = 0
	self:AddSkillListenEvent()
	self.is_click_skill = false
	self.attack_hit_handle = {}
	self.passive_level_list = {}
	self.effect_cd = 0
	self.auto_level_up = false
	self.is_set_model = false
	self.cur_toggle_state = -1
end

function PlayerSkillView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)

	self.parent_view = nil
	self.index = nil
	self.temp_skill_id = nil
	self.profession_skill = nil							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.passive_skill = nil								-- 被动技能
	self.profession_skill_data = nil
	self.passive_skill_data = nil
	self.is_init_exp_radio = nil
	self.is_click_skill = nil
	self.is_set_model = nil
	self.passive_level_list = {}
	if self.go then
		GameObject.Destroy(self.go.gameObject)
	end
	for k, v in pairs(self.attack_hit_handle) do
		v:Dispose()
	end

	self.attack_hit_handle = {}
	self:StopLevelUp()
	self:RemoveCountDown()
end

function PlayerSkillView:InitAllSkillList()
	local profession_skill_data = {}
	local passive_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for skill_id, v in pairs(skillinfo) do
		if prof == math.modf(skill_id / 100) then
			profession_skill_data[v.skill_index] = v
		elseif skill_id == KILL_SKILL_ID then
			profession_skill_data[v.skill_index] = v
		end
		for i = PASSVIE_SKILL_ID_STAR, PASSVIE_SKILL_ID_END do
			if i == skill_id then
				passive_skill_data[v.skill_index] = v
			end
		end
	end
	return profession_skill_data, passive_skill_data
end

-- 灭世技能
function PlayerSkillView:OnClickMieShi(index)
	self.index = index
	self.upgrade_button:SetActive(false)
	self.show_material:SetValue(false)
	self.show_fight_power:SetValue(false)
	self:SetMieShiSkillInfo(index)
	self.is_show_next_effect:SetValue(false)
	self.is_show_curr_effect:SetValue(false)
	self.show_mieshi_info:SetValue(true)
	self.show_mieshi_level:SetValue(true)
end

-- 灭世技能信息
function PlayerSkillView:SetMieShiSkillInfo(index)
	local cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").battlefield_goal or {}
	local desc = ""
	local single_cfg = CollectiveGoalsData.Instance:GetGoalsSingleCfg(index - PASSIVE_SKILL_NUM)

	if single_cfg and next(single_cfg) then
		desc = string.gsub(single_cfg.skill_desc2, "%b()%%" , function(str)
			return tonumber(single_cfg[string.sub(str, 2, -3)]) / 1000
		end)
		desc = string.gsub(desc, "%b[]%%" , function(str)
			return tonumber(single_cfg[string.sub(str, 2, -3)]) / 100 .. "%"
		end)
		desc = string.gsub(desc, "%[.-%]" , function(str)
			return single_cfg[string.sub(str, 2, -2)]
		end)

		-- 技能名字
		self.skill_name:SetValue(single_cfg.skill_name)
		local ser_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local is_active = CollectiveGoalsData.Instance:IsGetRewardBySeq(single_cfg.act_sep) or ser_day > single_cfg.open_server_day
		self.mieshi_info_text:SetValue(desc)

		-- local cur_level = is_active and 1 or string.format(Language.Mount.ShowRedStr, 0)   --屏蔽灭世之战
		local cur_level = string.format(Language.Mount.ShowRedStr, 0)
		self.mieshi_level:SetValue(cur_level.."/1")
	end
end

-- 灭世技能图标
function PlayerSkillView:FlushMieShiSkillIcon(index)
	local cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").battlefield_goal or {}
	local bundle, asset = nil, nil
	local ser_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local active = false
	for k, v in pairs(cfg) do
		if v.act_sep == (index - PASSIVE_SKILL_NUM) and self.miehsi_skill_list[index] then
			bundle, asset = ResPath.GetSkillGoalsIcon(v.skill_type)
			 self.miehsi_skill_list[index].icon:SetAsset(bundle, asset)
			 active = ser_day > v.open_server_day
			 self.miehsi_skill_list[index].gray:SetValue(false)
			 -- self.miehsi_skill_list[index].gray:SetValue(CollectiveGoalsData.Instance:IsGetRewardBySeq(v.act_sep) or active)
		end
	end
end

function PlayerSkillView:AddSkillListenEvent()
	for k, v in pairs(self.profession_skill) do
			v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickSkill, self,
				self.profession_skill_data[k].skill_icon, self.profession_skill_data[k].skill_id,
				self.profession_skill_data[k].skill_name, k, false, 0.4))
		end
	for k, v in pairs(self.passive_skill) do
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickSkill, self,
			self.passive_skill_data[k].skill_icon, self.passive_skill_data[k].skill_id,
			self.passive_skill_data[k].skill_name, k, true, 0.4))
	end
	if self.pro_skill_btn.toggle.isOn then
		self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
			 self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 0.4)
		self.profession_skill[self.index].skill.toggle.isOn = true
	else
		self:GetSkillInfo(self.passive_skill_data[self.index].skill_id, self.passive_skill_data[self.index].skill_name, self.index)
		self.passive_skill[self.index].skill.toggle.isOn = true
	end
end

function PlayerSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, is_passive, delay_play_skill_time)
	-- 显示升级按钮
	self.upgrade_button:SetActive(true)

	self.show_mieshi_info:SetValue(false)
	self.show_mieshi_level:SetValue(false)

	if is_passive then
		-- 显示材料
		self.show_material:SetValue(true)
		-- 显示战力
		self.show_fight_power:SetValue(true)

		if self.auto_level_up then
			local temp_skill_id = self.passive_skill_data[self.last_passive_index].skill_id
			local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..temp_skill_id]
			local skill_info = SkillData.Instance:GetSkillInfoById(temp_skill_id)
			local level = skill_info and skill_info.level + 1 or 1
			local item_id = skill_cfg[level] and skill_cfg[level].item_cost_id or 0
			local cost_num = skill_cfg[level] and skill_cfg[level].item_cost or -1
			local index_list = SkillData.Instance:GetPassvieSkillCanUpLevelIndexList(self.passive_skill_data)

			if (level <= 100 and cost_num <= ItemData.Instance:GetItemNumInBagById(item_id)) or (nil == skill_cfg[level] and nil == next(index_list)) then
				self:StopLevelUp()
			end
		end
		self.passive_index = index
	end
	self.index = index
	self.temp_skill_id = skill_id
	self.is_click_skill = true
	self:GetSkillInfo(skill_id, skill_name, index)
	if nil ~= self.skill_delay_timer then
		GlobalTimerQuest:CancelQuest(self.skill_delay_timer)
	end
	self.skill_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self:OnClickPlayButton(self.index)
	end, delay_play_skill_time)
end

function PlayerSkillView:OnClickUpgradeButton()
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..self.temp_skill_id]
	local skill_info = SkillData.Instance:GetSkillInfoById(self.temp_skill_id)
	local level = skill_info and skill_info.level + 1 or 1

	if level > #skill_cfg or nil == skill_cfg[level] then
		self:StopLevelUp()
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.MaxValue)
		return
	end
	local item_id = skill_cfg[level].item_cost_id

	if skill_cfg[level].item_cost > ItemData.Instance:GetItemNumInBagById(item_id) then
		if not self.auto_level_up then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
		end
		self:StopLevelUp()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			-- TipsCtrl.Instance:ShowItemGetWayView(item_id)
			--TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		end
		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
		-- 	return
		-- end
		local func = function(item_id2, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil,
			(item_id - ItemData.Instance:GetItemNumInBagById(item_id)))
	else
		self.auto_level_up = true
		self.show_stop:SetValue(true)
	end

	SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id)
end

function PlayerSkillView:StopLevelUp()
	self.auto_level_up = false
	self.show_stop:SetValue(false)
end

function PlayerSkillView:OnClickPlayButton(index)
	if PlayerCtrl.Instance.view:GetShowIndex() ~= TabIndex.role_skill then
		return
	end

	if not self.pro_skill_btn.toggle.isOn or not self.profession_skill[self.index] or not self.profession_skill[self.index].skill.toggle.isOn then
		return
	end

	self.skill_index = index or self.index
	local skill_action = self.profession_skill_data[index].skill_action

	if self.profession_skill_data[index].hit_count == 1 then
		self:SetDefaultState()
		UIScene:SetTriggerValue(skill_action)
		UIScene:SetAnimation(skill_action)
	elseif self.profession_skill_data[index].hit_count == 3 then
		self:SetDefaultState()
		for i = 1, 3 do
			local normal_skill_action = skill_action.."_"..i
			UIScene:SetTriggerValue(normal_skill_action)
			UIScene:SetAnimation(normal_skill_action)
		end
	end
end

function PlayerSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id]
	self.skill_name:SetValue(skill_name)
	self.is_show_curr_effect:SetValue(skill_info ~= nil)

	if skill_info == nil then
		self:SetSkillInfo(skill_cfg, index, nil, skill_info)
	else
		-- 客户端记录的技能等级，熟练度
		local proficient = SkillData.Instance:GetSkillProficiency(skill_id)
		local level = skill_info.level
		self:SetSkillInfo(skill_cfg, index, level, skill_info)
	end
end

-- 设置角色技能为0级时，右边技能信息的显示
function PlayerSkillView:SetSkillInfo(skill_cfg, index, level, skill_info, is_passive)
	local effect_level = level or 1
	local cur_level = level or 0
	local desc = ""
	local next_desc = ""
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	self.skill_cur_level:SetValue(cur_level)
	self.skill_max_level:SetValue(#skill_cfg)
	if self.pro_skill_btn.toggle.isOn and not is_passive then
		-- 主动技能
		for k, v in pairs(self.profession_skill) do
			local info = SkillData.Instance:GetSkillInfoById(self.profession_skill_data[k].skill_id)
			if info == nil then
				v.icon.grayscale.GrayScale = 255
			else
				v.icon.grayscale.GrayScale = 0
			end
			v.skill_name.text.text = self.profession_skill_data[k].skill_name
			
			local bundle, asset = ResPath.GetRoleSkillIcon(self.profession_skill_data[k].skill_icon)
			if self.profession_skill_data[k].skill_id == KILL_SKILL_ID then
				local skill_icon = self.profession_skill_data[k].skill_icon + main_vo.prof
				bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
			end
			v.icon.image:LoadSprite(bundle, asset)
		end
		if not self.profession_skill_data[index] then return end
		desc = string.gsub(self.profession_skill_data[index].skill_desc, "%b()%%" , function(str)
			return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 1000
		end)
		desc = string.gsub(desc, "%b[]%%" , function(str)
			return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 100 .. "%"
		end)
		desc = string.gsub(desc, "%[.-%]" , function(str)
			return skill_cfg[effect_level][string.sub(str, 2, -2)]
		end)

		self.exp_current_num:SetValue(0)
		self.exp_max_num:SetValue(0)
		self.exp_radio:InitValue(0)

		self.is_show_next_effect:SetValue(true)
		if skill_info then
			if effect_level >= #skill_cfg then
				self.is_show_next_effect:SetValue(false)
				self.exp_current_num:SetValue(0)
				self.exp_radio:InitValue(0)
				self.show_progress:SetValue(false)
			else
				local proficient = SkillData.Instance:GetSkillProficiency(skill_info.skill_id)
				self.exp_current_num:SetValue(proficient)
				next_desc = string.gsub(self.profession_skill_data[index].skill_desc, "%b()%%" , function(str)
					return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 1000
				end)
				next_desc = string.gsub(next_desc, "%b[]%%" , function(str)
					return tonumber(skill_cfg[effect_level + 1][string.sub(str, 2, -3)]) / 100 .. "%"
				end)
				next_desc = string.gsub(next_desc, "%[.-%]" , function(str)
					return skill_cfg[effect_level + 1][string.sub(str, 2, -2)]
				end)

				if self.is_init_exp_radio or self.is_click_skill then
					self.exp_radio:InitValue(proficient / skill_cfg[effect_level].zhenqi_cost)
				else
					self.exp_radio:SetValue(proficient / skill_cfg[effect_level].zhenqi_cost)
				end
				self.show_progress:SetValue(true)
			end
			self.exp_max_num:SetValue(skill_cfg[effect_level].zhenqi_cost)
		end
		self.is_click_skill = false
	else
		-- 被动技能
		local passive_info = SkillData.Instance:GetSkillInfoById(self.passive_skill_data[index].skill_id)
		local passive_skill = self.passive_skill[index]
		if passive_info then
			local bundle, asset = ResPath.GetRoleSkillIcon(self.passive_skill_data[index].skill_icon)
			passive_skill.icon.image:LoadSprite(bundle, asset)
			passive_skill.icon.grayscale.GrayScale = 0
			if self.passive_level_list[index] then
				if self.passive_level_list[index] < passive_info.level then
					if Status.NowTime - self.effect_cd > EFFECT_CD then
						passive_skill.effect:SetActive(true)
						self.effect_cd = Status.NowTime
						GlobalTimerQuest:AddDelayTimer(function ()
							passive_skill.effect:SetActive(false)
						end, 0.75)
					end
				end
			end
		else
			passive_skill.icon.grayscale.GrayScale = 255
		end

		-- 战斗力
		local attr = CommonStruct.Attribute()
		local attr_n = CommonStruct.Attribute()
		for k, v in pairs(Language.Common.PassvieSkillAttr) do
			if skill_cfg[effect_level].skill_name == v then
				if skill_info then
					attr[k] = skill_cfg[effect_level].param_a
					if effect_level < #skill_cfg then
						attr_n[k] = skill_cfg[effect_level + 1].param_a
					end
				else
					attr_n[k] = skill_cfg[effect_level].param_a
				end
			end
		end
		local capability = CommonDataManager.GetCapability(attr)
		self.current_fightpower:SetValue(capability)
		local capability_n = CommonDataManager.GetCapability(attr_n, true, attr)
		self.next_fightpower:SetValue(capability_n)

		desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
			return skill_cfg[effect_level][string.sub(str, 2, -2)]
		end)

		self.is_show_next_effect:SetValue(true)
		if skill_info then
			if effect_level >= #skill_cfg then
				self.is_show_next_effect:SetValue(false)
			else
				next_desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
					return skill_cfg[effect_level + 1][string.sub(str, 2, -2)]
				end)
			end
		end
		local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg[effect_level].item_cost_id)
		local count = ItemData.Instance:GetItemNumInBagById(skill_cfg[effect_level].item_cost_id)
		if item_cfg then
			self.up_need_material:SetValue(item_cfg.name)
		end
		if effect_level < #skill_cfg then
			if count < skill_cfg[effect_level + 1].item_cost then
				self.up_have_material_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
				self.passive_skill[index].arrow:SetActive(false)
			else
				self.passive_skill[index].arrow:SetActive(true)
				self.up_have_material_num:SetValue(count)
			end
			self.up_need_material_num:SetValue(skill_cfg[effect_level + 1].item_cost)
		else
			self.passive_skill[index].arrow:SetActive(false)
			self.up_need_material_num:SetValue(0)
			self.up_have_material_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		end

		self.upgrade_button.button.interactable = effect_level < #skill_cfg

		self.passive_level_list[index] = passive_info and passive_info.level or 0
	end

	if skill_info == nil then
		self.next_effect:SetValue(desc)
	else
		self.current_effect:SetValue(desc)
		if effect_level < #skill_cfg then
			self.next_effect:SetValue(next_desc)
		end
	end

	self.is_init_exp_radio = false
end

function PlayerSkillView:SetDefultToggle()
	self.pro_skill_btn.toggle.isOn = true
	self.passive_skill_btn.toggle.isOn = false
	self.is_init_exp_radio = true
	self:FlushSkillInfo()
	self.ui_scene = {"scenes/map/jnzs01", "Jnzs01"}
	UIScene:ChangeScene(self.parent_view, self.ui_scene)
	UIScene:SetActionEnable(false)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	UIScene:Rotate(0, -63, 0)
	self:StopLevelUp()
	self.is_set_model = false
	self.cur_toggle_state = 1
end

function PlayerSkillView:OnClickProfessionButton()
	if self.cur_toggle_state == 1 then
		return
	end
	self.parent_view:SetSceneMaskState(true)
	self.ui_scene = {"scenes/map/jnzs01", "Jnzs01"}
	local call_back = function()
		if self.parent_view then
			self.parent_view:SetSceneMaskState(false)
		end
	end
	UIScene:SetUISceneLoadCallBack(call_back)
	UIScene:ChangeScene(self.parent_view, self.ui_scene)
	self.is_init_exp_radio = true
	self.pro_skill_btn.toggle.isOn = true
	self.passive_skill_btn.toggle.isOn = false
	self.index = 1
	self:FlushSkillInfo()
	-- 显示角色切换到非战斗状态
	-- self.parent_view:SetRoleFight(true)
	UIScene:SetActionEnable(false)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	UIScene:Rotate(0, -63, 0)
	self:StopLevelUp()
	self.is_set_model = false
	self.cur_toggle_state = 1
end

function PlayerSkillView:SetDefaultState()
	self.ui_scene = {"scenes/map/jnzs01", "Jnzs01"}
	UIScene:ChangeScene(self.parent_view, self.ui_scene)
	UIScene:SetActionEnable(false)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	UIScene:Rotate(0, -63, 0)
	self.is_set_model = false
end

function PlayerSkillView:OnClickPassiveButton(v)
	if self.cur_toggle_state == 2 then
		return
	end
	if not self.passive_skill_btn.toggle.isOn then
		return
	end
	self.parent_view:SetSceneMaskState(true)
	if not self.is_set_model then
		self.ui_scene = {"scenes/map/uijsdt01", "UIjsdt01"}
		local call_back = function()
			if self.parent_view then
				self.parent_view:SetSceneMaskState(false)
			end
		end
		UIScene:SetUISceneLoadCallBack(call_back)
		UIScene:ChangeScene(self.parent_view, self.ui_scene, {[1] = {"Pingtai01"}})
		self:SetRoleFight(false)
		UIScene:SetActionEnable(true)
		self.is_set_model = true
	end
	self.passive_skill_btn.toggle.isOn = true
	self.pro_skill_btn.toggle.isOn = false
	self:FlushSkillInfo()
	self.cur_toggle_state = 2
end

function PlayerSkillView:SetRoleFight(enable)
	-- local draw_obj = self.role_model.draw_obj
	-- local part = draw_obj:GetPart(SceneObjPart.Main)
	-- part:SetBool("fight", enable)
	UIScene:SetFightBool(enable)
end

function PlayerSkillView:FlushSkillExpInfo()
	self.is_click_skill = true
	if not self.passive_skill_btn.toggle.isOn and self.profession_skill_data[self.index] then
		self:GetSkillInfo(self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index)
	end
end

function PlayerSkillView:FlushSkillInfo()
	if self.passive_skill_btn.toggle.isOn then
		self.last_passive_index = self.passive_index
		local temp_skill_id = self.passive_skill_data[self.passive_index].skill_id
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..temp_skill_id]
		local skill_info = SkillData.Instance:GetSkillInfoById(temp_skill_id)
		local level = skill_info and skill_info.level or 1

		for k = 7, 1, -1 do
			local v = self.passive_skill_data[k]
			if v == nil then return end
			skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..v.skill_id]
			skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)

			level = 1
			if skill_info then
				level = skill_info.level
			end
			self:SetSkillInfo(skill_cfg, k, level, skill_info, true)
		end
		local index_list = SkillData.Instance:GetPassvieSkillCanUpLevelIndexList(self.passive_skill_data)
		local index = -1
		local select_index_can_up = false
		for k, v in pairs(index_list) do
			if v == self.passive_index then
				select_index_can_up = true
				index = self.passive_index
			end
		end
		if not select_index_can_up then
			index = index_list[#index_list] or self.passive_index
		end

		if index ~= self.passive_index or not next(index_list) or (index == self.passive_index and select_index_can_up) then
			self.passive_skill[index].skill.toggle.isOn = true
		end
		self.passive_index = index > 0 and index or self.passive_index
		self:GetSkillInfo(self.passive_skill_data[self.passive_index].skill_id, self.passive_skill_data[self.passive_index].skill_name, self.passive_index)
		self.temp_skill_id = self.passive_skill_data[self.passive_index].skill_id

		if self.auto_level_up then
			self:RemoveCountDown()
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
				 if self.auto_level_up then
				 	self:OnClickUpgradeButton()
				 end
			end, 0.3)
		end

		for i = 8, 10 do
			self:FlushMieShiSkillIcon(i)
		end
	else
		self.index = self.index or 1
		if self.profession_skill[self.index] then
			self.profession_skill[self.index].skill.toggle.isOn = true
			self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
					self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 2)
		end
		-- self:OnClickPlayButton(self.index)
	end
end

function PlayerSkillView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end

	if self.skill_delay_timer then
		GlobalTimerQuest:CancelQuest(self.skill_delay_timer)
		self.skill_delay_timer = nil
	end
end

function PlayerSkillView:RemindChangeCallBack(remind_name, num)
	self.show_red_point:SetValue(num > 0)
end
