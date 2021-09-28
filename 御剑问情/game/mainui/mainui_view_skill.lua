MainUIViewSkill = MainUIViewSkill or BaseClass(BaseRender)

local prof_skill = {
	{111, 141, 121, 131, 0, 0, 5},
	{211, 221, 231, 241, 0, 0, 5},
	{311, 341, 331, 321, 0, 0, 5},
	{411, 441, 431, 421, 0, 0, 5},
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
	self.skill_infos = {
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo()
	}

	-- 找到要控制的变量
	self.skill_icons = {
		self:FindVariable("AttackIcon"),
		self:FindVariable("SkillIcon1"),
		self:FindVariable("SkillIcon2"),
		self:FindVariable("SkillIcon3"),
		self:FindVariable("SkillIcon5"),
		self:FindVariable("SkillIcon6"),
		self:FindVariable("KillIcon"),
	}

	self.skill_locked = {
		self:FindVariable("AttackLocked"),
		self:FindVariable("SkillLocked1"),
		self:FindVariable("SkillLocked2"),
		self:FindVariable("SkillLocked3"),
		nil,
		nil,
		self:FindVariable("KillLocked"),
	}
	self.show_mojie = self:FindVariable("ShowSkill5")
	self.show_goddess = self:FindVariable("ShowSkill6")
	self.show_mojie_gray_1 = self:FindVariable("Skill5_1Gray")
	self.show_mojie_gray_2 = self:FindVariable("Skill5_2Gray")
	self.show_mojie_panel = self:FindObj("Skill5ChangePanel").animator
	self.general_image = self:FindObj("general_icon").image.sprite
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
		self:FindVariable("SkillCDProgress5"),
		self:FindVariable("SkillCDProgress6"),
		self:FindVariable("KillCDProgress"),
	}

	self.skill_cd_time = {
		self:FindVariable("SkillCDTime1"),
		self:FindVariable("SkillCDTime2"),
		self:FindVariable("SkillCDTime3"),
		self:FindVariable("SkillCDTime5"),
		self:FindVariable("SkillCDTime6"),
	}

	self.general_skill = {}
	self.general_skill.cd_time = self:FindVariable("GeneralSkillCD")
	self.general_skill_cd = 0
	self.general_skill.end_cd = self:FindVariable("GeneralCD")
	self.general_skill.end_cd_text = self:FindVariable("GeneralCDText")
	self.general_skill.cd_time_text = self:FindVariable("GeneralSkillCDText")
	self.general_skill.progress = self:FindVariable("GeneralCDProgress")
	self.general_skill.change_effect = self:FindObj("change")
	self.general_skill.is_bianshen = false
	self.show_general = self:FindVariable("ShowGeneral")

	self.show_zhoumo_equipskill = self:FindVariable("ShowZhouMoEquipSkill")
	self.zhoumo_equipskillicon = self:FindVariable("ZhouMoEquipSkillIcon")
	self.zhoumo_equipskillcd = self:FindVariable("ZhouMoEquipSkillCD")
	self.zhoumo_equipskillcdprogress = self:FindVariable("ZhouMoEquipSkillCDProgress")
	self.zhoumo_equip_skill_name = self:FindVariable("ZhouMoEquipSkillName")

	self.dot = self:FindVariable("Dot")
	self.skill6_name = self:FindVariable("Skill6Name")
	self.skill5_name = self:FindVariable("Skill5Name")
	self.show_kill_effect = self:FindVariable("ShowKillEffect")
	self.show_kill6_effect = self:FindVariable("ShowKill6Effect")
	self.show_kill6_effect2 = self:FindVariable("ShowKill6Effect2")
	self.is_show_kill6_effect = false

	for i=1,4 do
		self.skill_cd_progress[i]:SetValue(0)
		self.skill_cd_time[i]:SetValue(0)
	end

	self.skill_count_down = {}
	self.speci_skill_count_down = {}
	self.is_lock_skill = false

	-- 监听UI事件
	self:ListenEvent("AttackDown", BindTool.Bind(
		self.OnClickAttackDown, self, self.skill_infos[1]))
	self:ListenEvent("AttackUp", BindTool.Bind(
		self.OnClickAttackUp, self, self.skill_infos[1]))
	self:ListenEvent("Skill1", BindTool.Bind(
		self.OnClickSkill, self, self.skill_infos[2]))
	self:ListenEvent("Skill2", BindTool.Bind(
		self.OnClickSkill, self, self.skill_infos[3]))
	self:ListenEvent("Skill3", BindTool.Bind(
		self.OnClickSkill, self, self.skill_infos[4]))
	self:ListenEvent("Skill5", BindTool.Bind(
		self.OnClickSkill5Up, self, self.skill_infos[5]))
	self:ListenEvent("Skill5Down", BindTool.Bind(
		self.OnClickSkill5Down, self, self.skill_infos[5]))
	self:ListenEvent("Skill6", BindTool.Bind(
		self.OnClickSkill, self, self.skill_infos[6]))
	self:ListenEvent("Kill", BindTool.Bind(
		self.OnClickSkill, self, self.skill_infos[7]))
	self:ListenEvent("Jump", BindTool.Bind(
		self.OnClickJump, self))
	self:ListenEvent("ClickSkill5_1", BindTool.Bind(
		self.ClickSkill5Change, self, 1))
	self:ListenEvent("ClickSkill5_2", BindTool.Bind(
		self.ClickSkill5Change, self, 2))
	self:ListenEvent("OnClickJinjieEquipSkill", BindTool.Bind(
		self.OnClickJinjieEquipSkill, self))
	self:ListenEvent("GeneralSkill", BindTool.Bind(self.ClickGeneralSkill, self))
	self:ListenEvent("OnZhouMoEquipSkill", BindTool.Bind(self.OnZhouMoEquipSkill, self))

	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.recv_main_role_info_handle = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self.role_skill_change_handle = GlobalEventSystem:Bind(MainUIEventType.ROLE_SKILL_CHANGE, BindTool.Bind(self.OnSkillChange, self))
	self.role_use_skill_handle = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))
	self.jinjie_equip_skill_change_handle = GlobalEventSystem:Bind(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE, BindTool.Bind(self.SetJinjieSkillInfo, self))

	self.change_area_type = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_CHANGE_AREA_TYPE, BindTool.Bind(self.OnMainRoleSwitchScene, self))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
	self.mojie_info_event = BindTool.Bind(self.OnSkillChange, self, "mojie")
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	-- 首次刷新数据
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self:PlayerDataChangeCallback("nuqi", vo.nuqi, 0)
	self:PlayerDataChangeCallback("level", vo.level, vo.level)
	self:OnRecvMainRoleInfo(SkillData.ANGER_SKILL_ID)
	self:OnSkillChange()

	-- 定位技能按钮位置
	self.skill_icon_pos_list = {
		[1] = self:FindObj("Skill1"),
		[2] = self:FindObj("Skill2"),
		[3] = self:FindObj("Skill3"),
		[4] = self:FindObj("Skill4"),
		[5] = self:FindObj("Skill5"),
		[6] = self:FindObj("Skill6"),
	}

	Runner.Instance:AddRunObj(self, 6)

	self.enter_safe_area_animator = self:FindObj("EnterSafeArea"):GetComponent(typeof(UnityEngine.Animator))
	self.leave_safe_area_animator = self:FindObj("LeaveSafeArea"):GetComponent(typeof(UnityEngine.Animator))

	self.jinjie_skill_total_count = self:FindVariable("JinjieSkillTotalCount")
	self.jinjie_skill_cur_count = self:FindVariable("JinjieSkillCurCount")
	self.jinjie_skill_icon = self:FindVariable("JinjieSkillIcon")
	self.special_cdmask = self:FindVariable("SpecialCdMask")
	self.general_icon = self:FindVariable("GeneralIcon")

	self.show_mojie_skill = false

	self.select_obj_group_list = {}
	self.skill_state = false
	self:SetJinjieSkillInfo()
	self:FlushGeneralSkill()
	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.get_ui_callback)
end

function MainUIViewSkill:__delete()
	FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.get_ui_callback)
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)

	Runner.Instance:RemoveRunObj(self)

	GlobalEventSystem:UnBind(self.recv_main_role_info_handle)
	GlobalEventSystem:UnBind(self.role_skill_change_handle)
	GlobalEventSystem:UnBind(self.role_use_skill_handle)
	GlobalEventSystem:UnBind(self.jinjie_equip_skill_change_handle)

	if self.change_area_type ~= nil then
		GlobalEventSystem:UnBind(self.change_area_type)
		self.change_area_type = nil
	end
	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer)
	GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
	self.skill5_time_quest = nil
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_change ~= nil then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end
	if self.parent ~= nil then
		self.parent = nil
	end
	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	for i, v in ipairs(self.skill_infos) do
		CountDown.Instance:RemoveCountDown(v.countdonw1)
		CountDown.Instance:RemoveCountDown(v.countdonw2)
	end
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
	local left_count = AdvanceData.Instance:GetJinjieGaugeCount() - game_vo.upgrade_cur_calc_num
	self.special_cdmask:SetValue(left_count / AdvanceData.Instance:GetJinjieGaugeCount())

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
		-- self.skill_cd_progress[6]:SetValue(value / COMMON_CONSTS.NUQI_FULL)
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
	local kill_skill_id = 5

	for skill_id, v in pairs(skillinfo) do
		if prof == math.modf(skill_id / 100) then
			skill_list[v.skill_index] = v
		elseif skill_id == kill_skill_id then
			skill_list[7] = v
		end
	end

	for i, v in ipairs(self.skill_infos) do
		v.skill_id = skill_list[i] and skill_list[i].skill_id or 0
	end
end

function MainUIViewSkill:CheckNuqiEff()
	local skill_info = SkillData.Instance:GetSkillInfoById(SkillData.ANGER_SKILL_ID)
	local cd = 1
	if skill_info and PlayerData.Instance.role_vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		cd = skill_info.cd_end_time - Status.NowTime
	end
	self.show_kill_effect:SetValue(cd <= 0)
	if cd <= 0 and self.skill_cd_progress[6] then
		self.skill_cd_progress[6]:SetValue(1)
	end
end

function MainUIViewSkill:OnSkillChange(change_type, skill_id)
	local mojie_index = 0
	local skill_info = nil
	local skill_cfg = nil
	for i, v in ipairs(self.skill_infos) do
		if i == 5 then
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
		elseif i == 6 then
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
				if v.skill_id == 5 then
					local prof = PlayerData.Instance:GetAttr("prof")
					v.skill_icon = skill_cfg.skill_icon + prof
				else
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		end
		if skill_info and ("list" == change_type or nil == change_type) then
			if v.skill_id ~= SkillData.ANGER_SKILL_ID or not self.has_cheak_nuqi then
				self:OnMainRoleUseSkill(v.skill_id)
				if v.skill_id == SkillData.ANGER_SKILL_ID then
					self:CheckNuqiEff()
				end
			end
		end
		if skill_id == v.skill_id and SkillData.Instance:GetSkillInfoById(skill_id) and self.skill_cd_progress[i - 1] and self.skill_cd_time[i - 1] then
			local change_skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
			local cd = change_skill_info.cd_end_time - Status.NowTime
			if cd <= 0 then
				CountDown.Instance:RemoveCountDown(v.countdonw1)
				CountDown.Instance:RemoveCountDown(v.countdonw2)
				self.skill_cd_progress[i - 1]:SetValue(0.0)
				self.skill_cd_time[i - 1]:SetValue(0.0)
				self.skill_count_down[skill_id] = false
				self.speci_skill_count_down[skill_id] = false
			end
		end
	end
	if self.skill_infos[1] and SkillData.Instance:GetSkillInfoById(self.skill_infos[1].skill_id or 0) then
		self.has_cheak_nuqi = true
	end

	self.parent:Flush("skill")
end

function MainUIViewSkill:OnMainRoleUseSkill(skill_id)
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

	elseif skill_id == 610 or skill_id == 611 or skill_id == 612 then
		self:FlushZhouMoEquipSkillTime(skill_id)

	elseif math.floor(skill_id / 10) == math.floor(self.skill_infos[1].skill_id / 10) then
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
			local bundle, asset = ResPath.GetRoleSkillIcon(self.skill_infos[1].skill_icon)
			self.skill_icons[1]:SetAsset(bundle, asset)
			self.common_skill_timer = nil
		end, 1.0)
	elseif skill_id % 10 == 1 or MojieData.IsMojieSkill(skill_id) or GoddessData.Instance:IsGoddessSkill(skill_id) or skill_id == SkillData.ANGER_SKILL_ID then
	-- elseif skill_id % 10 == 1 or MojieData.IsMojieSkill(skill_id) or GoddessData.IsGoddessSkill(skill_id) or skill_id == SkillData.ANGER_SKILL_ID then
		-- 触发技能的CD倒计时
		for i, v in ipairs(self.skill_infos) do
			if v.skill_id == skill_id then
				if self.skill_count_down[skill_id] then
					return
				end
				self.skill_count_down[skill_id] = true
				local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
				local cd = skill_info.cd_end_time - Status.NowTime
				if skill_id == SkillData.ANGER_SKILL_ID then
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
						if skill_id == SkillData.ANGER_SKILL_ID then
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
							end
						end)
				end
				break
			end
		end
	end
end

function MainUIViewSkill:ClickGeneralSkill()
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsJump() then
		return
	end

	--变身的时候下坐骑（防止变回来时模型加载出问题）
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.fight_mount_appeid and main_role_vo.fight_mount_appeid > 0 then
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
	end
	if main_role_vo.mount_appeid and main_role_vo.mount_appeid > 0 then
		MountCtrl.Instance:SendGoonMountReq(0)
	end

	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_BIANSHEN)
	self.general_skill.change_effect.gameObject:SetActive(false)
	self.general_skill.change_effect.gameObject:SetActive(true)
	GlobalTimerQuest:AddDelayTimer(function ()
		self.general_skill.change_effect.gameObject:SetActive(false)
	end,1)

end

function MainUIViewSkill:OnZhouMoEquipSkill()
	local skill_id = TianshenhutiData.Instance:GetTaoZhuangSkillID()
	if nil == skill_id or skill_id == 0 then
		return
	end

	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	if skill_info == nil then
		return
	end

	local skill_time = TianshenhutiData.Instance:GetSkillTimeInfo(skill_id) or 0
	local end_time = skill_info.last_perform + skill_time
	local svr_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - svr_time
	if rest_time > 0 then
		return
	end

	-- if self.skill_state then
	-- 	Scene.Instance:OnRemoveTransparent()
	-- else
	-- 	Scene.Instance:OnAddTransparent()
	-- end

	-- self.skill_state = not self.skill_state

	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()
	local target_x, target_y = main_role:GetLogicPos()
	FightCtrl.SendPerformSkillReq(
		skill_info.index,
		0,
		target_x,
		target_y,
		main_role:GetObjId(),
		false,
		main_role_x,
		main_role_y)
end

function MainUIViewSkill:FlushGeneralSkill()
	if self.show_general then
		if GeneralSkillData.Instance:CheckShowSkill() then
			local seq = GeneralSkillData.Instance:GetMainSlot()
			local is_use, cur_used_special_img_id = SpecialGeneralData.Instance:GetCurIsUsedSpecialImgIdAndSpecialImgId()
			if is_use then					--使用特殊天神(幻化形象)
				seq = cur_used_special_img_id
			end
			self.general_icon:SetAsset(ResPath.GetFamousTalentTypeIcon(seq))
			self.show_general:SetValue(true)
		else
			self.show_general:SetValue(false)
		end
	end
end

function MainUIViewSkill:GetShowGeneral()
	return self.show_general:GetBoolean()
end

function MainUIViewSkill:GetGeneralCD()
	return self.general_skill_cd
end

function MainUIViewSkill:GeneralBianShenCd()
	local is_general = GeneralSkillData.Instance:GetCurUseSeq()
	local cd_s = 0
	local func = nil
	self:ChangeBianShenEffect()
	if is_general == -1 then
		-- 变身结束
		cd_s = GeneralSkillData.Instance:GetBianShenCds()
		func = BindTool.Bind(self.UpdateGeneralCD, self)
	else
		-- 变身中
		cd_s = GeneralSkillData.Instance:GetBianShenTime()
		func = BindTool.Bind(self.UpdateGeneralSkill, self)
		-- local path, objname = "effects2/prefab/ui/ui_bsjm_prefab", "UI_bsjm"
		-- EffectManager.Instance:PlayAtTransformCenter(path, objname, GameObject.Find("GameRoot/UILayer").transform, cd_s)
	end
	CountDown.Instance:RemoveCountDown(self.general_skill.countdown)
	self.general_skill.progress:SetValue(1)
	self.general_skill.cd_time:SetValue(0)
	self.general_skill.end_cd:SetValue(0)
	if cd_s > 0 then
		self.general_skill.countdown = CountDown.Instance:AddCountDown(cd_s, 0.05, func)
	else
		self:ChangeBianShenEffect()
	end
end

function MainUIViewSkill:UpdateGeneralSkill(elapse_time, total_time)
	self.general_skill_cd = 1
	local progress = (total_time - elapse_time) / total_time
	self.general_skill.progress:SetValue(progress)
	self.general_skill.end_cd:SetValue(math.ceil(total_time - elapse_time))
	self.general_skill.end_cd_text:SetValue(TimeUtil.FormatSecond(math.ceil(total_time - elapse_time), 2))
	if total_time - elapse_time <= 0 then
		CountDown.Instance:RemoveCountDown(self.general_skill.countdown)
	end
end

function MainUIViewSkill:UpdateGeneralCD(elapse_time, total_time)
	local progress = (total_time - elapse_time) / total_time
	self.general_skill.progress:SetValue(1 - progress)
	local time  = -1
	time = math.ceil(total_time - elapse_time)
	-- if math.ceil(total_time - elapse_time) <= 60 then

	-- end
	self.general_skill.cd_time:SetValue(time)
	self.general_skill_cd = time
	self.general_skill.cd_time_text:SetValue(TimeUtil.FormatSecond(math.ceil(total_time - elapse_time), 2))
	if total_time - elapse_time <= 0 then
		CountDown.Instance:RemoveCountDown(self.general_skill.countdown)
		self:ChangeBianShenEffect()
	end
end

function MainUIViewSkill:FlushZhouMoEquip()
	local skill_id = TianshenhutiData.Instance:GetTaoZhuangSkillID()
	local skill_type = TianshenhutiData.Instance:GetTaoZhuangType()
	local asset, bundle = ResPath.GetTianShenSkill(skill_id)

	if self.show_zhoumo_equipskill then
		self.show_zhoumo_equipskill:SetValue(skill_type > 0)
	end

	if self.zhoumo_equipskillicon and skill_id ~= 0 then
		self.zhoumo_equipskillicon:SetAsset(asset, bundle)
	end

	if self.zhoumo_equip_skill_name and skill_id ~= 0 then
		self.zhoumo_equip_skill_name:SetValue(Language.MainSkillName[skill_id])
	end
end

function MainUIViewSkill:FlushZhouMoEquipSkillTime(skill_id)
	local skill_time = TianshenhutiData.Instance:GetSkillTimeInfo(skill_id) or 0
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local rest_time = skill_info.cd_end_time - Status.NowTime

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	if rest_time > 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 0.05, function (elapse_time, total_time)
			local left_time = total_time - elapse_time

			if left_time <= 0 then
				left_time = 0
				if self.least_time_timer then
	    			CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    			self.least_time_timer = nil
	   			end
	   			if self.zhoumo_equipskillcd and self.zhoumo_equipskillcdprogress then
		   			self.zhoumo_equipskillcd:SetValue("")
					self.zhoumo_equipskillcdprogress:SetValue(0)
				end
	   		else
				-- local time = TimeUtil.FormatSecond(left_time, 7)
		  --       self.flush_time:SetValue(string.format(Language.Activity.FestivalActivityShowTime, time))
		  		if self.zhoumo_equipskillcd and self.zhoumo_equipskillcdprogress then
			  		self.zhoumo_equipskillcd:SetValue(math.ceil(left_time))
					self.zhoumo_equipskillcdprogress:SetValue(left_time / skill_time)
				end
		    end
	    end)
	end
end

function MainUIViewSkill:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_bianshen_cd" then
			self:GeneralBianShenCd()
		elseif k == "check_skill" then
			self:FlushGeneralSkill()
		elseif k == "zhoumo_equip" then
			self:FlushZhouMoEquip()
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

	local scene_logic = Scene.Instance:GetSceneLogic()

	for i, v in ipairs(self.skill_infos) do
		if i == 5 then
			self.show_mojie:SetValue(v.is_exist)
			if v.skill_id ~= 0 then
				local skill_name = SkillData.GetSkillinfoConfig(v.skill_id).skill_name
				if skill_name then
					self.skill5_name:SetValue(skill_name)
				end
			end
		elseif i == 6 then
			local is_show_goddess_skill = scene_logic and scene_logic:CanUseGoddessSkill() or false
			self.show_goddess:SetValue(v.is_exist and is_show_goddess_skill)

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

		if v.is_exist and nil ~= v.skill_icon then
			if i == 6 then
				local bundle, asset = ResPath.GetRoleSkillIconThree(v.skill_icon)
				self.skill_icons[i]:SetAsset(bundle, asset)
			elseif i == 5 then
				local bundle, asset = ResPath.GetRoleSkillIconTwo(v.skill_icon)
				self.skill_icons[i]:SetAsset(bundle, asset)
			else
				local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
				self.skill_icons[i]:SetAsset(bundle, asset)
			end
		end
		v.territory_lock = false
		if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
			if i == 5 then
				self.show_mojie:SetValue(false)
			elseif i == 6 then
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
			local bundle, asset = ResPath.GetRoleSkillIconTwo(v.skill_icon)
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
	else
		if off_y < 0 then
			MainUICtrl.Instance:OpenNearRole()
		else
			self:SelectObj(SceneObjType.Monster, SelectType.Enemy)
		end
	end
	click_attack_down = nil
end

function MainUIViewSkill:SelectObj(obj_type, select_type)
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
			can_select = not v:IsRealDead()
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	table.sort(temp_obj_list, function(a, b) return a.dis < b.dis end)

	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[obj_type]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end

	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		if nil == select_obj_list[v.obj:GetObjId()] then
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
	if GuajiCtrl.Instance:IsInSafeTarget() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fight.Safe)
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

function MainUIViewSkill:ChangeBianShenEffect()
	local main_role = Scene.Instance:GetMainRole()
	local now_cd = GeneralSkillData.Instance:GetBianShenCds()
	-- if now_cd <= 0 then
	-- 	self.general_skill.show_effect:SetValue(true)
	-- else
	-- 	self.general_skill.show_effect:SetValue(false)
	-- end
end

function MainUIViewSkill:GetUiCallBack(ui_name, ui_param)
	if ui_name == GuideUIName.MainUIPartnerSkillIcon then
		local icon = self.skill_icon_pos_list[6]
		if icon.gameObject.activeInHierarchy then
			return icon
		end
	end

	return nil
end

function MainUIViewSkill:HideBianShen(is_show)
	self.show_general:SetValue(is_show)
	if is_show then
		self:FlushGeneralSkill()
	end
end