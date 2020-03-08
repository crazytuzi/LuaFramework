local tbUi = Ui:CreateClass("PartnerCardQuestionPanel");
tbUi.TYPE_QUESTION = PartnerCard.TYPE_QUESTION
tbUi.TYPE_ANSWER = PartnerCard.TYPE_ANSWER
tbUi.tbHideUi = {"Introduction2", "InputTxt", "Sprite (1)"}
tbUi.tbSetting = 
{
	[tbUi.TYPE_QUESTION] = {
		szTitle = "出个题考一下你的好友吧，答对题目双方都有奖励哦";
		bHide = false;
		fnSure = function (self) 
			local nAnswerIdx = self:GetAnswerIdx()
			if not nAnswerIdx then
				me.CenterMsg("请给问题设置一个答案", true)
				return 
			end
			local szBubble = self.pPanel:Label_GetText("Text")
			RemoteServer.PartnerCardOnClientCall("AddCardVisitState", self.nCardId, self.nQuestionId, nAnswerIdx, szBubble, self.tbRandomAnswer)
		end; 
	};
	[tbUi.TYPE_ANSWER] = {
		szTitle = "你的好友出个题考你一下，答对题目双方都有奖励哦";
		bHide = true;
		fnSure = function (self)
			local nAnswerIdx = self:GetAnswerIdx()
			if not nAnswerIdx then
				me.CenterMsg("请选择一个答案", true)
				return 
			end
			RemoteServer.PartnerCardOnClientCall("AnswerVisitQuestion", self.nCardId, self.nQuestionId, nAnswerIdx, self.nVisitPlayerId)
		end; 
	};
}
function tbUi:OnOpen(nType, nCardId, nQuestionId, nVisitPlayerId, tbAnswer)
	self.nType = nType
	self.nCardId = nCardId
	self.nQuestionId = nQuestionId
	self.nVisitPlayerId = nVisitPlayerId
	local tbQuestion = PartnerCard:RandomOneQuestion(self.nQuestionId)
	self.tbRandomAnswer = tbAnswer or tbQuestion.tbAnswer
	self:Update()
end

function tbUi:GetAnswerIdx()
	local nIdx
	if self.pPanel:Toggle_GetChecked("Toggle1") then
		nIdx = 1
	elseif self.pPanel:Toggle_GetChecked("Toggle2") then
		nIdx = 2
	elseif self.pPanel:Toggle_GetChecked("Toggle3") then
		nIdx = 3
	elseif self.pPanel:Toggle_GetChecked("Toggle4") then
		nIdx = 4
	end
	local nAnswerIdx = self.tbRandomAnswer[nIdx]
	return nAnswerIdx
end

function tbUi:Update()
	local tbSetting = self.tbSetting[self.nType]
	self.tbSettingInfo = tbSetting
	if not tbSetting then
		return
	end
	local tbQuestionInfo = PartnerCard:GetQuestionInfo(self.nQuestionId)
	if not tbQuestionInfo then
		return
	end
	for _, szUiName in ipairs(self.tbHideUi) do
		self.pPanel:SetActive(szUiName, not tbSetting.bHide)
	end
	self.pPanel:Label_SetText("Introduction1", tbSetting.szTitle)
	self.pPanel:Label_SetText("Question", tbQuestionInfo.szQuestion)
	local tbAnswer = tbQuestionInfo.tbAnswer
	for i=1,4 do
		local nAnswerIdx = self.tbRandomAnswer[i]
		if tbAnswer[nAnswerIdx] then
			self.pPanel:SetActive("Toggle" ..i, true)
			self.pPanel:Label_SetText("Label" ..i, tbAnswer[nAnswerIdx])
			self.pPanel:Toggle_SetChecked("Toggle" ..i,  false); 
		else
			self.pPanel:SetActive("Toggle" ..i, false)
		end
	end
	local szDefault = PartnerCard.tbPartnerCardVisitTalkSetting[self.nCardId] and PartnerCard.tbPartnerCardVisitTalkSetting[self.nCardId][1]
	self.pPanel:Input_SetDefaultText("InputTxt", szDefault)
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnSure = function (self)
	if not self.tbSettingInfo then
		me.CenterMsg("未知操作")
	else
		self.tbSettingInfo.fnSure(self)
	end
end