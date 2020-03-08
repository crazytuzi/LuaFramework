local tbUi = Ui:CreateClass("ChuanZhenQiQiaoPanel")

tbUi.tbOnClick = {
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnAnswer1 = function(self)
    	self:Answer(1)
    end,
    BtnAnswer2 = function(self)
    	self:Answer(2)
    end,
    BtnAnswer3 = function(self)
    	self:Answer(3)
    end,
    BtnAnswer4 = function(self)
    	self:Answer(4)
    end,
    BtnDekaron = function(self)
    	RemoteServer.ChuanZhenQiQiaoReq("Ready")
    end,
}

function tbUi:OnOpen()
	self.pPanel:Label_SetText("WaitingTip", "等待队友确定...")
	self.pPanel:Label_SetText("Time", "")
	self.pPanel:Texture_SetFillPercent("TimeSp", 0)
	self:Refresh()
end

function tbUi:OnOpenEnd()
	self:ShowPanel(false)
	Ui:TryPlaySitutionalDialog(Activity.ChuanZhenQiQiaoAct.nIntroDlgId, false, {self.ShowPanel, self, true})
end

function tbUi:ShowPanel(bShow)
	self.pPanel:SetActive("Main", bShow)
	if bShow then
		self.nCloseTimer = Timer:Register(Env.GAME_FPS * 60, function()
			self:AutoClose()
		end)
	end
end

function tbUi:AutoClose()
	local tbData = Activity.ChuanZhenQiQiaoAct.tbData or {}
	local nTimeLeft = (tbData.nDeadline or 0) - GetTime()
	if nTimeLeft <= 0 then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function tbUi:OnClose()
	self:StopTimer()
end

function tbUi:Refresh()
	local tbState = Activity.ChuanZhenQiQiaoAct.tbState
	local tbData = Activity.ChuanZhenQiQiaoAct.tbData
	if not tbState then
		return
	end
	if not tbState.bStarted or not tbData then
		self.pPanel:SetActive("Text", false)
		self.pPanel:SetActive("Answer", false)
		self.pPanel:SetActive("Time", false)

		local bReady = not not tbState.tbPlayers[me.dwID]
		self.pPanel:SetActive("BtnDekaron", not bReady)
		self.pPanel:SetActive("WaitingTip", bReady)

		return
	else
		self.pPanel:SetActive("Time", true)
		self.pPanel:SetActive("Text", true)
		self.pPanel:SetActive("Answer", true)
		self.pPanel:SetActive("BtnDekaron", false)
		self.pPanel:SetActive("WaitingTip", false)
		self:StartTimer()
	end

	self.tbQuestion = Activity.ChuanZhenQiQiaoAct:GetQuestionSetting(tbData.nQuestionId)
	if not self.tbQuestion then
		return 0
	end

	self.nSelected = nil
	self.pPanel:Label_SetText("Text", string.format("题目：%s", self.tbQuestion.szQuestion))

	for i=1, 4 do
		self.pPanel:SetActive("correct"..i, false)
		self.pPanel:SetActive("wrong"..i, false)
		self.pPanel:SetActive("CorrectBg"..i, false)
		self.pPanel:Label_SetText("TxtAnswer"..i, self.tbQuestion["szA"..i])
	end
end

function tbUi:UpdateTime()
	local tbData = Activity.ChuanZhenQiQiaoAct.tbData or {}
	local nTimeLeft = (tbData.nDeadline or 0) - GetTime()
	self.pPanel:Label_SetText("Time", string.format("倒计时：%s", Lib:TimeDesc3(math.max(0, nTimeLeft))))
	if nTimeLeft <= -2 then
		RemoteServer.ChuanZhenQiQiaoReq("Answer", self.tbQuestion.nId, nAnswerId)
	end
end

function tbUi:StartTimer()
	self:StopTimer()
	self.nTimer = Timer:Register(math.floor(Env.GAME_FPS), function()
		self:UpdateTime()
		return true
	end)
end

function tbUi:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:Answer(nAnswerId)
	if me.nSex ~= (Activity.ChuanZhenQiQiaoAct.tbData.bFemaleAnswer and Player.SEX_FEMALE or Player.SEX_MALE) then
		me.CenterMsg("请让队友来答这道题")
		return
	end
	if self.nSelected then
		return
	end
	self.nSelected = nAnswerId
	self:ShowResult()
	RemoteServer.ChuanZhenQiQiaoReq("SyncAnswer", self.tbQuestion.nId, nAnswerId)
	Timer:Register(Env.GAME_FPS, function()
		RemoteServer.ChuanZhenQiQiaoReq("Answer", self.tbQuestion.nId, nAnswerId)
	end)
end

function tbUi:ShowResult()
	local bCorrect = self.tbQuestion.nAnswerId==self.nSelected
	self.pPanel:SetActive("correct"..self.nSelected, bCorrect)
	self.pPanel:SetActive("wrong"..self.nSelected, not bCorrect)
	self.pPanel:SetActive("CorrectBg"..self.nSelected, bCorrect)
end

function tbUi:PlayAnimation()
	local nRight = Activity.ChuanZhenQiQiaoAct.tbData.nRight
	local nDelta = 1 / Activity.ChuanZhenQiQiaoAct.nAnswerCount
	self.pPanel:Texture_SetFillPercent("TimeSp", nDelta * nRight)
end

function tbUi:OnSyncAnswer(nAnswerIdx)
	self.nSelected = nAnswerIdx
	self:ShowResult()
end