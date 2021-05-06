local CChatMsg = class("CChatMsg")

function CChatMsg.ctor(self, id, dMsg)
	self.m_Data = dMsg
	self.m_ID = id
end

function CChatMsg.GetText(self)
	return self:GetValue("text")
end

function CChatMsg.IsHorseRace(self)
	return self:GetValue("horse_race") == 1
end

function CChatMsg.GetType(self)
	local sender = self:GetRoleInfo("pid")
	if sender then
		if sender == g_AttrCtrl.pid then
			return define.Chat.MsgType.Self
		else
			return define.Chat.MsgType.Others
		end
	else
		return define.Chat.MsgType.NoSender
	end
end

function CChatMsg.GetAudioLink(self)
	local dLink = LinkTools.FindLink(self:GetValue("text"), "SpeechLink")
	return dLink
end

function CChatMsg.IsAtMsg(self)
	return self.m_IsAtMsg
end



function CChatMsg.IsPlayerChat(self)
	local pid = self:GetRoleInfo("pid")
	return pid and pid~=0
end

function CChatMsg.GetValue(self, k)
	return self.m_Data[k]
end

function CChatMsg.GetRoleInfo(self, k)
	local dInfo = self.m_Data["role_info"]
	if dInfo then
		return dInfo[k]
	end
end

function CChatMsg.GetName(self)
	return self:GetRoleInfo("name")
end

function CChatMsg.GetShape(self)
	return self:GetRoleInfo("shape")
end

function CChatMsg.GetChannelPrefixText(self)
	local text = self:GetValue("text")
	local channel = self:GetValue("channel")
	-- if data.colordata.CHAT[channel] then
	-- 	local color = {text = "683F1D", name = "25C8FD"}
	-- 	if color then
	-- 		text = string.format("[%s]%s[-]", color.text, text)
	-- 	end
	-- end
	
	if table.index({define.Channel.Team, define.Channel.TeamPvp, define.Channel.Current, define.Channel.Org}, channel) and self:IsPlayerChat() then
		return text
	end
	if channel == define.Channel.World and self:IsPlayerChat() then
		return text
	end
	text = string.replace(text, "#W", "[656565]")
	return string.format("#ch<%d>[683F1D]%s[-]", channel, text)
end

function CChatMsg.GetMainMenuText(self, bHideChannel)
	local name = self:GetRoleInfo("name")
	local text = self:GetValue("text")
	local channel = self:GetValue("channel")
	if data.colordata.CHAT[channel] then
		local color = data.colordata.CHAT[channel]["mainmenu"]
		if color then
			if name then
				name = string.format("[%s]%s[-]", color.name, name)
			end
			text = string.format("[%s]%s[-]", color.text, text)
		end
	end
	local sChannel = ""
	if not bHideChannel then
		sChannel = string.format("#ch<%d>", channel)
	end
	local str = ""
	if name then
		str = string.format("%s[%s]%s", sChannel, name, text)
	else
		str = string.format("%s%s", sChannel, text)
	end
	return str
end

function CChatMsg.GetBulletScreenText(self)
	local name = self:GetRoleInfo("name")
	local text = self:GetValue("text")
	if self:IsPlayerChat() and self:GetRoleInfo("pid") ~= g_AttrCtrl.pid then
		return string.format("#B%s：#n%s", name, text)
	else
		return text
	end
end

return CChatMsg