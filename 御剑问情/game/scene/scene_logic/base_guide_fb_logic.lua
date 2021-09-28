BaseGuideFbLogic = BaseGuideFbLogic or BaseClass(BaseFbLogic)

function BaseGuideFbLogic:__init()
	self.story = nil
	self.story_view = nil
	self.story_name = ""
	self.old_nuqui = 0
	self.gamepuse_evt = nil

	self.old_setting_t = {}
end

function BaseGuideFbLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end

	if nil ~= self.story_view then
		self.story_view:DeleteMe()
		self.story_view = nil
	end
end

function BaseGuideFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)

	self.story_view = StoryView.New(ViewName.StoryView)

	MainUICtrl.Instance:SetViewState(false)
	StoryCtrl.Instance:CloseEntranceView()

	self.old_nuqui = PlayerData.Instance:GetRoleVo().nuqi
	PlayerData.Instance:SetAttr("nuqi", math.floor(COMMON_CONSTS.NUQI_FULL * 0.3))

	-- 记录设置，退出场景后恢复
	self.old_setting_t[SETTING_TYPE.AUTO_PICK_PROPERTY] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY, true, true)

	self.old_setting_t[SETTING_TYPE.AUTO_PICK_COLOR] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_COLOR)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_PICK_COLOR, 0, true)

	self.old_setting_t[SETTING_TYPE.SHIELD_OTHERS] = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_OTHERS, false, true)

	self.old_setting_t[SETTING_TYPE.SHIELD_SAME_CAMP] = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP, false, true)

	self.old_setting_t[SETTING_TYPE.SELF_SKILL_EFFECT] = SettingData.Instance:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT, false, true)

	self.old_setting_t[SETTING_TYPE.SKILL_EFFECT] = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SKILL_EFFECT, false, true)

	self.old_setting_t[SETTING_TYPE.SHIELD_ENEMY] = SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY)
	SettingData.Instance:SetSettingData(SETTING_TYPE.SHIELD_ENEMY, false, true)

	self.old_setting_t[SETTING_TYPE.AUTO_RELEASE_SKILL] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RELEASE_SKILL)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RELEASE_SKILL, true, true)

	self.gamepuse_evt = GlobalEventSystem:Bind(SystemEventType.GAME_PAUSE, BindTool.Bind(self.OnGamePause, self))
end

function BaseGuideFbLogic:OnSceneDetailLoadComplete()
	self.story_view:SetOpenCallBack(function ()
		local step_list_cfg = ConfigManager.Instance:GetAutoConfig("story_auto")[self.story_name]
		if nil ~= step_list_cfg then
			RobertManager.Instance:Start()
			self.story = Story.New(step_list_cfg, self.story_view)
			self.story:SetTrigger(S_STEP_TRIGGER.ENTER_SCENE)
		end
	end)

	self.story_view:SetCloseCallBack(function ()
		if nil ~= self.story then
			self.story:DeleteMe()
			self.story = nil
		end
	end)

	self.story_view:Open()
end

function BaseGuideFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)

	if self.gamepuse_evt then
		GlobalEventSystem:UnBind(self.gamepuse_evt)
		self.gamepuse_evt = nil
	end
	PlayerData.Instance:SetAttr("nuqi", self.old_nuqui)

	if nil ~= self.story_view then
		self.story_view:Close()
	end

	RobertManager.Instance:Stop()

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	for k, v in pairs(self.old_setting_t) do
		SettingData.Instance:SetSettingData(k, v, true)
	end

	self.old_setting_t = {}

	-- 任务那里有考虑scene_type是否为普通场景，到下一帧scene_type才会是普通场景
	GlobalTimerQuest:AddDelayTimer(function ()
		TaskCtrl.Instance:SetAutoTalkState(true)
	end, 2)
end

function BaseGuideFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function BaseGuideFbLogic:OnGamePause(is_game_pause)
	if is_game_pause then
		Scene.Instance:GetMainRole():StopMove()
		GuajiCtrl.Instance:ClearAllOperate()
	end
end

function BaseGuideFbLogic:IsEnemy(target_obj, main_role, ignore_table)
	if nil ~= target_obj and nil ~= main_role then
		local attacker_robert = RobertManager.Instance:GetRobert(main_role:GetObjId())
		local target_robert = RobertManager.Instance:GetRobert(target_obj:GetObjId())
		return RobertManager.Instance:IsEnemy(attacker_robert, target_robert)
	end

	return BaseFbLogic.IsEnemy(self, target_obj, main_role, ignore_table)
end

function BaseGuideFbLogic:IsAutoStopTaskOnGuide()
	return false
end

function BaseGuideFbLogic:IsCanSystemAutoSetting()
	return false
end