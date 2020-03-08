
local tbUi = Ui:CreateClass("NpcBiWuZhaoQinUi")

tbUi.nShowTime = 6;
tbUi.nStayTime = 5;

tbUi.szDesc = [[
参与等级：
最低参与等级：[FFFE0D]60级[-]；开放89级上限：[FFFE0D]70级[-]
开放99级上限：[FFFE0D]80级[-]；开放109级上限：[FFFE0D]90级[-]
开放119级上限：[FFFE0D]100级[-]
[FFFE0D]参与招亲比赛[-]
参加需缴纳报名费，比赛为无差别形式，报名后
以当前门派参赛，所有参赛者公平竞争，[FFFE0D]等级、
战力相同，无装备等外在因素差异，无五行相克[-]
参赛人数最多[FFFE0D]128人[-]，开始后两两随机配对战斗，赢者晋级，剩余参赛人数不大于[FFFE0D]8人[-]后进入决赛
阶段，决赛阶段比赛在[FFFE0D]场内擂台[-]上进行，玩家可以进行[FFFE0D]观战[-] ]]

tbUi.tbChat = {
	[2326] = {
		"我要让这个天下苍生的鲜血来告诉她，我在乎的，究竟是什么！",
		"天下可以丢弃了再夺，军队可以溃散了再组，而人死却无法复生！",
	};
	[2279] = {
		"原本都是一粒沙，被人宠爱，所以才变得珍贵，岁月打磨，终成珍珠",
		"这个世界，别人总是不可指望的，你能指望的，只有你自己",
		"青山遮不住，大江东流去，识时务者方为俊杰",
	};
};

tbUi.tbShowAward = {
	[2326] = {
		tbNormalAward = {
			{"item", 4810, 1},
		};
		tbWinnerAward = {
			{"item", 4811, 1},
			{"item", 4818, 1},
			{"item", 4789, 1},
		};
	},
	[2279] = {
		tbNormalAward = {
			{"item", 4812, 1},
		};
		tbWinnerAward = {
			{"item", 4813, 1},
			{"item", 4818, 1},
			{"item", 4790, 1},
		};
	},
}

function tbUi:OnOpen(nNpcId)
	self.nNpcId = nNpcId;
	local tbShowAward = self.tbShowAward[nNpcId] or {};
	for i = 1, 2 do
		self["normal" .. i].pPanel:SetActive("Main", false);
		if tbShowAward and tbShowAward.tbNormalAward and tbShowAward.tbNormalAward[i] then
			self["normal" .. i]:SetGenericItem(tbShowAward.tbNormalAward[i]);
			self["normal" .. i].fnClick = self["normal" .. i].DefaultClick
			self["normal" .. i].pPanel:SetActive("Main", true);
		end
	end

	for i = 1, 3 do
		self["winner" .. i].pPanel:SetActive("Main", false);
		if tbShowAward and tbShowAward.tbWinnerAward and tbShowAward.tbWinnerAward[i] then
			self["winner" .. i]:SetGenericItem(tbShowAward.tbWinnerAward[i]);
			self["winner" .. i].fnClick = self["winner" .. i].DefaultClick
			self["winner" .. i].pPanel:SetActive("Main", true);
		end
	end

	self.pPanel:Label_SetText("Content", self.szDesc);
	self.pPanel:NpcView_Open("PartnerView");
	self.pPanel:SetActive("SpokespersonTalk", false);
end

function tbUi:UpdateConsumeUi()
	self.pPanel:SetActive("Spend", false)
	self.pPanel:SetActive("Consume", false)
	local nCount = me.GetItemCountInAllPos(BiWuZhaoQin.nReplaceItemId)
	if nCount >= BiWuZhaoQin.nReplaceConsume then
		self.pPanel:SetActive("Consume", true)
		local szItemName = Item:GetItemTemplateShowInfo(BiWuZhaoQin.nReplaceItemId, me.nFaction, me.nSex) or ""
		local szConsumeTip = string.format("%sx%d", szItemName, BiWuZhaoQin.nReplaceConsume)
	else
		self.pPanel:SetActive("Spend", true)
	end
end

function tbUi:ShowChat()
	if self.nChatTimerId then
		Timer:Close(self.nChatTimerId);
		self.nChatTimerId = nil;
	end

	local tbShowInfo = self.tbChat[self.nNpcId];
	if not tbShowInfo or #tbShowInfo < 1 then
		return;
	end

	local szMsg = tbShowInfo[MathRandom(#tbShowInfo)];
	self.pPanel:Label_SetText("TalkContent", szMsg);
	self.pPanel:SetActive("SpokespersonTalk", true);

	if self.nCloseChatTimerId then
		Timer:Close(self.nCloseChatTimerId);
		self.nCloseChatTimerId = nil;
	end

	self.nCloseChatTimerId = Timer:Register(Env.GAME_FPS * self.nStayTime, function ()
		self.nCloseChatTimerId = nil;
		self.pPanel:SetActive("SpokespersonTalk", false);
		self.nChatTimerId = Timer:Register(Env.GAME_FPS * self.nShowTime, function ()
			self.nChatTimerId = nil;
			self:ShowChat();
		end)
	end)
end

function tbUi:OnOpenEnd()
	local _, nResId = KNpc.GetNpcShowInfo(self.nNpcId);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);

	self:CloseAllTimer();
	self:ShowChat();
	self:UpdateConsumeUi()
end

function tbUi:CloseAllTimer()
	if self.nChatTimerId then
		Timer:Close(self.nChatTimerId);
		self.nChatTimerId = nil;
	end

	if self.nCloseChatTimerId then
		Timer:Close(self.nCloseChatTimerId);
		self.nCloseChatTimerId = nil;
	end
end

function tbUi:OnClose()
	self.pPanel:NpcView_Close("PartnerView");
	self:CloseAllTimer();
end

tbUi.tbOnDrag = tbUi.tbOnDrag or {};
tbUi.tbOnDrag.PartnerView = function (self, szWnd, nX, nY)
	self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnEnter = function (self)
	local fnAgree = function ()
		RemoteServer.NpcBiWuZhaoQinAct("Enter");
		Ui:CloseWindow(self.UI_NAME);
	end;
	local nCount = me.GetItemCountInAllPos(BiWuZhaoQin.nReplaceItemId)
	if nCount >= BiWuZhaoQin.nReplaceConsume then
		
		local szItemName = Item:GetItemTemplateShowInfo(BiWuZhaoQin.nReplaceItemId, me.nFaction, me.nSex)
		me.MsgBox(string.format("是否消耗%d个%s参加招亲", BiWuZhaoQin.nReplaceConsume, szItemName or ""), {{"同意", fnAgree}, {"取消"}})
		return
	end
	fnAgree()
end

tbUi.tbOnClick.BtnMatch = function (self)
	RemoteServer.NpcBiWuZhaoQinAct("Match");
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end