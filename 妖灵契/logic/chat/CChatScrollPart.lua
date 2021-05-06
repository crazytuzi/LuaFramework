local CChatScrollPart = class("CChatScrollPart", CBox)

function CChatScrollPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Input = self:NewUI(1, CChatInput)
	self.m_MsgTable = self:NewUI(2, CTable)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_MsgBoxRight = self:NewUI(4, CChatMsgBox)
	self.m_MsgBoxLeft = self:NewUI(5, CChatMsgBox)
	self.m_SubmitBtn = self:NewUI(6, CButton)
	self.m_EmojiBtn = self:NewUI(7, CButton)
	self.m_UnReadBox = self:NewUI(8, CBox)
	self.m_LockBg = self:NewUI(9, CWidget)
	self.m_UnLockSpr = self:NewUI(10, CSprite)
	self.m_LockSpr = self:NewUI(11, CSprite)
	self.m_MsgBoxSys = self:NewUI(12, CChatSysMsgBox)
	self.m_ATSprite = self:NewUI(13, CSprite)
	self.m_SpeechBtn = self:NewUI(14, CButton)
	self.m_AudioSetBox = self:NewUI(15, CBox)
	self.m_AudioBoxLeft = self:NewUI(16, CChatAudioBox)
	self.m_AudioBoxRight = self:NewUI(17, CChatAudioBox)
	self.m_SpeechPressBtn = self:NewUI(18, CButton)
	self.m_InputBtn = self:NewUI(19, CButton)
	self.m_QABtn = self:NewUI(20, CButton)
	self.m_NoInputTip = self:NewUI(21, CLabel)
	self.m_CommonPart = self:NewUI(22, CBox)
	self.m_CurChannel = nil
	self.m_IsLockRead = false
	self.m_LastReadIndex = 0
	self.m_UnReadCnt = 0
	self.m_AddCnt = 20
	self.m_MsgCnt = 100
	self.m_CurAppendIdx = 0
	self.m_ExtraReceives = {}
	self.m_MsgList = {}
	self.m_Input:SetForbidChars({"{","}"})
	self:InitContent()
end

function CChatScrollPart.InitContent(self)
	self.m_UnReadBox:SetActive(false)
	self.m_MsgBoxLeft:SetActive(false)
	self.m_MsgBoxRight:SetActive(false)
	self.m_MsgBoxSys:SetActive(false)
	self.m_AudioBoxRight:SetActive(false)
	self.m_AudioBoxLeft:SetActive(false)
	self.m_QABtn:SetActive(false)
	self:InitCommPart()
	self.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_SpeechBtn:AddUIEvent("press", callback(self, "ShowSpeech"))
	self.m_SpeechPressBtn:AddUIEvent("longpress", callback(self, "OnSpeech"))
	self.m_InputBtn:AddUIEvent("click", callback(self, "ShowInput"))
	self.m_ATSprite:AddUIEvent("click", callback(self, "OnClickAT"))
	-- g_UITouchCtrl:AddDragObject(self.m_SpeechBtn, {start_delta={x=100,y=0},})
	self.m_LockBg:AddUIEvent("click", callback(self, "SwitchLock"))
	self.m_ScrollView:SetCullContent(self.m_MsgTable)
	self.m_ScrollView:AddMoveCheck("up", self.m_MsgTable, callback(self, "ShowOldMsg"))
	self.m_ScrollView:AddMoveCheck("down", self.m_MsgTable, callback(self, "ShowNewMsg"))
	self.m_ScrollView:AddUIEvent("scrolldragfinished", callback(self, "SetLock"))
	
	self.m_UnReadBox:AddUIEvent("click", callback(self, "ReadAll"))
	self.m_UnReadBox.m_Label = self.m_UnReadBox:NewUI(1, CLabel)
	self.m_UnReadBox.m_ArrowSpr = self.m_UnReadBox:NewUI(2, CSprite)
	
	self.m_QABtn:AddUIEvent("click", callback(self, "OnShowQAView"))
	self.m_AudioSetBox.m_Label = self.m_AudioSetBox:NewUI(1, CLabel)
	self.m_AudioSetBox.m_Btn = self.m_AudioSetBox:NewUI(2, CSprite)
	self.m_AudioSetBox.m_Btn:AddUIEvent("click", callback(self, "SetAutoAudio"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	local QACtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	QACtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))

	self:ShowInput()
	self:UpdateQuestion()
	self:RefreshLock()
end

function CChatScrollPart.InitCommPart(self)
	self.m_CommChanelBtn = self.m_CommonPart:NewUI(1, CButton)
	self.m_CommSelPart = self.m_CommonPart:NewUI(2, CObject)
	self.m_CommSelGrid = self.m_CommonPart:NewUI(3, CGrid)
	self.m_CommGridBG = self.m_CommonPart:NewUI(4, CSprite)
	self.m_CommSelBtnList = {}
	self.m_CommSelGrid:InitChild(function (obj, idx)
		local oBtn = CLabel.New(obj)
		oBtn:AddUIEvent("click", callback(self, "OnSwitchCommChannel"))
		table.insert(self.m_CommSelBtnList, oBtn)
	end)
	self.m_CommSelPart:SetActive(false)
	self.m_CommChanelBtn:AddUIEvent("click", callback(self, "OnSwitchCommSelPart"))
	g_UITouchCtrl:TouchOutDetect(self.m_CommonPart, callback(self, "OnCloseCommSelPart"))
end

function CChatScrollPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		local iChannel = oMsg:GetValue("channel")
		local lReceives = self:GetReceiveChannels()
		if oMsg:GetType() == define.Chat.MsgType.Self then
			self:ClearInputText(oMsg:GetText())
		end
		if not table.index(lReceives, iChannel) then
			return
		end
		
		table.insert(self.m_MsgList, oMsg)
		if self.m_IsLockRead then
			self:SetUnReadCnt(self.m_LockCnt + 1)
		else
			self:AddMsg(oMsg)
		end

	elseif oCtrl.m_EventID == define.Chat.Event.AddATMsg then
		self:CheckATMsg(oCtrl.m_EventData)
	end
end

function CChatScrollPart.OnTeamCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or oCtrl.m_EventID == define.Team.Event.DelTeam then
		self:RefreshTeamChannel()
	end
end

function CChatScrollPart.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshOrgChannel()
	end
end

function CChatScrollPart.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.QAState then
		self:UpdateQuestion(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Activity.Event.QAAdd then
		self:UpdateQuestion(oCtrl.m_EventData)
	end	
end

function CChatScrollPart.CloseTimer(self)
	if self.m_FocusTimer then
		Utils.DelTimer(self.m_FocusTimer)
		self.m_FocusTimer = nil
	end
end

function CChatScrollPart.RefreshFocus(self)
	if not self.m_Input:IsFocus() then
		self.m_Input:SetFocus()
	end
	return true
end

function CChatScrollPart.GetReceiveChannels(self)
	if self.m_CurChannel == define.Channel.Common then
		return g_ChatCtrl:GetCommRecevieChannel()
	else
		return table.extend({self.m_CurChannel}, self.m_ExtraReceives)
	end
end

function CChatScrollPart.SetExtraReceives(self, channels)
	self.m_ExtraReceives = channels
end

function CChatScrollPart.AddMsg(self, oMsg, bAppend)
	--bappend为true 为上面添加， false则下面添加
	bAppend = not bAppend
	local iType = oMsg:GetType()
	local oMsgBox = nil
	local audioLink = oMsg:GetAudioLink()
	if iType == define.Chat.MsgType.NoSender then
		oMsgBox = self.m_MsgBoxSys:Clone()
	
	elseif iType == define.Chat.MsgType.Self then
		if audioLink then
			oMsgBox = self.m_AudioBoxRight:Clone()
		else
			oMsgBox = self.m_MsgBoxRight:Clone()
		end
	
	elseif iType == define.Chat.MsgType.Others then
		if audioLink then
			oMsgBox = self.m_AudioBoxLeft:Clone()
		else
			oMsgBox = self.m_MsgBoxLeft:Clone()
		end
	end

	oMsgBox:SetActive(true)
	oMsgBox:SetMsg(oMsg)
	if self.m_CurChannel == define.Channel.Common and oMsg:IsPlayerChat() then
		if oMsgBox.AddChannel then
			oMsgBox:AddChannel()
		end
	end
	self.m_MsgTable:AddChild(oMsgBox)
	
	if not bAppend then --bAppend true 最后面添加，false添加到第一位
		oMsgBox:SetAsFirstSibling()
	end
	
	local iCount = self.m_MsgTable:GetCount()
	if not bAppend and iCount>self.m_MsgCnt then
		local oChild = self.m_MsgTable:GetChild(iCount)
		self.m_MsgTable:RemoveChild(oChild)
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:CullContentLater()
	self.m_ScrollView:ResetPosition()
end

function CChatScrollPart.ShowNewMsg(self)
	if self.m_IsLockRead then
		local index = self.m_MsgTable:GetCount()
		local oItem = self.m_MsgTable:GetChild(index)
		if oItem and oItem:GetActive() then
			self:SwitchLock()
		end
	end
end

function CChatScrollPart.ShowOldMsg(self)
	local iCount = self.m_MsgTable:GetCount()
	if iCount > self.m_MsgCnt-1 then
		return
	end
	local oOldMsg = self.m_MsgList[self.m_CurAppendIdx - 1]
	if oOldMsg then
		self:AddMsg(oOldMsg, true)
		self.m_CurAppendIdx = self.m_CurAppendIdx - 1
	end
end

function CChatScrollPart.OnSubmit(self)
	local sText = self.m_Input:GetText()
	if string.len(sText) == 0 then
		g_NotifyCtrl:FloatMsg("输入内容不能为空")
		return
	end
	
	--sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	local iEmojiCnt = 0
	local function emoji(s)
		iEmojiCnt = iEmojiCnt + 1
		if iEmojiCnt > 5 then
			return string.sub(s, 5)
		else
			return s
		end
	end
	sText = string.gsub(sText, "#%d+", emoji)
	sText = string.gsub(sText, "#n", "")
	sText = string.gsub(sText, "#l", "")
	if g_MaskWordCtrl:IsContainMaskWord(sText) then
		sText = string.gsub(sText, "#%u", "")
	end
	local sendText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	sendText = g_MaskWordCtrl:ReplaceHideStr(sendText)
	local sendChannel = self.m_CurChannel
	if sendChannel == define.Channel.Common then
		sendChannel = self.m_CurCommChannel
	end
	if g_ChatCtrl:SendMsg(sendText, sendChannel) then
		self.m_LastSendText = sendText
		Utils.AddTimer(function() self.m_LastSendText = nil end, 0, 1)
		g_ChatCtrl:SaveHistory(sText)
	end
end

function CChatScrollPart.ClearInputText(self, text)
	if self.m_LastSendText and self.m_LastSendText == text then
		self.m_Input:SetText("")
	end
end

function CChatScrollPart.OnSpeech(self, oBtn, bPress)
	if bPress then
		if not self:CheckSendLimit(self.m_CurChannel) then
			return
		end
		self:RecordTimeOut()
		CSpeechRecordView:ShowView(function(oView) 
				oView:SetRecordBtn(oBtn)
				oView:BeginRecord()
			end)
	else
		local oView = CSpeechRecordView:GetView()
		if oView then
			oView:EndRecord(self.m_CurChannel)
		end
	end
end

function CChatScrollPart.RecordTimeOut(self)
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
			self:OnSpeech(nil, false)
			return
		end
		return true
	end
	self.m_ForceTimer = Utils.AddTimer(forceend, 0.5, 0)
end

function CChatScrollPart.SetChannel(self, iChannel)
	local lForbid = self:ForbidChatChannels()
	local bCanChat = table.index(lForbid, iChannel) == nil
	if bCanChat or iChannel == define.Channel.Team or iChannel == define.Channel.Org or iChannel == define.Channel.TeamPvp then
		self.m_IsLockRead = false
		self:RefreshLock()
		g_ChatCtrl:SendLimitMsg(iChannel)
	end
	self.m_CurChannel = iChannel
	if not bCanChat then
		self:CloseInput()
	else
		self:ShowInput()
	end
	self.m_SubmitBtn:SetActive(bCanChat)
	self:SetAudioBox()
	self:RefreshAllMsg()
end

function CChatScrollPart.RefreshTeamChannel(self)
	if self.m_CurChannel == define.Channel.Team then
		if g_TeamCtrl:IsJoinTeam() then
			self:ShowInput()
			self.m_SubmitBtn:SetActive(true)
		end
	elseif self.m_CurChannel == define.Channel.TeamPvp then
		if g_TeamPvpCtrl:GetMemberSize() > 1 then
			self:ShowInput()
			self.m_SubmitBtn:SetActive(true)
		end
	end
end

function CChatScrollPart.RefreshOrgChannel(self)
	if self.m_CurChannel == define.Channel.Org then
		if g_OrgCtrl:HasOrg() then
			self:ShowInput()
			self.m_SubmitBtn:SetActive(true)
		end
	end
end

function CChatScrollPart.CheckSendLimit(self, iChannel)
	return true
end

function CChatScrollPart.SetAudioBox(self)
	if self.m_CurChannel == define.Channel.Common then
		self.m_SpeechBtn:SetActive(false)
		self.m_CommonPart:SetActive(true)
		self:SetCommPart()
	else
		self.m_CommonPart:SetActive(false)
	end
end

CChatScrollPart.LAST_COMMCHANEL = nil
function CChatScrollPart.SetCommPart(self)
	local channelList = {define.Channel.Current, define.Channel.World}
	local channel2idx = {
		[4] = 1,
		[1] = 4,
		[2] = 2,
		[3] = 3,
		[8] = 2,
	}
	if g_AttrCtrl.org_id ~= 0 then
		table.insert(channelList, define.Channel.Org)
	end
	if g_TeamCtrl:IsJoinTeam() then
		table.insert(channelList, define.Channel.Team)
	elseif g_TeamPvpCtrl:GetMemberSize() > 1 then
		table.insert(channelList, define.Channel.TeamPvp)
	end
	if self.m_CurCommChannel then
		self.m_CurCommChannel = self.m_CurCommChannel
	elseif CChatScrollPart.LAST_COMMCHANEL and table.index(channelList, CChatScrollPart.LAST_COMMCHANEL) then
		self.m_CurCommChannel = CChatScrollPart.LAST_COMMCHANEL
	else
		self.m_CurCommChannel = define.Channel.World
	end
	CChatScrollPart.LAST_COMMCHANEL = self.m_CurCommChannel
	self.m_CommChanelBtn:SetText(define.Channel.Ch2Text[self.m_CurCommChannel])
	for _, oBtn in ipairs(self.m_CommSelBtnList) do
		oBtn:SetActive(false)
	end
	local iAmount = 0
	for _, iChannel in ipairs(channelList) do
		if iChannel ~= self.m_CurCommChannel then
			local idx = channel2idx[iChannel]
			self.m_CommSelBtnList[idx]:SetActive(true)
			self.m_CommSelBtnList[idx].m_Chanel = iChannel
			iAmount = iAmount + 1
		end
	end
	self.m_CommSelGrid:Reposition()
	self.m_CommGridBG:SetSize(80, 10+55*iAmount)
end

function CChatScrollPart.SetAutoAudio(self)
	g_ChatCtrl:SetAudioChannel(self.m_CurChannel, self.m_AudioSetBox.m_Btn:GetSelected())
end

function CChatScrollPart.ReleaseTipTimer(self)
	if self.m_TipTimer then
		Utils.DelTimer(self.m_TipTimer)
		self.m_TipTimer = nil
	end
end

function CChatScrollPart.ForbidChatChannels(self)
	local list = {define.Channel.Message, define.Channel.Sys, define.Channel.Rumour}
	if not g_TeamCtrl:IsJoinTeam() then
		table.insert(list, define.Channel.Team)
	end
	if g_TeamPvpCtrl:GetMemberSize() <= 1 then
		table.insert(list, define.Channel.TeamPvp)
	end
	if not g_OrgCtrl:HasOrg() then
		table.insert(list, define.Channel.Org) 
	end
	return list
end

function CChatScrollPart.RefreshAllMsg(self)
	self.m_MsgTable:Clear()
	self.m_CurAppendIdx = 0
	self.m_MsgList = {}
	for i, iChannel in ipairs(self:GetReceiveChannels()) do
		local list = g_ChatCtrl:GetMsgList(iChannel)
		for i, oMsg in ipairs(list) do
			table.insert(self.m_MsgList, oMsg)
		end
	end
	local lATMsg = g_ChatCtrl:GetATMsgList()
	if lATMsg[self.m_CurChannel] and lATMsg[self.m_CurChannel][1] then
		self.m_ATSprite:SetActive(true)
	else
		self.m_ATSprite:SetActive(false)
	end

	table.sort(self.m_MsgList, function(a, b) return a["pos"] < b["pos"] end)
	local len = #self.m_MsgList
	local lastIndex = nil
	for i=len, len-self.m_AddCnt, -1 do
		local oMsg = self.m_MsgList[i]
		if oMsg then
			if not lastIndex then
				lastIndex = oMsg.m_ID
			end
			self:AddMsg(oMsg, true)
			self.m_CurAppendIdx = i
		else
			break
		end
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CChatScrollPart.RefreshLock(self)
	self.m_UnReadBox:SetActive(self.m_IsLockRead)
	self.m_LockSpr:SetActive(self.m_IsLockRead)
	self.m_UnLockSpr:SetActive(not self.m_IsLockRead)
	
	if not self.m_IsLockRead and self.m_LockCnt then
		local tail = #self.m_MsgList
		local head = math.max(1, tail - self.m_LockCnt +1)
		for i = head, tail do
			local oMsg = self.m_MsgList[i]
			if oMsg then
				self:AddMsg(oMsg)
			end
		end
		self.m_MsgTable:Reposition()
		self.m_ScrollView:ResetPosition()
	end
	self:SetUnReadCnt(0)
end

function CChatScrollPart.SetUnReadCnt(self, iCnt)
	self.m_LockCnt = iCnt
	if iCnt > 0 then
		self.m_UnReadBox:SetActive(true)
	else
		self.m_UnReadBox:SetActive(false)
	end
	local s = string.format("未读信息%d条", self.m_LockCnt)
	self.m_UnReadBox.m_Label:SetText(s)
	self.m_UnReadBox.m_ArrowSpr:ResetAndUpdateAnchors()
end


function CChatScrollPart.ReadAll(self)
	self:SwitchLock()
end

function CChatScrollPart.SwitchLock(self)
	self.m_IsLockRead = not self.m_IsLockRead
	self:RefreshLock()
end

function CChatScrollPart.SetLock(self)
	if not self.m_IsLockRead then
		local index = self.m_MsgTable:GetCount()
		local oItem = self.m_MsgTable:GetChild(index)

		if oItem and not oItem:GetActive() then
			self:SwitchLock()
		end
	end
end

function CChatScrollPart.ShowInput(self)
	self.m_SpeechBtn:SetActive(true)
	self.m_InputBtn:SetActive(false)
	self.m_Input:SetActive(true)
	self.m_EmojiBtn:SetActive(true)
	self.m_SpeechPressBtn:SetActive(false)
	self.m_SubmitBtn:SetActive(true)
	self.m_NoInputTip:SetActive(false)
end

function CChatScrollPart.ShowSpeech(self)
	self.m_SpeechBtn:SetActive(false)
	self.m_InputBtn:SetActive(true)
	self.m_Input:SetActive(false)
	self.m_EmojiBtn:SetActive(false)
	self.m_SpeechPressBtn:SetActive(true)
	self.m_SubmitBtn:SetActive(false)
end

function CChatScrollPart.CloseInput(self)
	self.m_SpeechBtn:SetActive(false)
	self.m_InputBtn:SetActive(false)
	self.m_Input:SetActive(false)
	self.m_EmojiBtn:SetActive(false)
	self.m_SpeechPressBtn:SetActive(false)
	self.m_NoInputTip:SetActive(true)
end

function CChatScrollPart.OnEmoji(self)
	CEmojiLinkView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
		end
	)
end

function CChatScrollPart.OnSwitchCommChannel(self, oBtn)
	self.m_CurCommChannel = oBtn.m_Chanel
	self:SetCommPart()
	self:OnCloseCommSelPart()
end

function CChatScrollPart.OnShowCommSelPart(self)
	self.m_CommSelPart:SetActive(true)
end

function CChatScrollPart.OnCloseCommSelPart(self)
	self.m_CommSelPart:SetActive(false)
end

function CChatScrollPart.OnSwitchCommSelPart(self)
	if self.m_CommSelPart:GetActive() then
		self.m_CommSelPart:SetActive(false)
	else
		self.m_CommSelPart:SetActive(true)
	end
end

function CChatScrollPart.AppendText(self, s)
	if self.m_TipTimer then
		return
	end
	local sOri = self.m_Input:GetText()
	if self:CheckValidLink(sOri, s) then
		if s == "" then
			self.m_Input:OnInputChange()
		else
			self.m_Input:SetText(sOri..s)
			self.m_Input:SetFocus()
		end
	end
end

function CChatScrollPart.CheckValidLink(self, lmsg, rmsg)
	local _, lLink = LinkTools.GetLinks(lmsg)
	local _, rLink = LinkTools.GetLinks(rmsg)
	local linkdict = {}
	--统计已输入链接
	for _, dLink in ipairs(lLink) do
		linkdict[dLink.sType] = linkdict[dLink.sType] or {}
		if dLink.iLinkid then
			linkdict[dLink.sType][dLink.iLinkid] = dLink.m_LinkText
		end
	end
	--新输入链接如果存在，则做删除链接处理
	for _, dLink in ipairs(rLink) do
		local lLinkList = linkdict[dLink.sType]
		if lLinkList and lLinkList[dLink.iLinkid] then
			local newmsg = string.replace(lmsg, lLinkList[dLink.iLinkid], "")
			self.m_Input:SetText(newmsg)
			return false
		end
	end
	if string.len(lmsg) + string.len(rmsg) > 100 then
		g_NotifyCtrl:FloatMsg("字数已达上限")
		return false
	end
	return true
end

function CChatScrollPart.CheckATMsg(self, oMsg)
	local iChannel = oMsg:GetValue("channel")
	local lReceives = self:GetReceiveChannels()
	if self.m_CurChannel == define.Channel.Common then
		return
	end
	
	if table.index(lReceives, iChannel) then
		self.m_ATSprite:SetActive(true)
	end
end

function CChatScrollPart.OnClickAT(self)
	if self.m_IsLockRead then
		self:SwitchLock()
	end
	local lMsg = g_ChatCtrl:GetATMsgList()
	local iChannel = self.m_CurChannel
	if lMsg[iChannel] then
		local oMsg = lMsg[iChannel][1]
		if oMsg then
			self:ScrollToMsg(oMsg)
		end
	end
	g_ChatCtrl:ClearATChanel(iChannel)
end

function CChatScrollPart.UpdateQuestion(self, data)
	local data = g_ActivityCtrl:GetQuesionAnswerCtrl():GetQuestionInfo()
	self.m_QABtn:SetActive(false)
	self.m_QABtn:DelEffect("Finger3")
	if data then
		if data["type"] == 1 then
			self.m_QABtn:SetActive(true)
			local oView = CQuestionAnswerView:GetView()
			local bRight = g_ActivityCtrl:GetQuesionAnswerCtrl():IsRightAnswer()
			if (not oView or not oView:GetActive()) and not bRight then
				self.m_QABtn:AddEffect("Finger3")
			end
		end
	end
end

function CChatScrollPart.ScrollToMsg(self, oMsg)
	for _, oMsgBox in ipairs(self.m_MsgTable:GetChildList()) do
		if oMsgBox.m_Msg == oMsg then
			if not oMsgBox:GetActive() then
				UITools.MoveToTarget(self.m_ScrollView, oMsgBox)
				local oTarget = oMsgBox
				local oScroll = self.m_ScrollView
				oScroll:ResetPosition()
				local v = oScroll:GetLocalPos()
				local pos = oTarget:GetLocalPos()
				local movement = oScroll:GetMovement()
				oScroll:MoveRelative(Vector3.New(0, -(v.y + pos.y-50), 0))
			end
		end
		self:SetLock()
	end
	self.m_ATSprite:SetActive(false)
end

function CChatScrollPart.OnShowQAView(self)
	self.m_QABtn:DelEffect("Finger3")
	CChatMainView:ShowView(function(oView)
		oView:SwitchChannel(define.Channel.World)
		end
	)
	local data = g_ActivityCtrl:GetQuesionAnswerCtrl():GetQuestionInfo()
	if data then
		if data["type"] == 1 then
			CQuestionAnswerView:ShowView(function (oView)
				oView:RefreshData(data)
			end)
		end
	else
		self.m_QABtn:SetActive(false)
	end
end

function CChatScrollPart.DelQAEffect(self)
	self.m_QABtn:DelEffect("Finger3")
end

return CChatScrollPart
