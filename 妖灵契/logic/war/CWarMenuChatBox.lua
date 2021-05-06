local CWarMenuChatBox = class("CWarMenuChatBox", CBox)

function CWarMenuChatBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgTable = self:NewUI(1, CTable)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_SizeBtn = self:NewUI(4, CButton)
	self.m_FilterBtn = self:NewUI(5, CButton)
	self.m_Bg = self:NewUI(6, CSprite)
	self.m_AudioBox = self:NewUI(7, CBox)
	self.m_ChatTable = self:NewUI(8, CTable)
	self.m_ChatPanel = self:NewUI(9, CScrollView)
	self.m_FriendBtn = self:NewUI(10, CButton)
	self.m_MsgLabel = self:NewUI(11, CLabel)
	self.m_MsgList = {}
	self.m_AddCnt = 10
	self.m_CurAppendIdx = 0
	self.m_IsExpand = IOTools.GetClientData("mainmenu_chat_box_expand") or false
	g_ChatCtrl.m_MainMenuChatBoxExpan = self.m_IsExpand
	self:InitContent()
end

function CWarMenuChatBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_ScrollView:SetCullContent(self.m_MsgTable)
	self.m_ChatPanel:SetCullContent(self.m_MsgTable)
	--self.m_ScrollView:AddMoveCheck("upmove", self.m_ChatTable, callback(self, "OnExpand"))
	--self.m_ScrollView:AddMoveCheck("downmove", self.m_ChatTable, callback(self, "OnPull"))

	self.m_Bg:AddUIEvent("click", callback(self, "OnOpenMainView", define.Channel.Common))
	self.m_SizeBtn:AddUIEvent("click", callback(self, "OnResize"))
	self.m_FilterBtn:AddUIEvent("click", callback(self, "OnFilter"))
	self.m_FriendBtn:AddUIEvent("click", callback(self, "OpenFriendInfoView"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))

	self:InitAudioBox()
	self:RefreshAllMsg()
	self:CheckOpenGrade()
	self:UpdateMsgAmount()
end

function CWarMenuChatBox.InitAudioBox(self)
	local audiobox = self.m_AudioBox
	audiobox.m_FirstBtn = audiobox:NewUI(1, CButton)
	audiobox.m_AudioBtns = {}
	
	self.m_IsExpandAudio = false
	self.m_AudioList = {define.Channel.Current, define.Channel.Team, define.Channel.Org, define.Channel.World}
	for i, key in ipairs(self.m_AudioList) do
		audiobox.m_AudioBtns[key] = audiobox:NewUI(i+1, CButton)
		audiobox.m_AudioBtns[key]:AddUIEvent("click", callback(self, "OnClickAudio", key))
		audiobox.m_AudioBtns[key]:AddUIEvent("longpress", callback(self, "OnSpeech", key))
	end
	audiobox.m_Bg = audiobox:NewUI(6, CSprite)
	audiobox.m_ExpandBtn = audiobox:NewUI(7, CButton)
	audiobox.m_AudioPart = audiobox:NewUI(8, CBox)
	audiobox.m_HousePart = audiobox:NewUI(9, CBox)

	audiobox.m_ExpandBtn:AddUIEvent("click", callback(self, "OnExpandAudio"))
	self:OnResortAudio(true)
end

function CWarMenuChatBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		local list = self:GetDisplayChannel()
		if table.index(list, oMsg:GetValue("channel")) then
			if g_ChatCtrl:IsFilterChannel(oMsg:GetValue("channel")) then
				print("已屏蔽该频道"..tostring(oMsg:GetValue("channel")))
				return
			end
			table.insert(self.m_MsgList, oMsg)
			self:AddMsg(oMsg)
		end
	
	elseif oCtrl.m_EventID == define.Chat.Event.PlayAudio then
		self:RefreshText()
	
	elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
		self:RefreshText()
	end
end

function CWarMenuChatBox.AddMsg(self, oMsg, bAppend)
	bAppend = not bAppend
	local iChannel = oMsg:GetValue("channel")
	local oMsgBox = self:NewMsgBox(oMsg)
	oMsgBox.m_Label:AddUIEvent("click", callback(self, "OnOpenMainView", define.Channel.Common))
	local w, h = oMsgBox:GetSize()
	local _, lh = oMsgBox.m_Label:GetSize()
	oMsgBox:SetSize(w, math.max((lh-22+h), h))
	self.m_MsgTable:AddChild(oMsgBox)
	if not bAppend then
		oMsgBox:SetAsFirstSibling()
	end
	local iCount = self.m_MsgTable:GetCount()
	if bAppend and iCount > self.m_AddCnt then
		local oChild = self.m_MsgTable:GetChild(1)
		self.m_MsgTable:RemoveChild(oChild)
	end

	self.m_MsgTable:Reposition()
	self.m_ChatPanel:CullContentLater()
	self.m_ChatPanel:ResetPosition()
	self:CheckBoxCollider()
end

function CWarMenuChatBox.SetActive(self, bAct)
	if bAct then
		self.m_MsgTable:Reposition()
		self.m_ChatPanel:CullContentLater()
		self.m_ChatPanel:ResetPosition()
		self:CheckBoxCollider()		
	end
	CBox.SetActive(self, bAct)
end

function CWarMenuChatBox.RefreshAllMsg(self)
	if Utils.IsNil(self) then
		return
	end
	self.m_MsgTable:Clear()
	self.m_CurAppendIdx = 0
	self.m_MsgList = {}
	for i, ch in ipairs(self:GetDisplayChannel()) do
		local subList = g_ChatCtrl:GetMsgList(ch)
		for i, oMsg in ipairs(subList) do
			table.insert(self.m_MsgList, oMsg)
		end
	end
	table.sort(self.m_MsgList, function(a, b) return a["pos"] < b["pos"] end)
	local len = #self.m_MsgList
	for i=len, len-self.m_AddCnt, -1 do
		local oMsg = self.m_MsgList[i]
		if oMsg then
			self:AddMsg(oMsg, true)
			self.m_CurAppendIdx = i
		else
			break
		end
	end
	self.m_MsgTable:Reposition()
	self:CheckBoxCollider()
	self.m_ScrollView:ResetPosition()
end

function CWarMenuChatBox.ReloadMsg(self)
	self.m_MsgTable:Clear()
	self.m_CurAppendIdx = 0
	local len = #self.m_MsgList
	for i=len, len-self.m_AddCnt, -1 do
		local oMsg = self.m_MsgList[i]
		if oMsg then
			self:AddMsg(oMsg, true)
			self.m_CurAppendIdx = i
		else
			break
		end
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:ResetPosition()
	self:CheckBoxCollider()
end

function CWarMenuChatBox.ShowOldMsg(self)
	local oOldMsg = self.m_MsgList[self.m_CurAppendIdx - 1]
	if oOldMsg then
		self:AddMsg(oOldMsg, true)
		self.m_CurAppendIdx = self.m_CurAppendIdx - 1
	end
end

function CWarMenuChatBox.NewMsgBox(self, oMsg)
	local oBox = self.m_BoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_Label = oBox:NewUI(1, CLabel)
	oBox.m_Label:SetRichText(oMsg:GetMainMenuText(), true)
	return oBox
end

function CWarMenuChatBox.RefreshText(self)
	for o, oBox in ipairs(self.m_MsgTable:GetChildList()) do
		local sText = oBox.m_Label:GetRawText()
		LinkTools.ClearLinkCache(sText)
		oBox.m_Label:SetRichText(sText, true)
	end
end

function CWarMenuChatBox.OnOpenMainView(self, iChannel)
	CChatMainView:ShowView(function(oView)
		oView:SwitchChannel(iChannel)
	end)
end

function CWarMenuChatBox.CheckBoxCollider(self)
	for _, oWidget in ipairs(self.m_MsgTable:GetChildList()) do
		local bounds = oWidget:CalculateBounds(self.m_ChatPanel.m_Transform)
		local w, h = oWidget:GetSize()
		local v = self.m_ChatPanel.m_UIPanel:CalculateConstrainOffset(bounds.min, bounds.max)
		local cnt =  self.m_ChatPanel.m_PreCnt
		if v.x < -cnt*w or v.x > cnt*w or v.y < - cnt*h or v.y > cnt*h then
			--active false
		else
			if v.y < -20 and h + v.y > 0 then
				local ow, oh = oWidget.m_Label:GetSize()
				local collider = oWidget.m_Label:GetComponent(classtype.BoxCollider)
				local delh = -v.y
				collider.size = Vector3.New(ow, math.max(0, oh-delh), 0)
				collider.center = Vector3.New(ow/2, (delh-oh)/2-delh+7, 0)
			end
		end
	end
end

function CWarMenuChatBox.GetDisplayChannel(self)
	local list = {
		define.Channel.World,
		define.Channel.Team,
		define.Channel.TeamPvp,
		define.Channel.Current,
		define.Channel.Org,
		define.Channel.Bulletin,
		define.Channel.Help,
		define.Channel.Rumour,
	}
	return list
end

function CWarMenuChatBox.OnResize(self)	
	if self.m_IsLock then
		return
	end
	self.m_IsExpand = not self.m_IsExpand
	IOTools.SetClientData("mainmenu_chat_box_expand",self.m_IsExpand)
	self:RefreshSize()	
	g_ChatCtrl.m_MainMenuChatBoxExpan = self.m_IsExpand
	g_ChatCtrl:OnEvent(define.Chat.Event.ChatBoxExpan)
end

function CWarMenuChatBox.OnExpand(self)
	if self.m_IsExpand or self.m_IsLock then
		return
	end
	self.m_IsExpand = true
	IOTools.SetClientData("mainmenu_chat_box_expand",self.m_IsExpand)
	self:RefreshSize()
	g_ChatCtrl.m_MainMenuChatBoxExpan = self.m_IsExpand
	g_ChatCtrl:OnEvent(define.Chat.Event.ChatBoxExpan)
end

function CWarMenuChatBox.OnPull(self)
	if not self.m_IsExpand or self.m_IsLock then
		return
	end
	self.m_IsExpand = false
	IOTools.SetClientData("mainmenu_chat_box_expand",self.m_IsExpand)
	self:RefreshSize()
	g_ChatCtrl.m_MainMenuChatBoxExpan = self.m_IsExpand
	g_ChatCtrl:OnEvent(define.Chat.Event.ChatBoxExpan)	
end

function CWarMenuChatBox.RefreshSize(self, nottask)
	self.m_IsLock = true
	local w, _ = self:GetSize()
	local height = self.m_IsExpand and 275 or 90
	self:SetHeight(height)
	local clipH = height - 5
	self.m_ScrollView:SetBaseClipRegion(Vector4.New(w/2, clipH/2, w, clipH))
	self.m_ChatPanel:SetBaseClipRegion(Vector4.New(w/2, clipH/2, w, clipH))
	local flip = self.m_IsExpand and enum.UISprite.Flip.Vertically or enum.UISprite.Flip.Nothing
	self.m_MsgTable:UpdateAnchors()
	self.m_SizeBtn:SetFlip(flip)
	self:SimulateOnEnable()
	self.m_ScrollView:ClipMove()
	self:ReloadMsg()
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_ScrollView:RefreshBounds()
		self.m_IsLock = false
	end
	
	if self.m_ScrollViewTimer then
		Utils.DelTimer(self.m_ScrollViewTimer)
	end
	self.m_ScrollViewTimer = Utils.AddTimer(update, 0, 1)
	
end

function CWarMenuChatBox.OnFilter(self)
	CChatFilterView:ShowView()
end

function CWarMenuChatBox.OnSpeech(self, iChannel, oBtn, bPress)
	local tempChannel = iChannel
	if g_TeamPvpCtrl:IsInTeamPvpScene() and iChannel == define.Channel.Team then
		tempChannel = define.Channel.TeamPvp
	end
	if bPress then
		if not self:CheckSendLimit(tempChannel) then
			return
		end
		self:RecordTimeOut(tempChannel)
		CSpeechRecordView:ShowView(function(oView) 
				oView:SetRecordBtn()
				oView:BeginRecord()
			end)
	else
		local oView = CSpeechRecordView:GetView()
		if oView then
			oView:EndRecord(tempChannel)
			local index = table.index(self.m_AudioList, tempChannel)
			if index then
				table.remove(self.m_AudioList, index)
				table.insert(self.m_AudioList, 1, tempChannel)
			end
			self:OnResortAudio(self.m_IsExpandAudio)
		end
	end
end

function CWarMenuChatBox.RecordTimeOut(self, iChannel)
	self.m_StartTime = g_TimeCtrl:GetTimeS()
	if self.m_ForceTimer then
		Utils.DelTimer(self.m_ForceTimer)
	end
	local function forceend()
		if Utils.IsNil(self) then
			return
		end
		if g_TimeCtrl:GetTimeS() - self.m_StartTime > g_SpeechCtrl:GetMaxTime() then
			g_NotifyCtrl:FloatMsg("语音已发送，最长可录制30秒")
			self:OnSpeech(iChannel, nil, false)
			return false
		end
		return true
	end
	self.m_ForceTimer = Utils.AddTimer(forceend, 0.5, 0)
end

function CWarMenuChatBox.CheckSendLimit(self, iChannel)
	return true
end

function CWarMenuChatBox.OnClickAudio(self, iChannel)
	local index = table.index(self.m_AudioList, iChannel)
	if index then
		table.remove(self.m_AudioList, index)
		table.insert(self.m_AudioList, 1, iChannel)
	end
	if self.m_IsExpandAudio then
		self:OnResortAudio(true)
		self.m_IsExpandAudio = false
	end
end

function CWarMenuChatBox.OnExpandAudio(self)
	self.m_IsExpandAudio = not self.m_IsExpandAudio 
	self:OnResortAudio(not self.m_IsExpandAudio)
end

function CWarMenuChatBox.OnResortAudio(self, ishide)
	local v = self.m_AudioBox.m_FirstBtn:GetLocalPos()
	local idx = 1
	for i, key in ipairs(self.m_AudioList) do
		if self:IsShowChannelAudio(key) then
			if ishide and idx ~= 1 then
				self.m_AudioBox.m_AudioBtns[key]:SetActive(false)
			else
				self.m_AudioBox.m_AudioBtns[key]:SetActive(true)
				self.m_AudioBox.m_AudioBtns[key]:SetLocalPos(Vector3.New(v.x+(idx-1)*60, v.y, v.z))
				if idx == 1 then
					v.x = v.x + 60
				end
				idx = idx + 1
			end
		else
			self.m_AudioBox.m_AudioBtns[key]:SetActive(false)
		end
	end

	--self.m_AudioBox.m_ExpandBtn:SetActive(ishide)
	if ishide then
		self.m_AudioBox.m_Bg:SetActive(false)
		self.m_IsExpandAudio = false
	else
		self.m_AudioBox.m_Bg:SetActive(true)
		self.m_AudioBox.m_Bg:SetSize(60*idx-50, 77)
	end
	if self.m_AutoExpandTimer then
		Utils.DelTimer(self.m_AutoExpandTimer)
	end
	
	if not ishide then
		self.m_AutoExpandTimer = Utils.AddTimer(callback(self, "OnResortAudio", true), 0, 3)
	end
end

function CWarMenuChatBox.IsShowChannelAudio(self, iChannel)
	if iChannel == define.Channel.Team then
		if g_TeamPvpCtrl:IsInTeamPvpScene() then
			return true
		else
			return g_TeamCtrl:IsJoinTeam()
		end
	elseif iChannel == define.Channel.Org then
		return g_AttrCtrl.org_id ~= 0
	end
	return true
end

function CWarMenuChatBox.CheckOpenGrade(self)
	self.m_FriendBtn:SetActive(g_FriendCtrl:IsOpen())	
end

function CWarMenuChatBox.OpenFriendInfoView(self)
	CFriendMainView:ShowView()
end

function CWarMenuChatBox.OnTalkEvent(self, oCtrl)
	self:DelayCall(0, "UpdateMsgAmount", "talk")
end

function CWarMenuChatBox.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateApply then
		self:DelayCall(0, "UpdateMsgAmount", "apply")
	end 
end

function CWarMenuChatBox.OnMailEvent(self, oCtrl)
	self:DelayCall(0, "UpdateMsgAmount", "mail")
end

function CWarMenuChatBox.UpdateMsgAmount(self, sType)
	local function getStr(str)
		if str == "talk" then
			return "你有新的消息"
		elseif str == "mail" then
			return "你有新的邮件"
		elseif str == "apply" then
			return "你有新的请求"
		end
		return ""
	end
	local dAmount = {}
	dAmount["talk"] = g_TalkCtrl:GetTotalNotify()
	dAmount["apply"] = g_FriendCtrl:GetApplyAmount()
	dAmount["mail"] = g_MailCtrl:GetUnOpenMailAmount()
	if dAmount["talk"] + dAmount["apply"] + dAmount["mail"] > 0 then
		self.m_MsgLabel:SetActive(true)
		if sType and dAmount[sType] > 0 then
			self.m_MsgLabel:SetText(getStr(sType))
		else
			for _, key in ipairs({"talk", "mail", "apply"}) do
				if dAmount[key] and dAmount[key] > 0 then
					self.m_MsgLabel:SetText(getStr(key))
					break
				end
			end
		end
	else
		self.m_MsgLabel:SetActive(false)
	end
end

return CWarMenuChatBox
