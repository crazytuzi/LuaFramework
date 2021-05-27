SettingView = SettingView or BaseClass(BaseView)

function SettingView:AssistInit()
	local scroll_size = self.node_t_list.scroll_index1.node:getContentSize()
	self.nor_layout_top = self.node_tree.layout_set_assiant.layout_nor_top
	self.nor_layout_center = self.node_tree.layout_set_assiant.layout_nor_center
	self.nor_layout_down = self.node_tree.layout_set_assiant.layout_nor_down
	self.nor_layout_down.node:retain()
	self.nor_layout_down.node:removeFromParent()
	self.node_t_list.scroll_index1.node:addChild(self.nor_layout_down.node)
	self.nor_layout_down.node:release()
	self.nor_layout_center.node:retain()
	self.nor_layout_center.node:removeFromParent()
	self.node_t_list.scroll_index1.node:addChild(self.nor_layout_center.node)
	self.nor_layout_center.node:release()
	local down_height = self.nor_layout_down.node:getContentSize().height
	local center_height = self.nor_layout_center.node:getContentSize().height
	local top_height = self.nor_layout_top.node:getContentSize().height
	self.nor_layout_down.node:setPosition(scroll_size.width / 2, down_height / 2)
	self.nor_layout_center.node:setPosition(scroll_size.width / 2, self.nor_layout_down.node:getPositionY() + (down_height + center_height) / 2 + 5)
	self.nor_layout_top.node:retain()
	self.nor_layout_top.node:removeFromParent()
	self.node_t_list.scroll_index1.node:addChild(self.nor_layout_top.node)
	self.nor_layout_top.node:release()
	self.nor_layout_top.node:setPositionY(self.nor_layout_center.node:getPositionY() + (center_height + top_height) / 2 + 5)
	self.node_t_list.scroll_index1.node:setInnerContainerSize(cc.size(scroll_size.width, down_height + center_height + top_height + 18))
	self.node_t_list.scroll_index1.node:jumpToTop()

	local path_ball = ResPath.GetSetting("bg_3")
	local path_progress = ResPath.GetSetting("prog_104")
	local path_progress_bg = ResPath.GetSetting("prog_104_progress")

	local ph_music = self.ph_list.ph_music
	self.slider_music = XUI.CreateSlider(ph_music.x, ph_music.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_music:setMaxPercent(99)
	self.node_t_list.layout_music_setting.node:addChild(self.slider_music, 100)
	self.slider_music:addSliderEventListener(BindTool.Bind(self.OnMusicSliderEvent, self))
	self.node_t_list.layout_effect_setting.node:setPositionY(self.node_t_list.layout_effect_setting.node:getPositionY())

	local ph_voice = self.ph_list.ph_voice
	self.slider_voice = XUI.CreateSlider(ph_voice.x, ph_voice.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_voice:setMaxPercent(99)
	self.node_t_list.layout_effect_setting.node:addChild(self.slider_voice, 100)
	self.slider_voice:addSliderEventListener(BindTool.Bind(self.OnVoiceSliderEvent, self))

	-- 主界面大小
	-- local ph_mainui = self.ph_list.ph_mainui_scale
	-- self.slider_mainui_scale = XUI.CreateSlider(ph_mainui.x, ph_mainui.y, path_ball, path_progress_bg, path_progress, true)
	-- self.slider_mainui_scale:setMaxPercent(99)
	-- self.slider_mainui_scale:setCascadeOpacityEnabled(false)
	-- self.node_t_list.layout_mainuiscale_setting.node:addChild(self.slider_mainui_scale, 100)
	-- self.slider_mainui_scale:addSliderEventListener(BindTool.Bind(self.OnMainuiScaleEvent, self))
	-- XUI.AddClickEventListener(self.node_t_list.btn_scale_default.node, BindTool.Bind(self.OnClickDefaultScale, self))

	for i = 1, self.OPTION_COUNT do
		if self.node_t_list["layout_setting_option"..i] then
			XUI.AddClickEventListener(self.node_t_list["layout_setting_option"..i].node, BindTool.Bind(self.OnClickSysSetting, self, i))
			self.node_t_list["layout_setting_option"..i].lbl_set_name.node:setString(Language.Setting.OptionNames[i])
		end
	end
	--屏蔽法神，屏蔽幻影, 屏蔽主界面大小
	-- self.node_t_list["layout_setting_option25"].node:setVisible(false)
	-- self.node_t_list["layout_setting_option27"].node:setVisible(false)
	-- self.node_t_list["layout_mainuiscale_setting"].node:setVisible(false)

	-- self.node_t_list["layout_setting_option_nu"].lbl_set_name.node:setString(Language.Setting.PinbiNuSkill)
	-- XUI.AddClickEventListener(self.node_t_list["layout_setting_option_nu"].node, BindTool.Bind(self.OnClickNuSetting, self))
	self:RefreshCheckBox()
	self.node_t_list["layout_set_assiant"].node:setVisible(true)
end

function SettingView:RefreshCheckBox()
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SYS_SETTING)
	if data ~= nil then
		self.set_flag = bit:d2b(data)
		for i = 1, self.OPTION_COUNT do
			if self.node_t_list["layout_setting_option"..i] then
				self.node_t_list["layout_setting_option" .. i].img_setting_hook1.node:setVisible(1 == self.set_flag[33 - i])
			end
		end
	end
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local nu_skill = SPECIAL_SKILL_LIST[prof] or 31
	local client_index = SkillData.Instance:GetSkillClientIndex(nu_skill)
	-- if client_index then
	-- 	self.node_t_list["layout_setting_option_nu"].img_setting_hook1.node:setVisible(SettingCtrl.Instance:GetAutoSkillSetting(client_index))
	-- end
	-- self.node_t_list["layout_setting_option_nu"].node:setVisible(false)
	
	self.mainui_scale_percent = self:UiScaleToPercent(MainuiData.Instance:GetMainuiScale())
	-- self.slider_mainui_scale:setPercent(self.mainui_scale_percent)

	self.music_percent, self.voice_percent = SettingData.Instance:GetSoundData()
	self.slider_music:setPercent(self.music_percent)
	self.node_t_list.lbl_music_per.node:setString(self.music_percent .. "%")
	self.slider_voice:setPercent(self.voice_percent)
	self.node_t_list.lbl_voice_per.node:setString(self.voice_percent .. "%")
end

function SettingView:AssistDelete()
	-- body
end

function SettingView:AssistOnFlush(param_t, index)
	self:RefreshCheckBox()
end

function SettingView:OnMusicSliderEvent(sender, percent)
	self.music_percent = math.floor(percent)
	self.node_t_list.lbl_music_per.node:setString(self.music_percent .. "%")
	AudioManager.Instance:SetMusicVolume(percent / 100)
end

function SettingView:OnVoiceSliderEvent(sender, percent)
	self.voice_percent = math.floor(percent)
	self.node_t_list.lbl_voice_per.node:setString(self.voice_percent .. "%")
	AudioManager.Instance:SetEffectsVolume(percent / 100)
end

function SettingView:UiPercentToScale(percent)
	return MainuiData.UI_MIN_SCALE + (self.mainui_scale_percent / 100) * (MainuiData.UI_MAX_SCALE - MainuiData.UI_MIN_SCALE)
end
function SettingView:UiScaleToPercent(scale)
	return (scale - MainuiData.UI_MIN_SCALE) / (MainuiData.UI_MAX_SCALE - MainuiData.UI_MIN_SCALE) * 100
end

function SettingView:OnClickDefaultScale()
	self.slider_mainui_scale:setPercent(self:UiScaleToPercent(MainuiData.UI_NORAML_SCALE))
end

function SettingView:OnMainuiScaleEvent(sender, percent)
	-- self:GetRootNode():setOpacity(30)
	-- GlobalTimerQuest:CancelQuest(self.mainui_sacle_timer)
	-- self.mainui_sacle_timer = GlobalTimerQuest:AddDelayTimer(function()
	-- 	self:GetRootNode():setOpacity(255)
	-- 	self.mainui_sacle_timer = nil
	-- end, 1)

	self.mainui_scale_percent = math.floor(percent)
	MainuiData.Instance:SetMainuiScale(self:UiPercentToScale(self.mainui_scale_percent))
end

-- 系统设置项
function SettingView:OnClickSysSetting(index)
	local img_hook =  self.node_t_list["layout_setting_option" .. index].img_setting_hook1.node

	local flag = not img_hook:isVisible()
	img_hook:setVisible(flag)
	self.set_flag[33 - index] = flag and 1 or 0

	local data = bit:b2d(self.set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.SYS_SETTING, data)
	GlobalEventSystem:Fire(SettingEventType.SYSTEM_SETTING_CHANGE, index, flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING, data)
end
function SettingView:OnClickNuSetting()
	local img_hook =  self.node_t_list["layout_setting_option_nu"].img_setting_hook1.node

	local vis = img_hook:isVisible()
	img_hook:setVisible(not vis)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local nu_skill = SPECIAL_SKILL_LIST[prof] or 31
	local client_index = SkillData.Instance:GetSkillClientIndex(nu_skill)
	if client_index > 0 then
		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not vis})
	end
end