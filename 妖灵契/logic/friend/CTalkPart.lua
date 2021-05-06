local CTalkPart = class("CTalkPart", CBox)

function CTalkPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Input = self:NewUI(1, CChatInput)
	self.m_MsgTable = self:NewUI(2, CTable)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_MsgBoxRight = self:NewUI(4, CFriendMsgBox)
	self.m_MsgBoxLeft = self:NewUI(5, CFriendMsgBox)
	self.m_SubmitBtn = self:NewUI(6, CButton)
	self.m_EmojiBtn = self:NewUI(7, CButton)
	self.m_UnReadBox = self:NewUI(8, CBox)
	self.m_AudioBtn = self:NewUI(9, CButton)

	self.m_FrdShipLabel = self:NewUI(10, CLabel)

	self.m_FrdTipBtn = self:NewUI(11, CButton)
	self.m_MsgBoxSys = self:NewUI(12, CChatSysMsgBox)
	self.m_RelationLabel = self:NewUI(13, CLabel)

	self.m_TipBox = self:NewUI(14, CBox)
	self.m_NameBox = self:NewUI(15, CBox)
	self.m_NameLabel = self.m_NameBox:NewUI(1, CLabel)
	self.m_AudioLeft = self:NewUI(16, CChatAudioBox)
	self.m_AudioRight = self:NewUI(17, CChatAudioBox)

	self.m_SpeechBtn = self:NewUI(18, CButton)
	self.m_InputBtn = self:NewUI(19, CButton)

	self.m_CurChannel = nil
	self.m_IsLockRead = false
	self.m_LastReadIndex = 0
	self.m_UnReadCnt = 0
	self.m_AddCnt = 20
	self.m_CurAppendIdx = 0
	self.m_ExtraReceives = {}
	self.m_MsgList = {}
	self.m_Input:SetForbidChars({"{","}"})
	self:InitContent()
end

function CTalkPart.InitContent(self)
	self.m_UnReadBox:SetActive(false)
	self.m_MsgBoxLeft:SetActive(false)
	self.m_MsgBoxRight:SetActive(false)
	self.m_MsgBoxSys:SetActive(false)
	self.m_AudioLeft:SetActive(false)
	self.m_AudioRight:SetActive(false)
	
	self.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
	self.m_ScrollView:SetCullContent(self.m_MsgTable)
	self.m_ScrollView:AddMoveCheck("up", self.m_MsgTable, callback(self, "ShowOldMsg"))
	--self.m_ScrollView:AddMoveCheck("down", self.m_MsgTable, callback(self, "ShowNewMsg"))
	self.m_ScrollView:AddUIEvent("scrolldragfinished", callback(self, "SetLock"))
	self.m_SpeechBtn:AddUIEvent("longpress", callback(self, "OnSpeech"))
	
	self.m_AudioBtn:AddUIEvent("click", callback(self, "ShowSpeech"))
	self.m_InputBtn:AddUIEvent("click", callback(self, "ShowInput"))

	self.m_FrdTipBtn:AddHelpTipClick("youhaodu")
	
	self.m_UnReadBox:AddUIEvent("click", callback(self, "ReadAll"))
	self.m_UnReadBox.m_Label = self.m_UnReadBox:NewUI(1, CLabel)
	self.m_UnReadBox.m_ArrowSpr = self.m_UnReadBox:NewUI(2, CSprite)
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:ShowInput()
end

function CTalkPart.OnTalkEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Talk.Event.AddMsg then
		local pid = oCtrl.m_EventData["pid"]
		local iAmount = oCtrl.m_EventData["amount"]
		local frdview = CFriendMainView:GetView()
		if frdview and frdview:GetActive() and self:GetActive() and self.m_ID == pid then
			self:AddMsg(pid, iAmount)
		end
	end
end

function CTalkPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFriend(oCtrl.m_EventData)

	elseif oCtrl.m_EventID == define.Friend.Event.AddBlack then
		self:ClearMsgList(oCtrl.m_EventData)
	end
end

function CTalkPart.UpdateFriend(self, frdList)
	if table.index(frdList, self.m_ID) then
		self:RefreshUI()
	end
end

function CTalkPart.SetPlayer(self, pid)
	if self.m_ID and self.m_ID ~= pid then
		self:SaveMsgRecord(self.m_ID)
	end
	self.m_ID = pid
	self:RefreshUI()
	self:AddAllMsg(pid)
	netfriend.C2GSQueryFriendProfile({self.m_ID})
end

function CTalkPart.GetPlayer(self)
	return self.m_ID
end

function CTalkPart.RefreshUI(self)
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	if frdobj then
		self.m_NameLabel:SetText(string.format("与 %s 聊天中", frdobj.name))
		self.m_FrdShipLabel:SetText("好友度 "..tostring(frdobj.friend_degree))
		self.m_RelationLabel:SetText(self:GetRelationText(frdobj.relation))
	else
		self.m_NameLabel:SetText(string.format("与 玩家%d 聊天中", self.m_ID))
	end
end

function CTalkPart.GetRelationText(self, irelation)
	return g_FriendCtrl:GetRelationString(irelation)
end

function CTalkPart.AddAllMsg(self, pid)
	self.m_MsgTable:Clear()
	self.m_MsgData = g_TalkCtrl:GetMsg(pid)
	self.m_CurAppendIdx = 0
	self.m_IsLock = false
	self.m_LoadEnd = false
	self.m_UnReadCnt = 0
	self:RefreshUnRead()
	local iAmount = math.min(20, #self.m_MsgData)
	for i = 1, iAmount do
		self:AddMsgBox(self.m_MsgData[i], true)
	end
	self.m_MsgTable:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CTalkPart.AddMsg(self, pid, iAmount)
	self.m_MsgData = g_TalkCtrl:GetMsg(pid)
	for i = iAmount, 1, -1 do
		local oMsg = self.m_MsgData[i]
		self:AddMsgBox(oMsg)
	end
end

function CTalkPart.AddSelfMsg(self, sText)
	g_TalkCtrl:AddSelfMsg(self.m_ID, sText)
end

function CTalkPart.AddMsgBox(self, oMsg, ishead)
	local iType = oMsg:GetType()
	local oMsgBox = nil
	local audioLink = oMsg:GetAudioLink()
	
	if not self.m_IsLock or ishead == true then
		if iType == define.Chat.MsgType.NoSender then
			oMsgBox = self.m_MsgBoxSys:Clone()
		
		elseif iType == define.Chat.MsgType.Self then
			if audioLink then
				oMsgBox = self.m_AudioRight:Clone()
			else
				oMsgBox = self.m_MsgBoxRight:Clone()
			end
		
		elseif iType == define.Chat.MsgType.Others then
			if audioLink then
				oMsgBox = self.m_AudioLeft:Clone()
			else
				oMsgBox = self.m_MsgBoxLeft:Clone()
			end
		end
		
		oMsgBox:SetActive(true)
		oMsgBox:SetMsg(oMsg)
		self.m_MsgTable:AddChild(oMsgBox)
		if ishead then
			oMsgBox:SetAsFirstSibling()
		end
		self.m_MsgTable:Reposition()
		self.m_ScrollView:CullContentLater()
		self.m_ScrollView:ResetPosition()
	else
		if iType ~= define.Chat.MsgType.NoSender then
			self.m_UnReadCnt = self.m_UnReadCnt + 1
			self:RefreshUnRead()
		end
	end

	self.m_CurAppendIdx = self.m_CurAppendIdx + 1
end

function CTalkPart.ShowOldMsg(self)
	local iCount = self.m_MsgTable:GetCount()
	if iCount >= #self.m_MsgData and not self.m_Load then
		if g_TalkCtrl:LoadMsgRecord(self.m_ID) then
			self.m_MsgData = g_TalkCtrl:GetMsg(self.m_ID)
		else
			self.m_LoadEnd = true
		end
		return
	end
	local oOldMsg = self.m_MsgData[self.m_CurAppendIdx + 1]
	if oOldMsg then
		self:AddMsgBox(oOldMsg, true)
	end
end

function CTalkPart.ShowNewMsg(self)
	if self.m_IsLock then
		
	end
end

function CTalkPart.ClearMsgList(self, pidList)
	if table.index(pidList, self.m_ID) then
		self.m_MsgTable:Clear()
		self.m_MsgTable:Reposition()
		self.m_ScrollView:ResetPosition()
	end
end

function CTalkPart.OnSubmit(self)
	local sText = self.m_Input:GetText()
	if self:CheckGM(sText) then
		return
	end
	if g_FriendCtrl:IsBlackFriend(self.m_ID) then
		g_NotifyCtrl:FloatMsg("发送失败，请先解除黑名单")
		return
	end
	
	if sText == "" then
		g_NotifyCtrl:FloatMsg("消息的内容为空")
		return
	end
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)

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
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = string.gsub(sText, "#l", "")
	sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
	self:AddSelfMsg(sText)
	if not g_AttrCtrl:IsBanChat() then
		g_TalkCtrl:SendChat(self.m_ID, sText)
	end
	self.m_Input:SetText("")
end

function CTalkPart.CheckGM(self, sText)

end

function CTalkPart.RefreshUnRead(self, iCnt)
	local iCnt = self.m_UnReadCnt
	if iCnt > 0 then
		self.m_UnReadBox:SetActive(true)
	else
		self.m_UnReadBox:SetActive(false)
	end
	local s = string.format("未读信息%d条", iCnt)
	self.m_UnReadBox.m_Label:SetText(s)
	self.m_UnReadBox.m_ArrowSpr:ResetAndUpdateAnchors()
end


function CTalkPart.ReadAll(self)
	self.m_UnReadCnt = 0
	self:RefreshUnRead()
	self:AddAllMsg(self.m_ID)
end

function CTalkPart.SetLock(self)
	local index = self.m_MsgTable:GetCount()
	local lastItem = self.m_MsgTable:GetChild(index)
	if lastItem and not lastItem:GetActive() then
		self.m_IsLock = true
	end
end

function CTalkPart.OnEmoji(self)
	CEmojiLinkView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
		end
	)
end

function CTalkPart.AppendText(self, s)
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

function CTalkPart.CheckValidLink(self, lmsg, rmsg)
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
function CTalkPart.OnAddFrd(self)
end

function CTalkPart.OnDelFrd(self)
end

function CTalkPart.ShowTips(self)
	self.m_TipBox:SetActive(true)
end

function CTalkPart.CloseTips(self)
	self.m_TipBox:SetActive(false)
end

function CTalkPart.DefaultSave(self)
	self:SaveMsgRecord(self.m_ID)
end

function CTalkPart.SaveMsgRecord(self, pid)
	if pid then
		g_TalkCtrl:SaveMsgRecord(pid)
	end
end

function CTalkPart.ShowSpeech(self)
	self.m_AudioBtn:SetActive(false)
	self.m_InputBtn:SetActive(true)
	self.m_SpeechBtn:SetActive(true)
	self.m_Input:SetActive(false)
	self.m_EmojiBtn:SetActive(false)
end

function CTalkPart.ShowInput(self)
	self.m_AudioBtn:SetActive(true)
	self.m_InputBtn:SetActive(false)
	self.m_SpeechBtn:SetActive(false)
	self.m_Input:SetActive(true)
	self.m_EmojiBtn:SetActive(true)
end

--语音相关
function CTalkPart.OnSpeech(self, oBtn, bPress)
	if bPress then
		g_ChatCtrl.m_IsChatRecording = true
		self:StartRecord(oBtn)
		self:RecordTimeOut()
	else
		g_ChatCtrl.m_IsChatRecording = false
		self:EndRecord()
	end
end

--开始录音
function CTalkPart.StartRecord(self, oBtn)
	CSpeechRecordView:ShowView(function(oView) 
		oView:SetRecordBtn(oBtn)
		oView:BeginRecord()
	end)
end

--结束录音
function CTalkPart.EndRecord(self)
	local oView = CSpeechRecordView:GetView()
	if oView then
		if oView:EndFriendRecord(self.m_ID) then
			--发送语音后解除锁屏状态
			--self:ReadAll()
		end
	end
end

--录音超时
function CTalkPart.RecordTimeOut(self)
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
			self:EndRecord(nil, false)
			return
		end
		return true
	end
	self.m_ForceTimer = Utils.AddTimer(forceend, 0.5, 0)
end

return CTalkPart
