SettingCustomView = SettingCustomView or BaseClass(BaseRender)

function SettingCustomView:__init(instance)
	SettingCustomView.Instance = self
	self.title_input = self:FindObj("title_input")
	self.content_input = self:FindObj("content_input")
	self.sugget_toggle = self:FindObj("sugget_toggle")
	self:ListenEvent("send_click", BindTool.Bind(self.SendClick,self))
	for i=1,3 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.qudao_text_1 = self:FindVariable("qudao_1")
	self.qudao_text_2 = self:FindVariable("qudao_2")
	local agent_id = ChannelAgent.GetChannelID()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		if agent_id == v.spid then
			self.qudao_text_1:SetValue(v.contect)
			self.qudao_text_2:SetValue(v.contect_2)
		end
	end
end

function SettingCustomView:__delete()
	SettingCustomView.Instance = nil
	self.qudao_text_2 = nil
	self.qudao_text_1 = nil
end

function SettingCustomView:OnToggleClick(i,is_click)
	if is_click then
		self.select_send_type = i
	end
end

function SettingCustomView:OpenCustom()
	self.sugget_toggle.toggle.isOn = true
	self.select_send_type = SEND_CUSTOM_TYPE.SUGGEST
	self.title_input.input_field.text = ""
	self.content_input.input_field.text = ""
end

function SettingCustomView:SendClick()
	if not self.select_send_type then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[1])
	elseif self.title_input.input_field.text == ""  then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[2])
	elseif self.content_input.input_field.text == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SettingSendTips[3])
	else
		local list = {}
		local vo = GameVoManager.Instance:GetMainRoleVo()
		list.zone_id = GLOBAL_CONFIG.package_info.config.agent_id
		list.server_id = GameVoManager.Instance:GetUserVo().plat_server_id
		list.user_id = vo.role_id
		list.role_id = vo.role_id
		list.role_name = vo.role_name
		list.role_level = vo.level
		list.role_gold = vo.gold
		list.role_scene = vo.scene_id
		list.issue_type = SettingData.Instance:GetIssueTypeName(self.select_send_type)
		list.issue_subject = self.title_input.input_field.text
		list.issue_content = self.content_input.input_field.text
		SettingCtrl.Instance:SendRequest(list)
	end
end

