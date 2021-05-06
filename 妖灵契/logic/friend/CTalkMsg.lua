local CTalkMsg = class("CTalkMsg")

function CTalkMsg.ctor(self, id, sMsg)
	self.m_ID = id
	self.m_Msg = sMsg
end

function CTalkMsg.GetText(self)
	return self.m_Msg
end

function CTalkMsg.GetID(self)
	return self.m_ID
end

function CTalkMsg.GetRoleInfo(self, skey)
	if skey == "pid" then
		return self.m_ID
	end
end

function CTalkMsg.GetType(self)
	local sender = self.m_ID
	if sender and type(sender) == type(1) then
		if sender == g_AttrCtrl.pid then
			return define.Chat.MsgType.Self
		else
			return define.Chat.MsgType.Others
		end
	elseif sender == "time" then
		return define.Chat.MsgType.NoSender
	else
		return define.Chat.MsgType.NoSender
	end
end

function CTalkMsg.GetAudioLink(self)
	local dLink = LinkTools.FindLink(self:GetText(), "SpeechLink")
	return dLink
end

function CTalkMsg.GetChannelPrefixText(self)
	if self.m_ID == "time" then
		return self:GetTimeStr()
	else
		return self.m_Msg
	end
end

function CTalkMsg.GetTimeStr(self)
	local second = tonumber(self.m_Msg)
	if g_TimeCtrl:IsToday(second) then
		return os.date("%H:%M",second)
	else
		return os.date("%Y/%m/%d %H:%M:%S", second)
	end
end

function CTalkMsg.GetShape(self)
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	local shape = g_AttrCtrl.model_info.shape
	if frdobj and frdobj.shape then
		shape = frdobj.shape
	end
	return shape
end

function CTalkMsg.GetName(self)
	return ""
end

return CTalkMsg