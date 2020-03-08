local tbUi = Ui:CreateClass("TaskQuestionPanel");
tbUi.nMaxQuestion = 3
tbUi.nMaxAnswer = 4
function tbUi:OnOpen(nFlowType)
	self:ClearSelect()
	self:Update(nFlowType)
end

function tbUi:ClearSelect()
	for nIdx = 1, self.nMaxQuestion do
		local szGroupName = "QuestionGroup" ..nIdx
		for i = 1, self.nMaxAnswer do
			self[szGroupName]["Btn" .. i].pPanel:Toggle_SetChecked("Main",  false); 
		end
	end
end

function tbUi:Update(nFlowType, tbRight)
	self.nFlowType = nFlowType or self.nFlowType
	if not self.nFlowType then
		return
	end
	me.tbFlowQuestionRight = me.tbFlowQuestionRight or {}
	me.tbFlowQuestionRight[nFlowType] = tbRight or me.tbFlowQuestionRight[nFlowType]
	local tbRight = me.tbFlowQuestionRight[nFlowType]
	local nFlowType = self.nFlowType
	local tbFlowQuestion, szTitle = Task:GetFlowQuestion(nFlowType)
	if not tbFlowQuestion then
		return 
	end
	self.pPanel:Label_SetText("Title", szTitle or "")
	for nIdx = 1, self.nMaxQuestion do
		local tbQuestion = tbFlowQuestion[nIdx] or {}
		local szQuestion = tbQuestion.szQuestion or ""
		local tbAnswer = tbQuestion.tbAnswer or {}
		local nAnswerIdx = tbQuestion.nAnswerIdx or 0
		local szGroupName = "QuestionGroup" ..nIdx
		self.pPanel:SetActive(szGroupName, next(tbFlowQuestion) and true or false)
		self[szGroupName].pPanel:Label_SetText("Question", szQuestion)
		for i = 1, self.nMaxAnswer do
			local szAnswer = tbAnswer[i] or ""
			self[szGroupName]["Btn" .. i].pPanel:SetActive("Main", not Lib:IsEmptyStr(szAnswer) and true or false)
			self[szGroupName]["Btn" .. i].pPanel:Label_SetText("Answer", szAnswer)
			self[szGroupName]["Btn" .. i].pPanel:SetActive("Error", false)
			self[szGroupName]["Btn" .. i].pPanel:SetActive("Correct", false)
			if tbRight then
				local nRight = tbRight[nIdx] or 0
				local bRight = nRight and nRight == -1
				if bRight then
					self[szGroupName]["Btn" .. i].pPanel:SetActive("Correct", i == nAnswerIdx)
					self[szGroupName]["Btn" .. i].pPanel:Toggle_SetChecked("Main", i == nAnswerIdx); 
				else
					self[szGroupName]["Btn" .. i].pPanel:SetActive("Error", i == nRight)
				end
			end
		end
	end

	local nAnswerCount = Task:GetFlowAnswerCount(me, nFlowType)
	self.pPanel:SetActive("Cost", nAnswerCount > 0)
	self.pPanel:Label_SetText("Cost", Task.nFlowQuestionCostGold)
end

function tbUi:OnAnswer(nFlowType, tbRight)
	if self.nFlowType ~= nFlowType then
		return
	end
	self:ClearSelect()
	self:Update(nFlowType, tbRight)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_FLOW_TASK_QUESTION,      self.OnAnswer},
        
    };
    return tbRegEvent;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnPlayback = function (self)
 	Ui:CloseWindow(self.UI_NAME)
    Task:TrackVedioBackPlay()
end
tbUi.tbOnClick.BtnThink = function (self)
    Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick.BtnSubmission = function (self)
	if not self.nFlowType then
		me.CenterMsg("未知分流任务")
		return 
	end
	local nFlowType = self.nFlowType
	local tbAnswer = {}
	for nIdx = 1, self.nMaxQuestion do
		local szGroupName = "QuestionGroup" ..nIdx
		for i = 1, self.nMaxAnswer do
			if self[szGroupName]["Btn" .. i].pPanel:Toggle_GetChecked("Main") then
				tbAnswer[nIdx] = i
			end
		end
	end
	local bRet, szMsg = Task:CheckAnswerFlowQuestion(me, nFlowType, tbAnswer)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	local nAnswerCount = Task:GetFlowAnswerCount(me, nFlowType)
	local szMsg = ""
	if nAnswerCount > 0 then
		szMsg = string.format("是否消耗[FFFE0D]%d元宝[-]提交答案？", Task.nFlowQuestionCostGold)
	else
		szMsg = string.format("首次提交答案为[FFFE0D]免费提交[-]，答错之后之后再提交则每次需要[FFFE0D]%d元宝[-]，确定提交吗？", Task.nFlowQuestionCostGold)
	end
	local fnAgree = function ()
		local bRet, szMsg = Task:CheckAnswerFlowQuestion(me, nFlowType, tbAnswer)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return
		end
		RemoteServer.TryAnswerFlowQuestion(nFlowType, tbAnswer)
	end;
	 me.MsgBox(szMsg, {{"同意", fnAgree}, {"取消"}})
    
end