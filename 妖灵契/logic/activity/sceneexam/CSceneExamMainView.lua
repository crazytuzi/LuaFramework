local CSceneExamMainView = class("CSceneExamMainView", CViewBase)

function CSceneExamMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/SceneExam/SceneExamView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_SwitchSceneClose = true
end

function CSceneExamMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_QuestionLabel = self:NewUI(2, CLabel)
	self.m_RightAnswerItem = self:NewUI(3, CBox)
	self.m_LeftAnswerItem = self:NewUI(4, CBox)
	self.m_TimerLabel = self:NewUI(5, CLabel)
	self.m_ReadyTimeLabel = self:NewUI(7, CLabel)
	self.m_ExamPage = self:NewUI(8, CObject)
	self.m_ReadyPage = self:NewUI(9, CObject)
	self.m_ReadyLabel = self:NewUI(10, CLabel)
	self.m_ConfirmBtn = self:NewUI(11, CButton)
	self.m_ClickOutSpr = self:NewUI(12, CSprite)
	self.m_DigitSpr = self:NewUI(13, CSprite)
	self:InitContent()
end

function CSceneExamMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnEnterScene"))
	self.m_ClickOutSpr:AddUIEvent("click", callback(self, "OnClose"))
	self.m_DigitSpr.m_Tween = self.m_DigitSpr:GetComponent(classtype.UITweener)
	self.m_DigitSpr:SetActive(false)
	self:InitItemBtn()
end

function CSceneExamMainView.InitItemBtn(self)
	self.m_LeftAnswerItem.m_Label = self.m_LeftAnswerItem:NewUI(1, CLabel)
	self.m_RightAnswerItem.m_Label = self.m_RightAnswerItem:NewUI(1, CLabel)
	self.m_LeftAnswerItem:AddUIEvent("click", callback(self, "OnClickAnswer", 1))
	self.m_RightAnswerItem:AddUIEvent("click", callback(self, "OnClickAnswer", 2))
end

function CSceneExamMainView.ShowReadPage(self)
	self.m_ReadyPage:SetActive(true)
	self.m_ExamPage:SetActive(false)
	self:RefreshReady()
end

function CSceneExamMainView.ShowExamPage(self)
	self.m_ReadyPage:SetActive(false)
	self.m_ExamPage:SetActive(true)
end

function CSceneExamMainView.UpdateQuestion(self)
	local dData = g_SceneExamCtrl:GetQuestion()
	self.m_QuestionLabel:SetText(tostring(dData["id"]).."."..dData["desc"])
	self.m_LeftAnswerItem.m_Label:SetText(dData["answer_list"][1])
	self.m_RightAnswerItem.m_Label:SetText(dData["answer_list"][2])

	local function update()
		if Utils.IsNil(self) then
			return
		end
		local t = dData["end_time"] - g_TimeCtrl:GetTimeS()
		if t > 0 then
			self.m_TimerLabel:SetText(g_TimeCtrl:GetLeftTime(t))
			if t > 0 and t < 4 then
				local idx = tonumber(math.max(t, 1))
				self.m_DigitSpr:SetActive(true)
				self.m_DigitSpr:SetSpriteName(string.format("pic_cjdi_%d", idx))
				if self.m_DigitSpr.m_Idx ~= idx then
					self.m_DigitSpr.m_Tween:ResetToBeginning()
					self.m_DigitSpr.m_Tween:Play(true)
				end
				self.m_DigitSpr.m_Idx = idx
			end
			return true
		else
			self.m_TimerLabel:SetText("00:00")
			self.m_DigitSpr:SetActive(false)
			self:OnClose()
		end
	end
	if self.m_EndTimer then
		Utils.DelTimer(self.m_EndTimer)
		self.m_DigitSpr:SetActive(false)
	end
	self.m_EndTimer = Utils.AddTimer(update, 0.2, 0)
end

function CSceneExamMainView.RefreshReady(self)
	local dData = g_SceneExamCtrl:GetData()
	local iState = g_SceneExamCtrl:GetState()
	if iState == 1 then
		self.m_ReadyLabel:SetText("[654a33]报名成功，请在[c54141]12:10[-]分前进场[-]")
	else
		self.m_ReadyLabel:SetText("[654a33]活动进行中，快点进场吧~喵[-]")
	end
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local t = dData["notify_end_time"] - g_TimeCtrl:GetTimeS()
		if t > 0 then
			self.m_ReadyTimeLabel:SetText(g_TimeCtrl:GetLeftTime(t))
			return true
		else
			self.m_ReadyTimeLabel:SetText("00:00")
		end
	end
	if self.m_ReadyTimer then
		Utils.DelTimer(self.m_ReadyTimer)
	end
	self.m_ReadyTimer = Utils.AddTimer(update, 0.2, 0)
end

function CSceneExamMainView.OnClickAnswer(self, i)
	local d = data.sceneexamdata.SceneData[3000]
	local x, y = 0, 0
	if i == 1 then
		x, y = d.leftpos.x, d.leftpos.y
	else
		x, y = d.rightpos.x, d.rightpos.y
	end
	x = x + Utils.RandomInt(-1, 1)
	y = y + Utils.RandomInt(-1, 1)
	CAutoPath:WalkTo({x=x, y=y})
	self:DoChat(i)
end

function CSceneExamMainView.DoChat(self, i)
	local d = data.sceneexamdata.SceneChat
	local dChat = table.randomvalue(d)
	local dMsg = nil
	if i == 1 then
		dMsg = dChat["chatA"]
	else
		dMsg = dChat["chatB"]
	end
	if dMsg then
		 g_ChatCtrl:SendMsg(dMsg, define.Channel.Current)
	end
end

function CSceneExamMainView.OnEnterScene(self)
	nethuodong.C2GSEnterQuestionScene()
end

return CSceneExamMainView