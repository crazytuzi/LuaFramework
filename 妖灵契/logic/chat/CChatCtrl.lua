local CChatCtrl = class("CChatCtrl", CCtrlBase)

function CChatCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CChatCtrl.ResetCtrl(self)
	self.m_MsgObjs = {}
	self.m_ChannelMsgs = {}
	self.m_Filters = {}
	self.m_AudioFilters = {}
	self.m_IsLockRead = false
	self.m_HelpTips = {}
	self.m_RedPacket = {}
	self.m_ChannelATMsg = {}
	self.m_MainMenuChatBoxExpan = IOTools.GetClientData("mainmenu_chat_box_expand") or false
	self.m_NeedLimitMsg = {["team"] = true, ["org"] = true, ["teampvp"] = true,}
end

function CChatCtrl.AddMsg(self, dMsg)
	local iChannel = dMsg.channel
	
	if self:IsFilterText(dMsg) then
		return
	end
	
	if dMsg.role_info and g_FriendCtrl:IsBlackFriend(dMsg.role_info.pid) then
		return
	end
	
	self:ClearUp(iChannel)
	local lMsgs = self.m_ChannelMsgs[iChannel]
	if not lMsgs then
		lMsgs = {}
	end
	local id = #self.m_MsgObjs + 1
	local oMsg = CChatMsg.New(id, dMsg)
	table.insert(self.m_MsgObjs, oMsg)
	table.insert(lMsgs, id)
	self.m_ChannelMsgs[dMsg.channel] = lMsgs
	local isWar = g_WarCtrl:IsWar()
	
	local pid = oMsg:GetRoleInfo("pid")
	local oPlayer = nil
	if pid then
		if isWar then
			oPlayer = g_WarCtrl:FindWarrior(function(oWarrior)
				return oWarrior.m_Pid == pid
			end)
		else
			oPlayer = g_MapCtrl:GetPlayer(pid)
		end
	end

	if iChannel == define.Channel.World then
		if oMsg:GetType() == define.Chat.MsgType.Self then
			self.m_LastWorldChatTime = g_TimeCtrl:GetTimeS()
		end
	elseif iChannel == define.Channel.Current then
		if oPlayer then
			oPlayer:ChatMsg(oMsg)
		end
	
	elseif iChannel == define.Channel.Team then
		if oPlayer then
			oPlayer:ChatMsg(oMsg)
		end
	end
	self:RefreshATMsg(oMsg)
	self:RefrehRedPacketMsg(oMsg)
	self:OnEvent(define.Chat.Event.AddMsg, oMsg)
	local oSpeechLink = LinkTools.FindLink(dMsg.text, "SpeechLink")
	if oSpeechLink then
		if self:IsAudioFilter(iChannel) then
			g_SpeechCtrl:AddPlayWithKey(oSpeechLink.sKey)
		end
	end
end

function CChatCtrl.RefreshATMsg(self, oMsg)
	local sText = oMsg:GetText()
	local dLink = LinkTools.FindLink(sText, "ATPlayerLink")
	if dLink and dLink.pid == g_AttrCtrl.pid then
		local iChannel = oMsg:GetValue("channel")
		self.m_ChannelATMsg[iChannel] = self.m_ChannelATMsg[iChannel] or {}
		table.insert(self.m_ChannelATMsg[iChannel], oMsg)
		self:OnEvent(define.Chat.Event.AddATMsg, oMsg)
	end
end

function CChatCtrl.GetATMsgList(self)
	return self.m_ChannelATMsg
end

function CChatCtrl.ClearATChanel(self, iChannel)
	self.m_ChannelATMsg[iChannel] = {}
end

function CChatCtrl.ClearUp(self, iChannel)
	local newMsgObjs = {}
	local lChannels = self:GetReceiveChannels(iChannel)
	local iMax = 40
	local iAmount = 10
	local iCurAmount = 0
	for k, v in pairs(lChannels) do
		local n = 0
		if self.m_ChannelMsgs[v] then
			n = #self.m_ChannelMsgs[v]
		end
		iCurAmount = iCurAmount + n
	end
	if iCurAmount < iMax then
		return
	end
	local iDelAmount = 0
	for k, oMsg in ipairs(self.m_MsgObjs) do
		if iDelAmount >= iAmount or not table.index(lChannels, oMsg:GetValue("channel")) then
			table.insert(newMsgObjs, oMsg)
		else
			iDelAmount = iDelAmount + 1
			self:ClearATMsg(oMsg)
		end
	end

	self.m_MsgObjs = newMsgObjs
	self.m_ChannelMsgs = {}
	for i, oMsg in ipairs(self.m_MsgObjs) do
		local lMsgs = self.m_ChannelMsgs[oMsg:GetValue("channel")]
		if not lMsgs then
			lMsgs = {}
		end
		table.insert(lMsgs, i)
		self.m_ChannelMsgs[oMsg:GetValue("channel")] = lMsgs
	end
end

function CChatCtrl.ClearATMsg(self, oMsg)
	local iChannel = oMsg:GetValue("channel")
	if self.m_ChannelATMsg[iChannel] then
		local index = table.index(self.m_ChannelATMsg[iChannel], oMsg)
		if index then
			table.remove(self.m_ChannelATMsg[iChannel], index)
		end
	end
end

function CChatCtrl.GetReceiveChannels(self, iChannel)
	local t = {
		{define.Channel.Sys, define.Channel.Bulletin, define.Channel.Help, define.Channel.Rumour},
	}
	for k, lChannels in pairs(t) do
		if table.index(lChannels, iChannel) then
			return lChannels
		end
	end
	return {iChannel}
end

function CChatCtrl.SendMsg(self, sMsg, iChannel, extraargs)
	if not self:CheckSendLimit(sMsg, iChannel) then
		print("客户端限制发送", sMsg, iChannel)
		return false
	end
	if g_AttrCtrl:IsBanChat() then
		local dMsg = {
			channel = iChannel,
			text = sMsg,
			role_info = {
				grade = g_AttrCtrl.grade,
				name = g_AttrCtrl.name,
				pid = g_AttrCtrl.pid,
				shape = g_AttrCtrl.model_info.shape,
			},
		}
		Utils.AddTimer(function() g_ChatCtrl:AddMsg(dMsg) end, 0, 0)
	else
		netchat.C2GSChat(sMsg, iChannel, extraargs)
	end
	return true
end

function CChatCtrl.CheckSendLimit(self, sMsg, iChannel)
	if iChannel == define.Channel.World then

	end
	return true
end

function CChatCtrl.GetMsgList(self, iChannel, iStart)
	local list = {}
	local iStart = iStart or 0
	if self.m_ChannelMsgs[iChannel] then
		for i, id in ipairs(self.m_ChannelMsgs[iChannel]) do 
			if id > iStart then
				local oMsg = self.m_MsgObjs[id]
				oMsg["pos"] = id
				table.insert(list, oMsg)
			end
		end
	end
	return list
end

function CChatCtrl.AppendInputMsg(self, msg)
	local oView = CChatMainView:GetView()
	if oView then
		oView.m_ChatPart:AppendText(msg)
	end
end

function CChatCtrl.SetLockRead(self, b)
	self.m_IsLockRead = b
end

function CChatCtrl.IsFilterChannel(self, iChannel)
	-- local lSysChannel = {
	-- 	define.Channel.Bulletin,
	-- 	define.Channel.Help,
	-- 	define.Channel.Rumour,
	-- 	define.Channel.Message,
	-- }
	-- if table.index(lSysChannel, iChannel) then
	-- 	iChannel = define.Channel.Sys
	-- end
	return self.m_Filters[iChannel]
end

function CChatCtrl.InitAudioFilter(self)
	self:InitHistory()
	local lChannels = IOTools.GetRoleData("audio_autoplay_channel") or {}
	self:RefreshAudioChannel(lChannels)
	lChannels = IOTools.GetRoleData("common_channel") or {1, 2, 3, 4, 103}
	self:RefreshCommChannel(lChannels)
end

function CChatCtrl.RefreshFilterChannel(self, lChannels)
	self.m_Filters = {}
	for i, channel in ipairs(lChannels) do
		self.m_Filters[channel] = true
	end
end

function CChatCtrl.IsAudioFilter(self, iChannel)
	return self.m_AudioFilters[iChannel]
end

function CChatCtrl.RefreshAudioChannel(self, lChannels)
	self.m_AudioFilters = {}
	for i, channel in ipairs(lChannels) do
		self.m_AudioFilters[channel] = true
	end
	IOTools.SetRoleData("audio_autoplay_channel", lChannels)
end

function CChatCtrl.SetAudioChannel(self, iChannel, bSet)
	local lChannels = IOTools.GetRoleData("audio_autoplay_channel") or {}
	local index = table.index(lChannels, iChannel)
	if bSet then
		if not index then
			table.insert(lChannels, iChannel)
		end
	else
		if index then
			table.remove(lChannels, index)
		end
	end
	self.m_AudioFilters[iChannel] = bSet
	IOTools.SetRoleData("audio_autoplay_channel", lChannels)
end

function CChatCtrl.IsCommFilter(self, iChannel)
	return self.m_CommFilters[iChannel]
end

function CChatCtrl.RefreshCommChannel(self, lChannels)
	self.m_CommFilters = {}
	for i, channel in ipairs(lChannels) do
		self.m_CommFilters[channel] = true
	end
	IOTools.SetRoleData("common_channel", lChannels)
end

function CChatCtrl.GetCommRecevieChannel(self)
	local list = table.keys(self.m_CommFilters)
	if table.index(list, define.Channel.Sys) then
		table.extend(list, {101, 102})
	end
	return list
end

function CChatCtrl.IsTeamBullet(self)
	return g_TeamCtrl.m_TeamSet.AutoChatScreen
end

function CChatCtrl.StartHelpTip(self)
	self.m_HelpTimer = Utils.AddTimer(callback(self, "SendHelpTip"), 120, 0)
end

function CChatCtrl.SendHelpTip(self)
	if #self.m_HelpTips == 0 then
		local tips = table.copy(data.chatdata.HELP)
		self.m_HelpTips = table.shuffle(tips)
	end
	local tip = self.m_HelpTips[1]
	table.remove(self.m_HelpTips, 1)
	local dMsg = {
		channel = define.Channel.Help,
		text = tip,
	}
	g_ChatCtrl:AddMsg(dMsg)
	return true
end

function CChatCtrl.SendLimitMsg(self, iChannel)
	if iChannel == define.Channel.Team then
		if self.m_NeedLimitMsg["team"] and not g_TeamCtrl:IsJoinTeam() then
			local dMsg = {channel = iChannel,
			text = "请先创建或加入队伍！"..LinkTools.GenerateCreateTeamLink()}
			g_ChatCtrl:AddMsg(dMsg)
			self.m_NeedLimitMsg["team"] = false
		end
	elseif iChannel == define.Channel.TeamPvp then
		if self.m_NeedLimitMsg["teampvp"] and g_TeamPvpCtrl:GetMemberSize() <= 1 then
			local dMsg = {channel = iChannel,
			text = "请先创建或加入队伍！"}
			g_ChatCtrl:AddMsg(dMsg)
			self.m_NeedLimitMsg["teampvp"] = false
		end
	elseif iChannel == define.Channel.Org then
		if self.m_NeedLimitMsg["org"] and g_AttrCtrl.org_id == 0 then
			local dMsg = {channel = iChannel,
			text = "请先创建或加入公会！"..LinkTools.GenerateJoinOrgLink("加入公会")
		}
			g_ChatCtrl:AddMsg(dMsg)
			self.m_NeedLimitMsg["org"] = false
		end
	end
end

function CChatCtrl.SetSendLimitMsg(self, sType, b)
	self.m_NeedLimitMsg[sType] = b
end

function CChatCtrl.IsFilterText(self, dMsg)
	local str = dMsg.text
	local dLink = LinkTools.FindLink(str, "NilLink")
	
	if not dLink then
		return false
	end
	local iType = tonumber(dLink["iType"])
	if iType == 1 then
		return self:DoGradeFilter(dLink["sText"])
	elseif iType == 2 then
		return self:DoGradeAreaFilter(dLink["sText"])
	elseif iType == 3 then
		if dMsg.role_info and dMsg.role_info.pid ~= g_AttrCtrl.pid then
			return true
		else
			return false
		end
	end
end

function CChatCtrl.DoGradeFilter(self, text)
	local t = string.split(text, "#")
	if #t > 0 then
		local grade = tonumber(t[1])
		if grade and g_AttrCtrl.grade < grade then
			return true
		end
	end
	return false
end

function CChatCtrl.DoGradeAreaFilter(self, text)
	local t = string.split(text, "#")
	if #t > 1 then
		local iLow = tonumber(t[1])
		local iHight = tonumber(t[2])
		if iLow and iHight and (g_AttrCtrl.grade < iLow or g_AttrCtrl.grade > iHight) then
			return true
		end
	end
	return false
end

function CChatCtrl.IsLegalMsg(self, s)
	local ss = ""  
	for k = 1, #s do  
		local c = string.byte(s,k)  
		if not c then
			break
		end  
		if (c > 128 and c < 256) then
			return false
		elseif c>=228 and c<=233 then  
			local c1 = string.byte(s,k+1)  
			local c2 = string.byte(s,k+2)  
			if c1 and c2 then  
				local a1,a2,a3,a4 = 128,191,128,191  
				if c == 228 then a1 = 184  
				elseif c == 233 then 
					a2,a4 = 190,c1 ~= 190 and 191 or 165  
				end  
				if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then  
					k = k + 2  
					ss = ss..string.char(c,c1,c2)
				else
					return false
				end
			end
		end
	end
	return true
end

function CChatCtrl.SaveHistory(self, sMsg)
	if self.m_HistoryList[1] == sMsg then
		return
	else
		table.insert(self.m_HistoryList, 1, sMsg)
	end
	IOTools.SetRoleData("chat_history", self.m_HistoryList)
end

function CChatCtrl.InitHistory(self)
	self.m_HistoryList = IOTools.GetRoleData("chat_history") or {}
end

function CChatCtrl.GetHistory(self)
	return self.m_HistoryList or {}
end

--聊天红包相关
function CChatCtrl.ClickRedPacket(self, hid)
	if table.index(self.m_RedPacket, hid) then
		netchat.C2GSHongBaoOption("look", hid)
	else
		netchat.C2GSHongBaoOption("draw", hid)
	end
end


function CChatCtrl.RefrehRedPacketMsg(self, oMsg)
	local sText = oMsg:GetText()
	local dLink = LinkTools.FindLink(sText, "RedPacketLink")
	if dLink then
		CMainMenuRedPackedView:ShowView(function (oView)
			oView:AddRedData("person", {dLink.id, dLink.sid})
		end)
	end
end

return CChatCtrl