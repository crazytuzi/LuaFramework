local tbUi = Ui:CreateClass("LanternQuestionPanel")

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
}

function tbUi:OnOpen(nNpcId, nQuestionId)
	self.nNpcId = nNpcId
	self.tbQuestion = Activity.MonsterNianAct:GetQuestion(nQuestionId)
	if not self.tbQuestion then
		return 0
	end

	self.nSelected = nil

	local szUpper, szLower = "？", "？"
	if self.tbQuestion.nUpper==1 then
		szUpper = self.tbQuestion.szQuestion
	else
		szLower = self.tbQuestion.szQuestion
	end
	self.pPanel:Label_SetText("LabelUpper", szUpper)
	self.pPanel:Label_SetText("LabelLower", szLower)

	for i=1, 4 do
		self.pPanel:SetActive("correct"..i, false)
		self.pPanel:SetActive("wrong"..i, false)
		self.pPanel:SetActive("CorrectBg"..i, false)
		self.pPanel:Label_SetText("TxtAnswer"..i, self.tbQuestion["szA"..i])
	end
end

function tbUi:Answer(nAnswerId)
	if self.nSelected then
		return
	end
	self.nSelected = nAnswerId
	RemoteServer.MonsterNianReq("Answer", self.nNpcId, self.tbQuestion.nId, nAnswerId)
	self:ShowResult()
end

function tbUi:ShowResult()
	local bCorrect = self.tbQuestion.nAnswerId==self.nSelected
	self.pPanel:SetActive("correct"..self.nSelected, bCorrect)
	self.pPanel:SetActive("wrong"..self.nSelected, not bCorrect)
	self.pPanel:SetActive("CorrectBg"..self.nSelected, bCorrect)
end