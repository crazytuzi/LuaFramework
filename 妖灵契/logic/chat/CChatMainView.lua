local CChatMainView = class("CChatMainView", CViewBase)
CChatMainView.g_LastChannel = nil
CChatMainView.g_LastInput = ""

function CChatMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/ChatMainView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_IsAlwaysShow = true
end

function CChatMainView.OnCreateView(self)
	self.m_ChatPart = self:NewUI(1, CChatScrollPart)
	self.m_ChannelGrid = self:NewUI(2, CGrid)
	self.m_Btns = {}
	self.m_BoxDic = {}
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_Contanier = self:NewUI(4, CWidget)
	self.m_ChannelBtnClone = self:NewUI(5, CBox)
	self.m_SetBtn = self:NewUI(6, CButton)
	self.m_PreView = nil
	self.m_ToggleTimer = nil

	self.m_Contanier.TweenPos = self.m_Contanier:GetComponent(classtype.TweenPosition)
	self:InitContent()
end

function CChatMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Contanier)
	self.m_ChannelBtnClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnToggleClose"))
	self.m_SetBtn:AddUIEvent("click", callback(self, "OnChatSet"))
	local list = self:GetOpenChannels()
	for i, tInfo in ipairs(list) do
		local oBox = self.m_ChannelBtnClone:Clone()
		oBox:SetActive(true)
		local text = define.Channel.Ch2Text[tInfo.send]
		oBox.m_Btn = oBox:NewUI(1, CButton)
		oBox.m_SelectLabel = oBox:NewUI(2, CLabel)
		oBox.m_SelectLabel:SetText(text)
		oBox.m_Btn:SetText(text)
		oBox.m_Btn:SetGroup(self.m_ChannelGrid:GetInstanceID())
		oBox.m_Btn.m_ExtraReceives = tInfo.extra_receives or {}
		oBox.m_Btn:SetClickSounPath(define.Audio.SoundPath.Tab)
		oBox.m_Btn:AddUIEvent("click", callback(self, "SwitchChannel", tInfo.send))
		self.m_Btns[tInfo.send] = oBox.m_Btn
		self.m_BoxDic[tInfo.send] = oBox
		self.m_ChannelGrid:AddChild(oBox)
	end
	
	-- if CChatMainView.g_LastChannel then
	-- 	self:SwitchChannel(CChatMainView.g_LastChannel)
	-- else
	-- 	self:SwitchChannel(define.Channel.World)
	-- end
	self:SwitchChannel(define.Channel.Common)
	--self:RefreshATRed()
	Utils.AddTimer(callback(self, "RefreshATRed"), 0, 0.2)
	self.m_ChatPart.m_Input:SetText(CChatMainView.g_LastInput)
	self.m_Contanier.TweenPos:Toggle()
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamPvpEvent"))
	self:CheckTeamPvp()
end

function CChatMainView.CheckTeamPvp(self)
	local bInTeamPvp = g_TeamPvpCtrl:IsInTeamPvpScene()
	if bInTeamPvp and self.m_CurChannel == define.Channel.Team then
		self:SwitchChannel(define.Channel.TeamPvp)
	elseif (not bInTeamPvp) and self.m_CurChannel == define.Channel.TeamPvp then
		self:SwitchChannel(define.Channel.Team)
	end
	self.m_BoxDic[define.Channel.Team]:SetActive(not bInTeamPvp)
	self.m_BoxDic[define.Channel.TeamPvp]:SetActive(bInTeamPvp)
	self.m_ChannelGrid:Reposition()
end


function CChatMainView.OnTeamPvpEvent(self, oCtrl)
	self:CheckTeamPvp()
end

function CChatMainView.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddATMsg then
		self:CheckATMsg(oCtrl.m_EventData)
	end
end

function CChatMainView.SwitchChannel(self, iChannel)
	if self.m_CurChannel ~= iChannel then
		self.m_CurChannel = iChannel
		local oBtn = self.m_Btns[iChannel]
		if not oBtn then
			iChannel = define.Channel.Sys
			oBtn = self.m_Btns[iChannel]
		end
		oBtn:SetSelected(true)
		self.m_ChatPart:SetExtraReceives(oBtn.m_ExtraReceives)
		self.m_CurChannel = iChannel
		
		local function f()
			if Utils.IsNil(self) then
				return
			end
			self.m_ChatPart:SetChannel(iChannel)
		end
		Utils.AddTimer(f, 0, 0.3)
	end
end

function CChatMainView.GetOpenChannels(self)
	local t = {
		{send=define.Channel.Common,},
		{send=define.Channel.World,},
		{send=define.Channel.Team},
		{send=define.Channel.TeamPvp},
		{send=define.Channel.Org},
		{send=define.Channel.Current},
		{send=define.Channel.Sys, 
		 extra_receives={
			define.Channel.Bulletin,
			define.Channel.Help,
			define.Channel.Message,}},
		{send=define.Channel.Rumour},
	}
	return t
end

function CChatMainView.CheckATMsg(self, oMsg)
	local iChannel = oMsg:GetValue("channel")
	if self.m_CurChannel ~= iChannel then
		local btn = self.m_Btns[iChannel]
		if btn then
			btn:AddEffect("RedDot")
		end
	end
end

function CChatMainView.RefreshATRed(self)
	local tMsgData = g_ChatCtrl:GetATMsgList()
	for iChannel, btn in pairs(self.m_Btns) do
		if self.m_CurChannel ~= iChannel then
			if tMsgData[iChannel] and tMsgData[iChannel][1] then
				btn:AddEffect("RedDot")
			end
		end
	end
end

function CChatMainView.SetQAnswerModel(self)
	self:SwitchChannel(define.Channel.World)
	self.m_ChatPart:DelQAEffect()
end

function CChatMainView.CloseView(self)
	if self.m_ChatPart then
		CChatMainView.g_LastInput = self.m_ChatPart.m_Input:GetText()
		self.m_ChatPart:OnSpeech(nil, false)
	end
	CChatMainView.g_LastChannel = self.m_CurChannel
	self:ResumePreviousView(true)
	CViewBase.CloseView(self)
end

function CChatMainView.SetPreviousView(self, oView)
	oView:SetActive(false)
	self.m_PreView = oView
end

function CChatMainView.ResumePreviousView(self)
	if self.m_PreView then
		self.m_PreView:SetActive(true)
	end
end

function CChatMainView.OnToggleClose(self)
	if self.m_ToggleTimer ~= nil then
		return
	end
	self.m_ToggleTimer = Utils.AddTimer(callback(self, "OnClose"), 0.1, 0.5)
	self.m_Contanier.TweenPos:Toggle()
end

function CChatMainView.ExtendCloseView(self)
	self:OnToggleClose()
end

function CChatMainView.OnChatSet(self)
	CChatFilterView:ShowView()
end

return CChatMainView