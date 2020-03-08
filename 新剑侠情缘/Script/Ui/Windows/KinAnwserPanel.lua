local tbUi = Ui:CreateClass("KinAnswerPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHAT_NEW_MSG, self.NewChatMsg, self},
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.Update, self },
	};

	return tbRegEvent;
end

local tbOptionButtons = {
	"BtnA",
	"BtnB",
	"BtnC",
	"BtnD",
}


tbUi.tbCache = tbUi.tbCache or {};
local tbData = tbUi.tbCache;

function tbUi:OnOpen(tbQuizData)
	if me.nMapTemplateId ~= Kin.Def.nKinMapTemplateId then
		me.MsgBox("确定要回到家族参加活动吗？", {{"确定", Kin.GoKinMap}, {"取消"}});
		return 0;
	end

	if tbData.nDay ~= Lib:GetLocalDay() then
		tbUi.tbCache = {};
		tbData = tbUi.tbCache;
		tbData.nDay = Lib:GetLocalDay();
	end

	tbQuizData.nReply = tbData[tbQuizData.nIndex];
	self.tbQuizData = tbQuizData;
	self:Update()
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
end

function tbUi:NewChatMsg(nChannelId, tbMsg)
	local tbLinkInfo = tbMsg.tbLinkInfo;
	if not tbLinkInfo or tbLinkInfo.nLinkType ~= ChatMgr.LinkType.KinQuestion then
		return;
	end

	local tbQuestion = tbLinkInfo.tbData and tbLinkInfo.tbData.tbQuestionData;
	if not tbQuestion then
		return;
	end

	self.tbQuizData = tbQuestion;
	self:Update();
end

function tbUi:Update()
	local tbQuizData = self.tbQuizData;
	self.pPanel:Label_SetText("TxtQuestion", tbQuizData.szQuiz);

	local szRightCount = string.format("%d/%d", Kin:GetGatherAnswerRightCount(), Kin.GatherDef.QuizCount);
	self.pPanel:Label_SetText("TxtRightCount", szRightCount);

	for nIndex, szBtnName in ipairs(tbOptionButtons) do
		self[szBtnName].pPanel:Label_SetText("TxtAnwser", tbQuizData.tbOption[nIndex]);

		if tbQuizData.nReply == nIndex then
			self[szBtnName].pPanel:SetActive("Fork", tbQuizData.nReply ~= tbQuizData.nAnswer);
			self[szBtnName].pPanel:SetActive("Hook", tbQuizData.nReply == tbQuizData.nAnswer);
		else
			self[szBtnName].pPanel:SetActive("Fork", false);
			self[szBtnName].pPanel:SetActive("Hook", false);
		end
	end

	self:UpdateTime();
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
	self.nTimer = Timer:Register(Env.GAME_FPS, self.UpdateTime, self);
end

function tbUi:UpdateTime()
	local nLeftTime = self.tbQuizData.nTimeOut - GetTime();
	local szIndex = string.format("第%d題", self.tbQuizData.nIndex or 0)
	if nLeftTime > 0 then
		szIndex = string.format("%s（%d秒）", szIndex, nLeftTime);
	end
	self.pPanel:Label_SetText("TxtIndex", szIndex);
	return true;
end

function tbUi:Answer(nIndex)
	if self.tbQuizData.nReply then
		me.CenterMsg("已回答过本题");
		return;
	end

	if GetTime() >= self.tbQuizData.nTimeOut then
		me.CenterMsg("本题答题时间已结束");
		return 0;
	end

	Ui:OpenWindow("MessageBox",
		string.format("确认答案：[FFFE0D]%s[-]", self.tbQuizData.tbOption[nIndex]),
		{{function ()
			Kin:GatherAnswer(self.tbQuizData.nIndex, nIndex);
			self.tbQuizData.nReply = nIndex;
			local tbGatherData = Kin:GetGatherOtherData()
			tbGatherData[Kin.GatherDef.QuestionData].nReply = nIndex
			tbData[self.tbQuizData.nIndex] = nIndex;
			self:Update();
		end}, {}},
		{"确定", "取消"});
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

for nIndex, szBtnName in ipairs(tbOptionButtons) do
	tbUi.tbOnClick[szBtnName] = function (self)
		self:Answer(nIndex);
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinAnswerPanel");
end
