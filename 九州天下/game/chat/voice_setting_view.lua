VoiceSettingView = VoiceSettingView or BaseClass(BaseView)

local SETTING_COUNT = 4

local SettingList = {
	["world"] = 1,
	["team"] = 2,
	["guild"] = 3,
	["privite"] = 4,
}

function VoiceSettingView:__init()
	self.ui_config = {"uis/views/chatview","VoiceSettingView"}
	self:SetMaskBg(true)
end

function VoiceSettingView:__delete()
	
end

function VoiceSettingView:ReleaseCallBack()
	-- 清理变量和对象
	self.world_voice_animator = nil
	self.team_voice_animator = nil
	self.guild_voice_animator = nil
	self.privite_voice_animator = nil
end

function VoiceSettingView:LoadCallBack()
	self.world_voice_animator = self:FindObj("WorldVoice").animator
	self.team_voice_animator = self:FindObj("TeamVoice").animator
	self.guild_voice_animator = self:FindObj("GuildVoice").animator
	self.privite_voice_animator = self:FindObj("PriviteVoice").animator

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

	self:ListenEvent("AutoWorldClick", BindTool.Bind(self.AutoClick, self, SettingList.world))
	self:ListenEvent("AutoTeamClick", BindTool.Bind(self.AutoClick, self, SettingList.team))
	self:ListenEvent("AutoGuildClick", BindTool.Bind(self.AutoClick, self, SettingList.guild))
	self:ListenEvent("AutoPriviteClick", BindTool.Bind(self.AutoClick, self, SettingList.privite))
end

function VoiceSettingView:CloseWindow()
	self:Close()
end

function VoiceSettingView:AutoClick(index)
	local state = false
	local animator = nil
	local ani_state = false
	if index == SettingList.world then
		state = ChatData.Instance:GetAutoWorldVoice()
		animator = self.world_voice_animator
	elseif index == SettingList.team then
		state = ChatData.Instance:GetAutoTeamVoice()
		animator = self.team_voice_animator
	elseif index == SettingList.guild then
		state = ChatData.Instance:GetAutoGuildVoice()
		animator = self.guild_voice_animator
	elseif index == SettingList.privite then
		state = ChatData.Instance:GetAutoPriviteVoice()
		animator = self.privite_voice_animator
	end

	if animator then
		ani_state = animator:GetBool("auto")
	end

	if animator and state == ani_state then
		local new_state = not ani_state
		if index == SettingList.world then
			ChatData.Instance:SetAutoWorldVoice(new_state)
		elseif index == SettingList.team then
			ChatData.Instance:SetAutoTeamVoice(new_state)
		elseif index == SettingList.guild then
			ChatData.Instance:SetAutoGuildVoice(new_state)
		elseif index == SettingList.privite then
			ChatData.Instance:SetAutoPriviteVoice(new_state)
		end
		animator:SetBool("auto", new_state)
	end
end

function VoiceSettingView:RefeshSetting()
	for index = 1, SETTING_COUNT do
		local state = false
		local animator = nil
		local ani_state = false

		if index == SettingList.world then
			state = ChatData.Instance:GetAutoWorldVoice()
			animator = self.world_voice_animator
		elseif index == SettingList.team then
			state = ChatData.Instance:GetAutoTeamVoice()
			animator = self.team_voice_animator
		elseif index == SettingList.guild then
			state = ChatData.Instance:GetAutoGuildVoice()
			animator = self.guild_voice_animator
		elseif index == SettingList.privite then
			state = ChatData.Instance:GetAutoPriviteVoice()
			animator = self.privite_voice_animator
		end

		if animator then
			ani_state = animator:GetBool("auto")
		end

		if animator and state ~= ani_state then
			animator:SetBool("auto", state)
		end
	end
end

function VoiceSettingView:OpenCallBack()
	self:RefeshSetting()
end

function VoiceSettingView:CloseCallBack()

end