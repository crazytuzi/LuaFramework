local tbUi = Ui:CreateClass("MedalFightPanel")

tbUi.tbOnClick = {
    BtnClose = function(self)
    	me.MsgBox("关闭此界面将放弃此轮答题，是否关闭？", {
			{"确认", function() 
				Ui:CloseWindow(self.UI_NAME)
			 end},
			{"取消"},
		})
    end,
    Btn1 = function(self)
    	self:Answer(1)
    end,
    Btn2 = function(self)
    	self:Answer(2)
    end,
    Btn3 = function(self)
    	self:Answer(3)
    end,
    Btn4 = function(self)
    	self:Answer(4)
    end,
}

function tbUi:OnOpen()
	self:StartTimer()
	if not Activity.MedalFightAct.tbMatch then
		return 0
	end

	self:SetPlayerUi(Activity.MedalFightAct.tbPlayers[1], Activity.MedalFightAct.tbPlayers[2])
	self:OnNewRound()
end

function tbUi:SetQuestionVisible(bVisible)
	self.pPanel:SetActive("Question", bVisible)
	for i=1, 4 do
		self.pPanel:SetActive("Btn"..i, bVisible)
	end
	self.pPanel:SetActive("Time", bVisible)
end

function tbUi:ShowQuestion()
	if self.bShowQuestion then
		return
	end
	self:SetQuestionVisible(true)
	self.bShowQuestion = true
	local nQuestionId = Activity.MedalFightAct.tbMatch.tbQuestions[Activity.MedalFightAct.tbMatch.nCurRound]
	self.tbQuestion = Activity.MedalFightAct:GetQuestion(nQuestionId)
	if not self.tbQuestion then
		return
	end

	self.nSelected = nil

	self.pPanel:Label_SetText("Question", self.tbQuestion.szQuestion)
	for i=1, 4 do
		self.pPanel:Toggle_SetChecked("Btn"..i, false)
		self.pPanel:SetActive("Correct"..i, false)
		self.pPanel:SetActive("Error"..i, false)
		self.pPanel:Label_SetText("Answer"..i, self.tbQuestion["szA"..i])
	end
end

function tbUi:SetPlayerUi(tbPlayer1, tbPlayer2)
	local tbPlayers = {tbPlayer1, tbPlayer2}
	for i=1, 2 do
		local tbPlayer = tbPlayers[i]

		self.pPanel:Label_SetText("VictoryRate"..i, string.format("胜率：%d%%", tbPlayer.nWinRate))
		self.pPanel:Label_SetText("Medal"..i, "剩余奖章："..tbPlayer.nMedal)
		self.pPanel:Label_SetText("Integral"..i, "积分："..Activity.MedalFightAct.tbMatch.tbPlayers[tbPlayer.nPlayerId].nScore)
		self.pPanel:Label_SetText("PlayerName"..i, tbPlayer.szName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbPlayer.nHonorLevel)
		if ImgPrefix then
			self.pPanel:SetActive("PlayerTitle"..i, true)
			self.pPanel:Sprite_Animation("PlayerTitle"..i, ImgPrefix, Atlas)
		else
			self.pPanel:SetActive("PlayerTitle"..i, false)
		end

		local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbPlayer.nPortrait)
		if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
			self.pPanel:Sprite_SetSprite("Player"..i, szSprite, szAtlas)
		end
	end
end

function tbUi:Answer(nAnswerId)
	if self.nSelected then
		return
	end
	self.nSelected = nAnswerId
	RemoteServer.MedalFightReq("Answer", Activity.MedalFightAct.tbMatch.nId, nAnswerId)
	self:ShowResult()
end

function tbUi:AnswerTimeout()
	self.nSelected = -1
	RemoteServer.MedalFightReq("AnswerTimeout", Activity.MedalFightAct.tbMatch.nId)
end

function tbUi:ShowResult()
	local bCorrect = self.tbQuestion.nAnswerId==self.nSelected
	self.pPanel:SetActive("Correct"..self.nSelected, bCorrect)
	self.pPanel:SetActive("Error"..self.nSelected, not bCorrect)
end

function tbUi:OnNewMatch()
	self:OnNewRound()
end

function tbUi:OnScoreChanged()
	for i, tbPlayer in ipairs(Activity.MedalFightAct.tbPlayers) do
		local nScore = Activity.MedalFightAct.tbMatch.tbPlayers[tbPlayer.nPlayerId].nScore
		self.pPanel:Label_SetText("Integral"..i, "积分："..nScore)
	end
end

function tbUi:ShowAnimation()
	if self.bShowAnimation then
		return
	end
	self.bShowAnimation = true
	self.pPanel:SetActive("Animation", false)
	self.pPanel:Label_SetText("Label1", string.format("第%s题", Lib:Transfer4LenDigit2CnNum(Activity.MedalFightAct.tbMatch.nCurRound)))
	self.pPanel:SetActive("Animation", true)
	local tbNode = {"Label1", "Label2", "3", "2", "1", "Go"}
    for _, szNode in ipairs(tbNode) do
        self.pPanel:Tween_Reset(szNode)
        self.pPanel:Tween_Play(szNode)
    end
end

function tbUi:OnNewRound()
    self.bShowAnimation = false
    self.bShowQuestion = false
    self:SetQuestionVisible(false)
    self:StartTimer()
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

function tbUi:OnClose()
	self:StopTimer()
end

function tbUi:UpdateTime()
	if not Activity.MedalFightAct.tbMatch then
		self.pPanel:Sprite_SetFillPercent("Time", 1)
		self.pPanel:Label_SetText("Label", "")
		return
	end

	local nTotalTime = Activity.MedalFightAct.nRoundTime
	local nTimeLeft = Activity.MedalFightAct.tbMatch.nRoundDeadline-GetTime()

	if nTimeLeft>=nTotalTime+Activity.MedalFightAct.nRoundPrepareTime then
		return
	end
	self:ShowAnimation()

	if nTimeLeft>nTotalTime then
		return
	end
	self:ShowQuestion()

	local nTimeLeft = math.max(0, math.min(nTotalTime, nTimeLeft))
	local nPercent = math.max(0, nTimeLeft/nTotalTime)
	self.pPanel:Sprite_SetFillPercent("Time", nPercent)
	self.pPanel:Label_SetText("Label", nTimeLeft)

	if nTimeLeft<=0 then
		self:AnswerTimeout()
	end
end