require("scripts/game/setting/setting_select_view")
SettingView = SettingView or BaseClass(BaseView)

function SettingView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list[1] = 'res/xui/setting.png'
	self.title_img_path = ResPath.GetWord("word_setting")
	self.def_index = TabIndex.setting_assist
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"setting_ui_cfg", 1, {0}},
		{"setting_ui_cfg", 2, {0}},
		{"setting_ui_cfg", 3, {TabIndex.setting_assist}, false},
		{"setting_ui_cfg", 4, {TabIndex.setting_protect}, false},
		{"setting_ui_cfg", 5, {TabIndex.setting_fighting}, false},
		{"setting_ui_cfg", 6, {TabIndex.setting_pick_up}, false},
		{"common_ui_cfg", 2, {0}},
	}
	self.OPTION_COUNT = 23
	self.GJ_OPTION_COUNT = 5
	self.GJ_OPTION_COUNT2 = 7
	self.PICK_OPTION_COUNT = 7
	self.set_flag = {}
	self.guaji_set_flag = {}

	self.music_percent = 0
	self.voice_percent = 0
	self.mainui_scale_percent = 0

	self.hp_percent = 0
	self.mp_percent = 0
	self.hp_run_percent = 0

	self.hp_select = 0
	self.mp_select = 0
	self.run_select = 0
	self.pick_eq_select = 0

	self.single_select = 0
	self.group_select = 0

	self.pick_eqlv_data = {}

	self.single_skill_data = {}
	self.group_skill_data = {}

	self.confirm_dialog = Alert.New()
	self.has_open = false
	self.select_setting_view = SettingSelectView.New()
end

function SettingView:__delete()
	self.select_setting_view:DeleteMe()
	self.select_setting_view = nil
	
	self.confirm_dialog:DeleteMe()
	self.confirm_dialog = nil
end

function SettingView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self:AssistDelete()
	self:ProtectDelete()
	self:FightingDelete()
	self:PickUpDelete()

	-- if self.timer then
	-- 	GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
	-- end
	-- self.timer = nil
	self.gm_show_time = nil
end

function SettingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
		self.node_t_list.btn_role_select.node:addClickEventListener(BindTool.Bind(self.OnClickSelectRole, self))
		self.node_t_list.btn_back_loading.node:addClickEventListener(BindTool.Bind(self.OnClickToLogin, self))
	end

	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	self.node_t_list.lable_role_name.node:setString(Language.Setting.RoleName .. role_name)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_t_list.lable_role_id.node:setString(Language.Setting.RoleID .. role_id)
	
	-- 用户协议和隐私政策
	local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
	if (agent_id == "dev" or agent_id == "alz") and index == 1 then
		local ph, text_btn
		local parent = self.node_t_list["layout_bg"].node
		local callback1 = function()
			ViewManager.Instance:OpenViewByDef(ViewDef.UserAgreement)
		end

		local callback2 = function()
			ViewManager.Instance:OpenViewByDef(ViewDef.PrivacyPolicy)
		end

		local x, y = self.node_t_list["lable_role_name"].node:getPosition()
		ph = {x = x + 305, y = y - 11, w = 10, h = 10}
		text_btn = RichTextUtil.CreateLinkText("用户协议", 22, COLOR3B.GREEN)
		text_btn:setPosition(ph.x, ph.y)
		parent:addChild(text_btn, 99)
		XUI.AddClickEventListener(text_btn, callback1, true)

		local x, y = self.node_t_list["lable_role_id"].node:getPosition()
		ph = {x = x + 305, y = y - 11, w = 10, h = 10}
		self.node_t_list["lable_role_id"].node:getPosition()
		text_btn = RichTextUtil.CreateLinkText("隐私保护政策", 22, COLOR3B.GREEN)
		text_btn:setPosition(ph.x, ph.y)
		parent:addChild(text_btn, 99)
		XUI.AddClickEventListener(text_btn, callback2, true)
	end

	if index == TabIndex.setting_assist then
		self:AssistInit()
	elseif index == TabIndex.setting_protect then
		self:ProtectInit()
	elseif index == TabIndex.setting_fighting then
		self:FightingInit()
	elseif index == TabIndex.setting_pick_up then
		self:PickUpInit()
	end

	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GM_LEVEL) >= 1 then	-- 测试号显示开服时间
		self.gm_show_time = XUI.CreateText(-50, 20, 300, 20, cc.TEXT_ALIGNMENT_LEFT, "")
		self.node_t_list.layout_bg.node:addChild(self.gm_show_time, 999)
		self.gm_show_time:setString(os.date("%Y-%m-%d  %H:%M:%S", OtherData.Instance:GetOpenServerTime()))
	end
end

function SettingView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 10, -5,
			BindTool.Bind1(self.SelectTabCallback, self), Language.Setting.TabGroup, 
			true, ResPath.GetCommon("toggle_120"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function SettingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.hp_percent, self.mp_percent, self.hp_run_percent = SettingData.Instance:GetSupplyData()
	self.music_percent, self.voice_percent = SettingData.Instance:GetSoundData()
	self.hp_select, self.mp_select, self.run_select, self.pick_eq_select, self.money_select, self.level_dan_select = SettingData.Instance:GetSelectOptionData()
	self.single_select, self.group_select = SettingData.Instance:GetGuajiSkillData()
	if not self.has_open then
		for k,v in pairs(SettingData.DRUG_T) do
			ItemData.Instance:GetItemConfig(v)
		end
		for k,v in pairs(SettingData.DELIVERY_T) do
			ItemData.Instance:GetItemConfig(v)
		end
	end
	self.has_open = true
end

function SettingView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index)
	if index == TabIndex.setting_assist then
		self.node_t_list["layout_set_assiant"].node:setVisible(true)
	elseif index == TabIndex.setting_protect then
		self.node_t_list["layout_protect_set"].node:setVisible(true)
	elseif index == TabIndex.setting_fighting then
		self.node_t_list["layout_skill_set"].node:setVisible(true)
	elseif index == TabIndex.setting_pick_up then
		self.node_t_list["layout_pick_up"].node:setVisible(true)
	end

	self:Flush(index)
end

function SettingView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

function SettingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	local hp_percent, mp_percent, hp_run_percent = SettingData.Instance:GetSupplyData()
	if hp_percent ~= self.hp_percent or mp_percent ~= self.mp_percent  or hp_run_percent ~= self.hp_run_percent then
		SettingCtrl.Instance:ChangeSupplySetting(self.hp_percent, self.mp_percent, self.hp_run_percent)
	end
	local music_percent, voice_percent = SettingData.Instance:GetSoundData()
	if music_percent ~= self.music_percent or voice_percent ~= self.voice_percent then
		SettingCtrl.Instance:ChangeSoundSetting(self.music_percent, self.voice_percent)
	end
	local hp_select, mp_select, run_select, pick_eq_select, money_select, level_dan_select = SettingData.Instance:GetSelectOptionData()
	if hp_select ~= self.hp_select or mp_select ~= self.mp_select 
		or run_select ~= self.run_select  or pick_eq_select ~= self.pick_eq_select
		or money_select ~= self.money_select or level_dan_select ~= self.level_dan_select 
		then
		SettingCtrl.Instance:ChangeSelectOptionSetting(self.hp_select, self.mp_select, self.run_select, self.pick_eq_select, self.money_select, self.level_dan_select)
	end
	local single_select, group_select = SettingData.Instance:GetGuajiSkillData()
	if single_select ~= self.single_select or group_select ~= self.group_select then
		SettingCtrl.Instance:ChangeGuajiSkillSetting(self.single_select, self.group_select)
	end
	MainuiData.Instance:SaveMainuiScale()
end

function SettingView:OnFlush(param_t, index)
	if index == TabIndex.setting_assist then
		self:AssistOnFlush(param_t, index)
	elseif index == TabIndex.setting_protect then
		self:ProtectOnFlush(param_t, index)
	elseif index == TabIndex.setting_fighting then
		self:FightingOnFlush(param_t, index)
	elseif index == TabIndex.setting_fighting then
		self:PickUpFlush(param_t, index)
	end
end

-- 返回登录
function SettingView:OnClickToLogin()
	function ok_callback()
		if AgentAdapter.OnClickRestartGame then
			AgentAdapter.OnClickRestartGame()
		else	
			ReStart()
		end
	end

	self.confirm_dialog:SetOkString(Language.Common.Confirm)
	self.confirm_dialog:SetCancelString(Language.Common.Cancel)
	self.confirm_dialog:SetLableString(Language.Common.BackToLogin)
	self.confirm_dialog:SetOkFunc(ok_callback)
	self.confirm_dialog:Open()
end

-- 返回选择角色
function SettingView:OnClickSelectRole()
	if CrossServerCtrl.CrossServerPingbi() then return end

	function ok_callback()	
		AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
		AdapterToLua:getInstance():setDataCache("IS_RESELECTROLE", "true")
		ReStart()
	end

	self.confirm_dialog:SetOkString(Language.Common.Confirm)
	self.confirm_dialog:SetCancelString(Language.Common.Cancel)
	self.confirm_dialog:SetLableString(Language.Common.BackToSelectRole)
	self.confirm_dialog:SetOkFunc(ok_callback)
	self.confirm_dialog:Open()
end

function SettingView:InitPickUpData()
	self.pick_eqlv_data = {}
	for k,v in pairs(SettingData.PICK_EQLV) do
		local str = v ..Language.Common.Jie
		table.insert(self.pick_eqlv_data, string.format(Language.Setting.PickEqLv, str))
	end
end

function SettingView:InitSingleSkillData()
	self.single_skill_data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i,v in ipairs(SettingData.SKILL[prof][1]) do
		local skill_cfg = SkillData.GetSkillCfg(v)
		if skill_cfg then
			table.insert(self.single_skill_data, skill_cfg.name)
		end
	end
end

function SettingView:InitGroupSkillData()
	self.group_skill_data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i,v in ipairs(SettingData.SKILL[prof][2]) do
		local skill_cfg = SkillData.GetSkillCfg(v)
		if skill_cfg then
			table.insert(self.group_skill_data, skill_cfg.name)
		end
	end
end
