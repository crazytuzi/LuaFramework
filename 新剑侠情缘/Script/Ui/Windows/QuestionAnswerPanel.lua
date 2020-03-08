local tbUi = Ui:CreateClass("QuestionAnswerPanel");

tbUi.tbAllAnwser = {"BtnA", "BtnB", "BtnC", "BtnD"}

function tbUi:OnOpen(tbQuestion, fnOnSelect)
	if tbUi.nCloseTimerId then
		Timer:Close(tbUi.nCloseTimerId);
		tbUi.nCloseTimerId = nil;
	end

	self.tbQuestion = tbQuestion;
	self.fnOnSelect = fnOnSelect;

	self:Update();
end

function tbUi:Update()
	local tbQuestion = self.tbQuestion;
	self.pPanel:SetActive("TxtIndex", tbQuestion.szIndex and true or false);
	if tbQuestion.szIndex then
		self.pPanel:Label_SetText("TxtIndex", tbQuestion.szIndex);
	end

	self.pPanel:SetActive("Content", tbQuestion.szRightInfoContent and true or false);
	if tbQuestion.szRightInfoContent then
		self.pPanel:Label_SetText("Content", tbQuestion.szRightInfoContent);
	end

	self.pPanel:SetActive("TxtRightCount", tbQuestion.szRightCount and true or false);
	if tbQuestion.szRightCount then
		self.pPanel:Label_SetText("TxtRightCount", tbQuestion.szRightCount);
	end

	self.pPanel:Label_SetText("TxtQuestion", tbQuestion[1]);
	for i, szAnwser in pairs(self.tbAllAnwser) do
		self[szAnwser].pPanel:Label_SetText("TxtAnwser", tbQuestion[i + 1]);
		self[szAnwser].pPanel:SetActive("Hook", false);
		self[szAnwser].pPanel:SetActive("Fork", false);
	end
end

function tbUi:OnSyncResult(bRight, nSelect, nResult)
	if not self.nSelect or nSelect ~= self.nSelect then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	if bRight and self.nSelect then
		self[self.tbAllAnwser[self.nSelect]].pPanel:SetActive("Hook", true);
	else
		self[self.tbAllAnwser[self.nSelect]].pPanel:SetActive("Fork", true);
	end

	if not bRight and nResult and self.tbQuestion[nResult + 1] then
		me.CenterMsg(string.format("正确答案：%s", self.tbQuestion[nResult + 1]));
	end
end

function tbUi:OnClose()
	if tbUi.nCloseTimerId then
		Timer:Close(tbUi.nCloseTimerId);
		tbUi.nCloseTimerId = nil;
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
for i, szAnwser in pairs(tbUi.tbAllAnwser) do
	tbUi.tbOnClick[szAnwser] = function (self)
		self.nSelect = i;
		if self.fnOnSelect then
			self.fnOnSelect(i);
		end
		tbUi.nCloseTimerId = Timer:Register(8, function ()
			tbUi.nCloseTimerId = nil;
			Ui:CloseWindow("QuestionAnswerPanel");
		end)
	end
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end