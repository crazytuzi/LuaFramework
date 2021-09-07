MainUIViewSkill = MainUIViewSkill or BaseClass(BaseRender)
local GeneralType = {
	Btn = 1,
	Layer = 2,
}
local prof_skill = {
	{111, 141, 121, 131, 0, 0, 5},
	{211, 221, 231, 241, 0, 0, 6},
	{311, 341, 331, 321, 0, 0, 7},
	{411, 441, 431, 421, 0, 0, 8},
}

local function SkillInfo()
	return {
		icon = nil,
		skill_id = 0,
		is_exist = false,
	}
end

function MainUIViewSkill:__init(instance, parent)
	-- 初始化
	self.parent = parent

	self.skill_infos = {}
	for i = 1, 7 do
		table.insert(self.skill_infos, SkillInfo())
	end

	-- 找到要控制的变量
	self.skill_icons = {
		self:FindVariable("AttackIcon"),
		self:FindVariable("SkillIcon1"),
		self:FindVariable("SkillIcon2"),
		self:FindVariable("SkillIcon3"),
		self:FindVariable("SkillIcon4"),
		self:FindVariable("SkillIcon5"),
		self:FindVariable("SkillIcon6"),
		self:FindVariable("KillIcon"),
	}

	self.skill_locked = {
		self:FindVariable("AttackLocked"),
		self:FindVariable("SkillLocked1"),
		self:FindVariable("SkillLocked2"),
		self:FindVariable("SkillLocked3"),
		self:FindVariable("SkillLocked4"),
		nil,
		self:FindVariable("KillLocked"),
	}
	self.show_mojie = self:FindVariable("ShowSkill5")
	self.show_goddess = self:FindVariable("ShowSkill6")
	self.show_mojie_gray_1 = self:FindVariable("Skill5_1Gray")
	self.show_mojie_gray_2 = self:FindVariable("Skill5_2Gray")
	self.show_mojie_panel = self:FindObj("Skill5ChangePanel").animator
	self.mojie_icon_1 = self:FindVariable("Skill5_1")
	self.mojie_icon_2 = self:FindVariable("Skill5_2")
	self.goddess_is_lock = nil
	self.other_mojie_info = {
		SkillInfo(),
		SkillInfo(),
	}
	self.other_mojie_icon = {
		self:FindVariable("Skill5_1"),
		self:FindVariable("Skill5_2")
	}

	self.other_mojie_name = {
		self:FindVariable("Skill5_1_Name"),
		self:FindVariable("Skill5_2_Name")
	}

	self.jump_locked = self:FindVariable("JumpLocked")
	self.jump_count = self:FindVariable("JumpCount")

	self.skill_cd_progress = {
		self:FindVariable("SkillCDProgress1"),
		self:FindVariable("SkillCDProgress2"),
		self:FindVariable("SkillCDProgress3"),
		self:FindVariable("SkillCDProgress4"),
		self:FindVariable("SkillCDProgress5"),
		self:FindVariable("SkillCDProgress6"),
		self:FindVariable("KillCDProgress"),
	}

	self.skill_cd_time = {
		self:FindVariable("SkillCDTime1"),
		self:FindVariable("SkillCDTime2"),
		self:FindVariable("SkillCDTime3"),
		self:FindVariable("SkillCDTime4"),
		self:FindVariable("SkillCDTime5"),
		self:FindVariable("SkillCDTime6"),
	}

	self.general_skill = {}
	self.general_skill.cd_time = self:FindVariable("GeneralSkillCD")
	self.general_skill.progress = self:FindVariable("GeneralCDProgress")
	self.general_skill.icon = self:FindVariable("GeneralIcon")
	self.general_skill.name = self:FindVariable("GeneralName")
	self.general_skill.is_bianshen = false
	self.general_skill.show_effect = self:FindVariable("ShowGeneralEffecf")

	self.team_skill = {}
	self.team_skill.cd_time = self:FindVariable("TeamSkillCD")
	self.team_skill.progress = self:FindVariable("TeamSkillCDProgress")
	self.team_skill.icon = self:FindVariable("TeamSkillIcon")
	self.team_skill.name = self:FindVariable("TeamSkillName")
	self.team_skill.show_btn = self:FindVariable("ShowTeamSkill")

	self.dot = self:FindVariable("Dot")
	self.skill6_name = self:FindVariable("Skill6Name")
	self.skill5_name = self:FindVariable("Skill5Name")
	self.show_kill_effect = self:FindVariable("ShowKillEffect")
	self.show_kill6_effect = self:FindVariable("ShowKill6Effect")
	self.show_kill6_effect2 = self:FindVariable("ShowKill6Effect2")
	self.is_show_kill6_effect = false
	self.show_general = self:FindVariable("ShowGeneral")
	self.show_war_scene = self:FindVariable("ShowWarSceneSkill")
	
	for i=1,4 do
		self.skill_cd_progress[i]:SetValue(0)
		self.skill_cd_time[i]:SetValue(0)
	end

	self.skill_count_down = {}
	self.speci_skill_count_down = {}
	self.is_lock_skill = false

	-- 获取技能
	self.attack_button = self:FindObj("AttackButton")
	self.ani_attack_button = self.attack_button.animator

	-- 监听UI事件
	self:ListenEvent("AttackDown", BindTool.Bind(self.OnClickAttackDown, self, self.skill_infos[1]))
	self:ListenEvent("AttackUp", BindTool.Bind(self.OnClickAttackUp, self, self.skill_infos[1]))
	self:ListenEvent("Skill1", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[2]))
	self:ListenEvent("Skill2", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[3]))
	self:ListenEvent("Skill3", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[4]))
	self:ListenEvent("Skill4", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[5]))
	self:ListenEvent("Skill5", BindTool.Bind(self.OnClickSkill5Up, self, self.skill_infos[6]))
	self:ListenEvent("Skill5Down", BindTool.Bind(self.OnClickSkill5Down, self, self.skill_infos[6]))
	self:ListenEvent("Skill6", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[7]))
	-- self:ListenEvent("SkillNuqi", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[7]))
	self:ListenEvent("Jump", BindTool.Bind(self.OnClickJump, self))
	self:ListenEvent("ClickSkill5_1", BindTool.Bind(self.ClickSkill5Change, self, 1))
	self:ListenEvent("ClickSkill5_2", BindTool.Bind(self.ClickSkill5Change, self, 2))
	self:ListenEvent("OnClickJinjieEquipSkill", BindTool.Bind(self.OnClickJinjieEquipSkill, self))
	self:ListenEvent("GeneralSkill", BindTool.Bind(self.ClickGeneralSkill, self))
	self:ListenEvent("ClickTeamSkill", BindTool.Bind(self.ClickTeamSkill, self))
	self:ListenEvent("ClickWarSceneSkill", BindTool.Bind(self.ClickWarSceneSkill, self))

	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)
	
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self:BindGlobalEvent(MainUIEventType.ROLE_SKILL_CHANGE, BindTool.Bind(self.OnSkillChange, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))
	self:BindGlobalEvent(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE, BindTool.Bind(self.SetJinjieSkillInfo, self))

	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_CHANGE_AREA_TYPE, BindTool.Bind(self.OnMainRoleSwitchScene, self))
	self:BindGlobalEvent(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self:BindGlobalEvent(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
	self.mojie_info_event = BindTool.Bind(self.OnSkillChange, self, "mojie")
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	-- 首次刷新数据
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self:PlayerDataChangeCallback("nuqi", vo.nuqi, 0)
	self:PlayerDataChangeCallback("level", vo.level, vo.level)
	self:OnRecvMainRoleInfo()
	self:OnSkillChange()
	self:FlushGeneralSkill()
	self:FlushTeamSkillState()

	-- 定位技能按钮位置
	-- self.skill_icon_pos_list = {
	-- 	[1] = self:FindObj("Skill1"),
	-- 	[2] = self:FindObj("Skill2"),
	-- 	[3] = self:FindObj("Skill3"),
	-- 	[4] = self:FindObj("Skill4"),
	-- 	[5] = self:FindObj("Skill5"),
	-- 	[6] = self:FindObj("Skill6"),
	-- }
	self.skill_icon_pos_list = {}
	for i = 1, 6 do
		self.skill_icon_pos_list[i] = self:FindObj("Skill" .. i)
	end
	self.team_skill_pos = self:FindObj("TeamSkill")

	Runner.Instance:AddRunObj(self, 6)

	self.enter_safe_area_animator = self:FindObj("EnterSafeArea"):GetComponent(typeof(UnityEngine.Animator))
	self.leave_safe_area_animator = self:FindObj("LeaveSafeArea"):GetComponent(typeof(UnityEngine.Animator))

	self.jinjie_skill_total_count = self:FindVariable("JinjieSkillTotalCount")
	self.jinjie_skill_cur_count = self:FindVariable("JinjieSkillCurCount")
	self.jinjie_skill_icon= self:FindVariable("JinjieSkillIcon")

	self.show_mojie_skill = false

	self.select_obj_group_list = {}

	-- self:SetJinjieSkillInfo()
	self.bianshen_effect = nil
	self.general_btn_effect = nil

	self.enter_fight = GlobalEventSystem:Bind(ObjectEventType.ENTER_FIGHT, BindTool.Bind(self.ChangeBianShenEffect, self))
	self.exit_fight = GlobalEventSystem:Bind(ObjectEventType.EXIT_FIGHT, BindTool.Bind(self.ChangeBianShenEffect, self))
end

function MainUIViewSkill:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)

	Runner.Instance:RemoveRunObj(self)

	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer)
	GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
	self.skill5_time_quest = nil
	MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	
	for i, v in ipairs(self.skill_infos) do
		CountDown.Instance:RemoveCountDown(v.countdonw1)
		CountDown.Instance:RemoveCountDown(v.countdonw2)
	end
	GlobalEventSystem:UnBind(self.enter_fight)
	GlobalEventSystem:UnBind(self.exit_fight)
end

function MainUIViewSkill:SetJinjieSkillInfo()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	if game_vo.upgrade_next_skill < 0 then
		return
	end

	local gauge_count = AdvanceData.Instance:GetJinjieGaugeCount()
	if nil == gauge_count then
		return
	end

	self.jinjie_skill_total_count:SetValue(AdvanceData.Instance:GetJinjieGaugeCount())
	self.jinjie_skill_cur_count:SetValue(game_vo.upgrade_cur_calc_num)

	self.jinjie_skill_icon:SetAsset(AdvanceData.Instance:GetEquipSkillResPath(game_vo.upgrade_next_skill))
end

function MainUIViewSkill:OnClickJinjieEquipSkill()
	ViewManager.Instance:Open(ViewName.AdvanceEquipSkillView)
end

function MainUIViewSkill:SetMojiePanelAnimation(value)
	if self.show_mojie_skill and self.show_mojie_panel.isActiveAndEnabled then
		self.show_mojie_panel:SetBool("fold", value)
	end
end


function MainUIViewSkill:OnMainUIModeListChange(is_show)
	self:SetMojiePanelAnimation(false)
end

function MainUIViewSkill:PortraitToggleChange(state, from_joystick)
	self:SetMojiePanelAnimation(false)
end

function MainUIViewSkill:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "nuqi" then
		-- self.skill_cd_progress[7]:SetValue(value / COMMON_CONSTS.NUQI_FULL)
		-- if (value >= COMMON_CONSTS.NUQI_FULL and old_value < COMMON_CONSTS.NUQI_FULL) or
		--  (value < COMMON_CONSTS.NUQI_FULL and old_value >= COMMON_CONSTS.NUQI_FULL) then
		-- 	self:CheckNuqiEff()
		-- end
	elseif attr_name == "level" then
		self.jump_locked:SetValue(value < GameEnum.JUMP_ROLE_LEVEL)
		self.dot:SetValue(value >= GameEnum.JUMP_ROLE_LEVEL)
	end
end

function MainUIViewSkill:OnRecvMainRoleInfo()
	local prof = PlayerData.Instance:GetAttr("prof")
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo
	local skill_list = {}
	local kill_skill_id = prof + 4

	for skill_id, v in pairs(skillinfo) do
		if prof == math.modf(skill_id / 100) then
			skill_list[v.skill_index] = v
		elseif skill_id == kill_skill_id then
			skill_list[7] = v
		end
	end

	if Scene and Scene.Instance then
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			local war_scene_cfg = SkillData.Instance:GetWarSceneCfg()
			for k,v in pairs(war_scene_cfg) do
				if v and SkillData.Instance:GetSkillInfoById(v.skill_id) ~= nil then
					local data = {}
					data.skill_id = v.skill_id
					skill_list[v.seq] = data
				end
			end
		end
	end

	for i, v in ipairs(self.skill_infos) do
		v.skill_id = skill_list[i] and skill_list[i].skill_id or 0
	end
end

function MainUIViewSkill:CheckNuqiEff()
	local skill_info = SkillData.Instance:GetSkillInfoById(SkillData.GetAngerSkillID())
	local cd = 1
	if skill_info and PlayerData.Instance.role_vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		cd = skill_info.cd_end_time - Status.NowTime
	end
	self.show_kill_effect:SetValue(cd <= 0)
	if cd <= 0 and self.skill_cd_progress[7] then
		self.skill_cd_progress[7]:SetValue(1)
	end
end

function MainUIViewSkill:OnSkillChange(change_type, skill_id, need_flush)
	local mojie_index = 0
	local skill_info = nil
	local skill_cfg = nil
	for i, v in ipairs(self.skill_infos) do
		if i == 6 then
			v.is_exist = false
			v.skill_id = 0
			for k1,v1 in pairs(MojieData.SKILL_T) do
				skill_info = SkillData.Instance:GetSkillInfoById(v1)
				if skill_info then
					self.show_mojie_skill = true
					v.is_exist = nil ~= skill_info
					v.skill_id = v1
					skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
					if nil ~= skill_cfg then
						v.skill_icon = skill_cfg.skill_icon
					end
				else
					mojie_index = mojie_index + 1
					local vo = self.other_mojie_info[mojie_index]
					if vo then
						vo.skill_id = v1
						skill_cfg = SkillData.GetSkillinfoConfig(vo.skill_id)
						if nil ~= skill_cfg then
							vo.skill_icon = skill_cfg.skill_icon
						end
					end
				end
			end
		elseif i == 7 then
			v.is_exist = false
			v.skill_id = 0
			skill_info = SkillData.Instance:GetCurGoddessSkill()
			if skill_info then
				v.is_exist = nil ~= skill_info
				v.skill_id = skill_info.skill_id
				skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
				if nil ~= skill_cfg then
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		else
			skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
			v.is_exist = nil ~= skill_info

			skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
			if nil ~= skill_cfg then
				-- local prof = PlayerData.Instance:GetAttr("prof")
				-- if v.skill_id == prof + 4 then
				-- 	v.skill_icon = skill_cfg.skill_icon + prof
				-- else
					v.skill_icon = skill_cfg.skill_icon
				-- end
			end
		end
		if skill_info and ("list" == change_type or nil == change_type) then
			if v.skill_id ~= SkillData.GetAngerSkillID() or not self.has_cheak_nuqi then
				self:OnMainRoleUseSkill(v.skill_id)
				if v.skill_id == SkillData.GetAngerSkillID() then
					self:CheckNuqiEff()
				end
			end
		end
	end

	if not need_flush then
		if self.skill_infos[1] and SkillData.Instance:GetSkillInfoById(self.skill_infos[1].skill_id or 0) then
			self.has_cheak_nuqi = true
		end

		self.parent:Flush("skill")
		self:FlushTeamSkillState()
	end
end

function MainUIViewSkill:OnMainRoleUseSkill(skill_id)
	local is_war_skill = SkillData.Instance:CheckIsWarSceneSkill(skill_id)
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		for i, v in ipairs(self.skill_infos) do
			if i == 4 then
				if self.speci_skill_count_down[skill_id] then
					return
				end
				self.speci_skill_count_down[skill_id] = true
				local skill_info = ClashTerritoryData.Instance:GetSkillInfoById(skill_id)
				if skill_info and skill_info.index ~= 1 then
					local cd = skill_info.cd_end_time - Status.NowTime
					if cd < 1 then
						self.speci_skill_count_down[skill_id] = false
						return
					end
					self.has_Flush_appearance = true
					self.skill_cd_progress[i - 1]:SetValue(1.0)
					CountDown.Instance:RemoveCountDown(v.countdonw1)
					CountDown.Instance:RemoveCountDown(v.countdonw2)
					v.countdonw1 = CountDown.Instance:AddCountDown(
						cd, 0.05, function(elapse_time, total_time)
							local progress = (total_time - elapse_time) / total_time
							self.skill_cd_progress[i - 1]:SetValue(progress)
						end)

					self.skill_cd_time[i - 1]:SetValue(math.ceil(cd))
					v.countdonw2 = CountDown.Instance:AddCountDown(
						cd, 1.0, function(elapse_time, total_time)
							self.skill_cd_time[i - 1]:SetValue(math.ceil(total_time - elapse_time))
							if total_time - elapse_time <= 0 then
								self.speci_skill_count_down[skill_id] = false
							end
						end)
				end
				break
			end
		end
	elseif skill_id == 7 then
		print_log("Use Kill Skill.")
	elseif (not is_war_skill and math.floor(skill_id / 10) == math.floor(self.skill_infos[1].skill_id / 10)) or (is_war_skill and self.skill_infos[1].skill_id == skill_id) then
		-- 如果是主动技能, 更新主动技能图标
		local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
		if nil ~= skill_cfg then
			local bundle, asset = ResPath.GetRoleSkillIcon(skill_cfg.skill_icon)
			self.skill_icons[1]:SetAsset(bundle, asset)
		end

		if nil ~= self.common_skill_timer then
			GlobalTimerQuest:CancelQuest(self.common_skill_timer)
			self.common_skill_timer = nil
		end

		self.common_skill_timer = GlobalTimerQuest:AddDelayTimer(function()
			local res_id = self.skill_infos[1].skill_icon
			if SkillData.Instance:CheckIsWarSceneSkill(self.skill_infos[1].skill_id) then
				res_id = self.skill_infos[1].skill_id
			end
			
			local bundle, asset = ResPath.GetRoleSkillIcon(res_id)
			self.skill_icons[1]:SetAsset(bundle, asset)
			self.common_skill_timer = nil
		end, 1.0)
	elseif skill_id % 10 == 1 or MojieData.IsMojieSkill(skill_id) or GoddessData.Instance:IsGoddessSkill(skill_id) or skill_id == SkillData.ANGER_SKILL_ID or is_war_skill then
		-- 触发技能的CD倒计时
		for i, v in ipairs(self.skill_infos) do
			if v.skill_id == skill_id then
				if self.skill_count_down[skill_id] then
					return
				end
				self.skill_count_down[skill_id] = true
				local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
				local cd = skill_info.cd_end_time - Status.NowTime

				if skill_id == SkillData.GetAngerSkillID() then
					self.skill_cd_progress[i - 1]:SetValue(0.0)
					self:CheckNuqiEff()
				else
					self.skill_cd_progress[i - 1]:SetValue(1.0)
				end
				CountDown.Instance:RemoveCountDown(v.countdonw1)
				CountDown.Instance:RemoveCountDown(v.countdonw2)
				v.countdonw1 = CountDown.Instance:AddCountDown(
					cd, 0.05, function(elapse_time, total_time)
						local progress = (total_time - elapse_time) / total_time
						if skill_id == SkillData.GetAngerSkillID() then
							self.skill_cd_progress[i - 1]:SetValue(1 - progress)
							if progress <= 0 then
								self:CheckNuqiEff()
								self.skill_count_down[skill_id] = false
							end
						else
							self.skill_cd_progress[i - 1]:SetValue(progress)
						end
					end)
				if self.skill_cd_time[i - 1] then
					self.skill_cd_time[i - 1]:SetValue(math.ceil(cd))
					v.countdonw2 = CountDown.Instance:AddCountDown(
						cd, 1.0, function(elapse_time, total_time)
							self.skill_cd_time[i - 1]:SetValue(math.ceil(total_time - elapse_time))
							if total_time - elapse_time <= 0 then
								self.skill_count_down[skill_id] = false
								if total_time > 0 then
									EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_cdman_prefab", "UI_jineng_CDman", self.skill_icon_pos_list[i - 1].transform)
								end
							end
						end)
				end
				break
			end
		end
	end
	self:FlushTeamSkillCd(skill_id)
end

function MainUIViewSkill:CheckIsShowWarScene()
	if self.show_war_scene ~= nil then
		local scene_type = Scene.Instance:GetSceneType()
		local show_list = SkillData.Instance:GetShowWarSceneList()
		local is_show = false
		if show_list ~= nil and show_list[scene_type] ~= nil then
			is_show = true
		end

		if self.show_war_scene ~= nil then
			self.show_war_scene:SetValue(is_show)
		end
	end
end

function MainUIViewSkill:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_bianshen_cd" then
			self:GeneralBianShenCd()
		elseif k == "check_skill" then
			local is_spec = false
			local role = Scene.Instance:GetMainRole()
			local war_state = false
			if role ~= nil then
				war_state = role:IsWarSceneState()
			end

			if self.skill_infos then
				for k,v in pairs(self.skill_infos) do
					if v ~= nil and v.skill_id ~= nil and SkillData.Instance:CheckIsWarSceneSkill(v.skill_id) ~= nil and not war_state then
						is_spec = true
						break
					end 
				end
			end
			if v.is_change or is_spec then
				self:OnRecvMainRoleInfo()
				self:OnSkillChange(nil, nil, true)
			end
			self:FlushGeneralSkill()
		elseif k == "check_team_skill" then
			self:FlushTeamSkillState()
		elseif k == "check_war_scene" then
			self:CheckIsShowWarScene()
		elseif k == "all" then
			self:CheckIsShowWarScene()		
		end
	end
	
	if param_t.goddess_skill_tips then
		self.show_kill6_effect:SetValue(false)
		self.show_kill6_effect2:SetValue(true)
		self.is_show_kill6_effect= false
		GlobalTimerQuest:AddDelayTimer(function()
			self.show_kill6_effect2:SetValue(false)
		end, 0.5)
		return
	end
	if nil == param_t.skill then
		return
	end

	for i, v in ipairs(self.skill_infos) do
		if i == 6 then
			self.show_mojie:SetValue(v.is_exist)
			if v.skill_id ~= 0 then
				local skill_name = SkillData.GetSkillinfoConfig(v.skill_id).skill_name
				if skill_name then
					self.skill5_name:SetValue(skill_name)
				end
			end
		elseif i == 7 then
			self.show_goddess:SetValue(v.is_exist)
			if v.skill_id ~= 0 then
				local skill_name = SkillData.GetSkillinfoConfig(v.skill_id).skill_name
				if skill_name then
					self.skill6_name:SetValue(skill_name)
				end
			end
			if self.goddess_is_lock and v.is_exist then
				self.show_kill6_effect:SetValue(true)
				self.is_show_kill6_effect= true
			end
			if SkillData.SKILL_INFO_GET then
				self.goddess_is_lock = not v.is_exist
			end
		else
			self.skill_locked[i]:SetValue(not v.is_exist)
		end

		if v.is_exist then
			if nil ~= v.skill_icon then
				local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
				self.skill_icons[i]:SetAsset(bundle, asset)
			end

			if SkillData.Instance:CheckIsWarSceneSkill(v.skill_id) then
				local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_id)
				self.skill_icons[i]:SetAsset(bundle, asset)
			end
		end
		v.territory_lock = false
		if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
			if i == 6 then
				self.show_mojie:SetValue(false)
			elseif i == 7 then
				self.show_goddess:SetValue(false)
			else
				v.territory_lock = i ~= 1 and i ~= 4
				self.skill_locked[i]:SetValue(v.territory_lock)
			end
			if i == 1 or i == 4 then
				local skill_icon = ClashTerritoryData.Instance:GetTerritorySkillIcon(SkillData.Instance:GetRealSkillIndex(v.skill_id))
				if skill_icon then
					local bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
					self.skill_icons[i]:SetAsset(bundle, asset)
				end
			end
			if not self.has_Flush_appearance and i ~= 1 then
				self:OnMainRoleUseSkill(v.skill_id)
			end
		else
			self.has_Flush_appearance = false
		end
		if param_t.special_appearance and i == 4 and v.is_exist then
			self.speci_skill_count_down = {}
			self:OnMainRoleUseSkill(v.skill_id)
			self:CheckNuqiEff()
		end
	end
	for i,v in ipairs(self.other_mojie_info) do
		if v.skill_icon then
			local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
			self.other_mojie_icon[i]:SetAsset(bundle, asset)
			self.other_mojie_name[i]:SetValue(SkillData.GetSkillinfoConfig(v.skill_id).skill_name)
			if self["show_mojie_gray_" .. i] then
				self["show_mojie_gray_" .. i]:SetValue(MojieData.Instance:GetMojieInfoBySkillId(v.skill_id) ~= nil)
			end
		end
	end
end

function MainUIViewSkill:ClickSkill5Change(index)
	local skill_id = self.other_mojie_info[index].skill_id
	if skill_id > 0 then
		local mojie_info = MojieData.Instance:GetMojieInfoBySkillId(skill_id)
		if nil == mojie_info then
			SysMsgCtrl.Instance:ErrorRemind(Language.Role.NotActive)
		else
			FashionCtrl.SendMojieChangeSkillReq(mojie_info.mojie_skill_id, mojie_info.mojie_skill_type, mojie_info.mojie_skill_level)
		end
	end
	self:SetMojiePanelAnimation(false)
end

local click_attack_down = nil
function MainUIViewSkill:OnClickAttackDown(skill_info)
	click_attack_down = UnityEngine.Input.mousePosition
end

function MainUIViewSkill:OnClickAttackUp(skill_info)
	if nil == click_attack_down then return end
	local off_y = click_attack_down.y - UnityEngine.Input.mousePosition.y
	if off_y > 1000 or off_y < -1000 then
		return
	elseif math.abs(off_y) < 20 then
		self:OnClickSkill(skill_info)
		EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_dianjida_prefab", "UI_jineng_dianjida", self.ani_attack_button.transform)
	else
		if off_y < 0 then				-- 向上
			self:SelectObj(SceneObjType.Role, SelectType.Alive, "dis")
			self.ani_attack_button:SetTrigger("SkillTouchUp")
		else 							-- 向下
			self:SelectObj(SceneObjType.Role, SelectType.Alive, "hp")
			self.ani_attack_button:SetTrigger("SkillTouchDown")
		end
	end
	click_attack_down = nil
end

function MainUIViewSkill:SelectObj(obj_type, select_type, sort_type)
	-- 获取所有可选对象
	local obj_list = Scene.Instance:GetObjListByType(obj_type)
	if not next(obj_list) then
		return
	end

	local temp_obj_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	local can_select = true
	for k, v in pairs(obj_list) do
		can_select = true
		if SelectType.Friend == select_type then
			can_select = Scene.Instance:IsFriend(v, self.main_role)
		elseif SelectType.Enemy == select_type then
			can_select = Scene.Instance:IsEnemy(v, self.main_role)
		elseif SelectType.Alive == select_type then
			can_select = not v:IsRealDead() and Scene.Instance:IsEnemy(v, self.main_role)
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, hp = (v.vo.hp / v.vo.max_hp), dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	-- table.sort(temp_obj_list, function(a, b) return a.dis < b.dis end)
	SortTools.SortAsc(temp_obj_list, sort_type)

	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[obj_type]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end

	-- local select_obj = nil
	-- for i, v in ipairs(temp_obj_list) do
	-- 	if nil == select_obj_list[v.obj:GetObjId()] then
	-- 		select_obj = v.obj
	-- 		break
	-- 	end
	-- end

	-- 策划需求  只在血量最少的两个人里面来回选择
	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		local last_select_obj = select_obj_list[v.obj:GetType()]
		if nil == last_select_obj or last_select_obj:GetObjId() ~= v.obj:GetObjId() then
			select_obj = v.obj
			break
		end
	end

	-- 如果没有选中，选第一个，并清空已选列表
	if nil == select_obj then
		select_obj = temp_obj_list[1].obj
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end
	if nil == select_obj then
		return
	end
	select_obj_list[select_obj:GetObjId()] = select_obj

	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, select_obj, "select")

	return select_obj
end

function MainUIViewSkill:OnClickSkill5Up(skill_info)
	if self.skill5_time_quest then
		if self.show_mojie_skill and self.show_mojie_panel:GetBool("fold") then
			self:SetMojiePanelAnimation(false)
		else
			self:OnClickSkill(skill_info)
		end
	end
	GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
	self.skill5_time_quest = nil
end

function MainUIViewSkill:OnClickSkill5Down(skill_info)
	local function open_change()
		GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
		self.skill5_time_quest = nil
		self:SetMojiePanelAnimation(true)
	end
	self.skill5_time_quest = GlobalTimerQuest:AddDelayTimer(open_change, 0.5)
end

function MainUIViewSkill:OnClickSkill(skill_info)
	self:SetMojiePanelAnimation(false)
	if not skill_info.is_exist then
		return
	end

	if SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) >= 1 and SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) <= 4 then
		self:OnClickSkillEffect(skill_info.skill_id)
	end

	if skill_info.territory_lock then
		return
	end

	if not Scene.Instance:GetMainRole():CanAttack() then
		return
	end
	if GoddessData.Instance:IsGoddessSkill(skill_info.skill_id) and self.is_show_kill6_effect then
		ViewManager.Instance:Open(ViewName.MainUIGoddessSkillTip)
		return
	end

	if SkillData.Instance:IsSkillCD(skill_info.skill_id) and SkillData.IsNotNormalSkill(skill_info.skill_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
	end

	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(true, {
			[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] = true,
		}, skill_info.skill_id == 70 or skill_info.skill_id == 71)
	if SkillData.IsBuffSkill(skill_info.skill_id) or
		(PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		and SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) == 5) then
		target_obj = Scene.Instance:GetMainRole()
	end
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		and SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) == 6 then
		GuajiCtrl.Instance:StopGuaji()
		target_obj = GuajiCtrl.Instance:SelectFriend()
	end

	if nil == target_obj then
		return
	end

	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	GlobalEventSystem:Fire(MainUIEventType.CLICK_SKILL_BUTTON, skill_info.skill_id, target_obj)
	GuajiCtrl.Instance:DoFightByClick(skill_info.skill_id, target_obj)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function MainUIViewSkill:OnClickJump()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- 护送中不能跳跃
	if vo.husong_taskid ~= 0 and vo.husong_color ~= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.CanNotJump)
		return
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.LingyuFb then
			if vo.special_param ~= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.CanNotJump)
				return
			end
		end
	end
	local main_role = Scene.Instance:GetMainRole()
	if not main_role:IsJump() and not main_role:IsAtk() then
		if vo.jump_remain_times > 0 then
			if vo.jump_remain_times >= GameEnum.JUMP_MAX_COUNT then
				vo.jump_last_recover_time = TimeCtrl.Instance:GetServerTime()
			end

			vo.jump_remain_times = vo.jump_remain_times - 1
			self.jump_count:SetValue(vo.jump_remain_times)
			FightCtrl.Instance:DoJump()
		end
	end
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
end

function MainUIViewSkill:Update()
	-- Refresh jump time
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local srv_time = TimeCtrl.Instance:GetServerTime()
	local pass_time = srv_time - vo.jump_last_recover_time
	local recover_times = math.floor(pass_time / GameEnum.JUMP_RECOVER_TIME)
	if recover_times > 0 then
		local new_times = vo.jump_remain_times + recover_times
		if new_times > GameEnum.JUMP_MAX_COUNT then
			new_times = GameEnum.JUMP_MAX_COUNT
		end

		vo.jump_last_recover_time = vo.jump_last_recover_time + recover_times * GameEnum.JUMP_RECOVER_TIME
		if vo.jump_remain_times ~= new_times then
			vo.jump_remain_times = new_times
			self.jump_count:SetValue(vo.jump_remain_times)
		end
	end
end

function MainUIViewSkill:GetSkillButtonPosition()
	return self.skill_icon_pos_list
end

local old_type = nil
function MainUIViewSkill:OnMainRoleSwitchScene(area_type)
	if self.enter_safe_area_animator == nil  then return end
	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer)
	if old_type then
		self:DeleteAreaTip(old_type)
	end
	old_type = area_type
	self.delete_area_tips_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DeleteAreaTip,self, area_type), 3)
	if area_type == SceneConvertionArea.WAY_TO_SAFE then
		if self.enter_safe_area_animator.isActiveAndEnabled then
			self.enter_safe_area_animator:SetBool("enter", true)
		end
	elseif area_type == SceneConvertionArea.SAFE_TO_WAY then
		if self.leave_safe_area_animator.isActiveAndEnabled then
			self.leave_safe_area_animator:SetBool("enter", true)
		end
	end
end

function MainUIViewSkill:DeleteAreaTip(area_type)
	if area_type == SceneConvertionArea.WAY_TO_SAFE then
		if self.enter_safe_area_animator.isActiveAndEnabled then
			self.enter_safe_area_animator:SetBool("enter", false)
		end
	elseif area_type == SceneConvertionArea.SAFE_TO_WAY then
		if self.leave_safe_area_animator.isActiveAndEnabled then
			self.leave_safe_area_animator:SetBool("enter", false)
		end
	end
end

function MainUIViewSkill:FlushSkillName()
	
end

function MainUIViewSkill:ClickGeneralSkill()
	if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[1])
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsJump() then
		return
	end

	if main_role and main_role:IsWarSceneState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsNoUseBianShen)
		return			
	end
	
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_BIANSHEN)
end

function MainUIViewSkill:FlushGeneralSkill()
	if self.show_general then
		if FamousGeneralData.Instance:CheckShowSkill() then
			local value = FamousGeneralData.Instance:GetCurUseSeq()
			local has_general_skill = FamousGeneralData.Instance:GetHasGeneralSkill()
			if value == -1 and has_general_skill then
				self.show_general:SetValue(false)
			else
				self.show_general:SetValue(true)
			end
		else
			self.show_general:SetValue(false)
		end
	end
end

function MainUIViewSkill:GeneralBianShenCd()
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	if not other_cfg then return end
	local is_general = FamousGeneralData.Instance:GetCurUseSeq()
	local cd_s = 0
	local func = nil
	self:ChangeBianShenEffect()
	if is_general == -1 then
		-- 变身结束
		cd_s = FamousGeneralData.Instance:GetBianShenCds()
		func = BindTool.Bind(self.UpdateGeneralCD, self)
	else
		-- 变身中
		cd_s = FamousGeneralData.Instance:GetBianShenTime()
		func = BindTool.Bind(self.UpdateGeneralSkill, self)
		local path, objname = "effects2/prefab/ui/ui_bsjm_prefab", "UI_bsjm"
		EffectManager.Instance:PlayAtTransformCenter(path, objname, GameObject.Find("GameRoot/UILayer").transform, cd_s)
	end
	CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
	self.general_skill.progress:SetValue(0)
	self.general_skill.cd_time:SetValue(0)
	if cd_s > 0 then
		self.general_skill.countdonw = CountDown.Instance:AddCountDown(cd_s, 0.05, func)
	else
		self:ChangeBianShenEffect()
	end
end

function MainUIViewSkill:UpdateGeneralSkill(elapse_time, total_time)
	local progress = (total_time - elapse_time) / total_time
	self.general_skill.progress:SetValue(progress)
	self.general_skill.cd_time:SetValue(math.ceil(total_time - elapse_time))
	if total_time - elapse_time <= 0 then
		CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
	end
end

function MainUIViewSkill:UpdateGeneralCD(elapse_time, total_time)
	local progress = (total_time - elapse_time) / total_time
	self.general_skill.progress:SetValue(progress)	
	local time  = -1
	if math.ceil(total_time - elapse_time) <= 60 then
		time = math.ceil(total_time - elapse_time)
	end
	self.general_skill.cd_time:SetValue(time)
	if total_time - elapse_time <= 0 then
		CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
		self:ChangeBianShenEffect()
	end
end

function MainUIViewSkill:ClickTeamSkill()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(1)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(0, 0, skill_info.level or 0)
	local team_skill_id = skill_level_cfg.active_skill_id

	target_obj = Scene.Instance:GetMainRole()
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	GlobalEventSystem:Fire(MainUIEventType.CLICK_SKILL_BUTTON, team_skill_id, target_obj)
	GuajiCtrl.Instance:DoFightByClick(team_skill_id, target_obj)

	if self.team_skill_pos then
		if SkillData.Instance:IsSkillCD(team_skill_id) then
			EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_dianji2_prefab", "UI_jineng_dianji2", self.team_skill_pos.transform)
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		else
			EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_dianji_prefab", "UI_jineng_dianji", self.team_skill_pos.transform)
		end
	end
end

function MainUIViewSkill:ClickWarSceneSkill()
	local now_num = SkillData.Instance:GetBianShenTime()
	local other_cfg = SkillData.Instance:GetWarSceneOtherCfg()
	if other_cfg ~= nil then
		local limit = other_cfg.bianshen_dead_count or 0
		local role = Scene.Instance:GetMainRole()
		if role and role:IsWarSceneState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsInWarSceneSkill)
			return			
		end

		if role and role.vo and SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER == role.vo.special_appearance then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsNoUseWarSceneSkill)
			return				
		end

		if now_num < limit then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.WarSceneSkillStr, limit, now_num))
			return
		end
	end

	SkillCtrl.Instance:SendUseWarSceneSkill()
end

function MainUIViewSkill:FlushTeamSkillState()
	local skill_info = RoleSkillData.Instance:GetSkillInfo(1)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(0, 0, skill_info.level or 0)
	local team_skill_id = skill_level_cfg.active_skill_id
	self.team_skill.show_btn:SetValue(team_skill_id > 0)
	if team_skill_id > 0 then
		local bundle, asset = ResPath.GetRoleSkillIcon(team_skill_id)
		self.team_skill.icon:SetAsset(bundle, asset)
	end

	self:FlushTeamSkillCd(team_skill_id)
end

function MainUIViewSkill:FlushTeamSkillCd(skill_id)
	if skill_id == 0 then return end
	local skill_info = RoleSkillData.Instance:GetSkillInfo(1)
	local skill_level_cfg = RoleSkillData.Instance:GetTeamSingleCfg(0, 0, skill_info.level or 0)
	local team_skill_id = skill_level_cfg.active_skill_id
	if skill_id == team_skill_id and not self.team_skill.countdonw then
		local skill_data_info = SkillData.Instance:GetSkillInfoById(skill_id) or {}
		local cd = (skill_data_info.cd_end_time or 0) - Status.NowTime
		if cd > 0 then
			self.team_skill.progress:SetValue(1.0)
			self.team_skill.countdonw = CountDown.Instance:AddCountDown(
				cd, 0.05, function(elapse_time, total_time)
					local progress = (total_time - elapse_time) / total_time
					self.team_skill.progress:SetValue(progress)
					self.team_skill.cd_time:SetValue(math.ceil(total_time - elapse_time))
					if elapse_time >= total_time then
						CountDown.Instance:RemoveCountDown(self.team_skill.countdonw)
						self.team_skill.countdonw = nil
						if total_time > 0 then
							EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_cdman_prefab", "UI_jineng_CDman", self.team_skill_pos.transform)
						end
					end
				end)
		end
	end
end

--引导用名将变身技能
function MainUIViewSkill:GetClickGeneralSkillCallBack()
	return BindTool.Bind(self.ClickGeneralSkill, self)
end

function MainUIViewSkill:ChangeBianShenEffect()
	local main_role = Scene.Instance:GetMainRole()
	local now_cd = FamousGeneralData.Instance:GetBianShenCds()
	if main_role and main_role:IsFightState() and now_cd <= 0 then
		self.general_skill.show_effect:SetValue(true)
	else
		self.general_skill.show_effect:SetValue(false)
	end
end

function MainUIViewSkill:OnClickSkillEffect(skill_id)
	local skill_data_info = SkillData.Instance:GetSkillInfoById(skill_id) or {}
	local index = SkillData.Instance:GetRealSkillIndex(skill_id)
	local cd = (skill_data_info.cd_end_time or 0) - Status.NowTime


	if self.skill_icon_pos_list[index] then
		if SkillData.Instance:IsSkillCD(skill_id) then
			EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_dianji2_prefab", "UI_jineng_dianji2", self.skill_icon_pos_list[index].transform)
		else
			EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui/ui_jineng_dianji_prefab", "UI_jineng_dianji", self.skill_icon_pos_list[index].transform)
		end
	end
end