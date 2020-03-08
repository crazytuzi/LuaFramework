-- 抽奖提醒最新消息
local tbNotifyUI = Ui:CreateClass("NewInfo_LotteryNotify");

tbNotifyUI.szContent = 
[[
赠礼资格获得途径：使用[C8FF00][url=openwnd:盟主的馈赠, ItemTips, "Item", nil, 6144][-]（[FFD300][url=openwnd:获得途径, AttributeDescription, '', false, 'Lottery'][-]），本周已使用[C8FF00]%d[-]张。
赠礼资格刷新时间：每周日晚19:30，发奖前使用[C8FF00][url=openwnd:盟主的馈赠, ItemTips, "Item", nil, 6144][-]的数量越多，被盟主青睐的机会越大
]]

tbNotifyUI.tbNpcSetting =
{
	OpenLevel69 = { nId = 32, nScale = 0.73 },
};

function tbNotifyUI:OnOpen()
	local tbRes = self:GetNpcRes();
	if tbRes then
		self.pPanel:NpcView_Open("ShowRole");
		self.pPanel:NpcView_ShowNpc("ShowRole", tbRes.nId);
		self.pPanel:NpcView_SetScale("ShowRole", tbRes.nScale);
	end
	self:RefreshUi()
	self:RefreshTime();
end

function tbNotifyUI:RefreshTime()
	self:CloseTimer();

	local fnRefresh = function ()
		local nCurTime = GetTime();
		local nRemainTime = Lottery:GetDrawTime(nCurTime) - nCurTime;
		self.TitleTime:SetText(string.format("开奖倒计时：[FFD300]%s[-]", Lib:TimeDesc15(nRemainTime)));

		return true;
	end

	fnRefresh();

	local nCurTime = GetTime();
	local nRemainTime = Lottery:GetDrawTime(nCurTime) - nCurTime;
	if nRemainTime > 3600 then
		self.nRefreshTimerId = Timer:Register(Env.GAME_FPS * 60, fnRefresh);
		return;
	end

	self.nRefreshTimerId = Timer:Register(Env.GAME_FPS, fnRefresh);
end

function tbNotifyUI:GetNpcRes()
	local szTimeFrame = Lib:GetMaxTimeFrame(self.tbNpcSetting);
	return self.tbNpcSetting[szTimeFrame];
end

function tbNotifyUI:OnClose()
	self.pPanel:NpcView_Close("ShowRole");
	self:CloseTimer();
end

function tbNotifyUI:CloseTimer()
	if self.nRefreshTimerId then
		Timer:Close(self.nRefreshTimerId);
		self.nRefreshTimerId = nil;
	end
end

function tbNotifyUI:RefreshUi()
	local tbDetail = NewInformation:GetInfoDetail(self.szCurNewInfoKey);
	self.pPanel:Label_SetText("Txt1", tbDetail[2]);
	self.ActiveDetails:SetLinkText(string.format(self.szContent, Lottery:GetTicketCount()));

	local fnRefresh = function (tbRankItem, nRank, nNum)
		tbRankItem.pPanel:Label_SetText("Num", string.format("共%d份", nNum));

		local tbAwardSetting = Lottery:GetAwardSetting(nRank);
		for i = 2, 1, -1 do
			local szItem = "itemframe0" .. i;
			local tbAward = tbAwardSetting[i];
			local bHasAward = tbAward and true or false;
			tbRankItem.pPanel:SetActive(szItem, bHasAward);
			if bHasAward then
				local tbItem = tbRankItem[szItem];
				tbItem:SetGenericItem(tbAward);
				tbItem.fnClick = tbItem.DefaultClick;
			end
		end
	end

	for nRank, tbSetting in ipairs(Lottery.tbRankSetting) do
		local tbRankItem = self["Item0" .. nRank];
		fnRefresh(tbRankItem, nRank, tbSetting.nNum);
	end
	fnRefresh(self["Item05"], -1, Lottery.MAX_JOIN_AWARD_COUNT);
end

-- 抽奖结果最新消息
local tbResultUI = Ui:CreateClass("NewInfo_LotteryResult")
tbResultUI.szContent = 
[[
武林盟主已经选好了本周他所青睐的少侠，恭喜诸位幸运儿。
]]

function tbResultUI:OnOpen(tbData)
	self.tbData = tbData;
	self:RefreshUi();
end

function tbResultUI:RefreshUi()
	local tbDetail = NewInformation:GetInfoDetail(self.szCurNewInfoKey);
	self.pPanel:Label_SetText("Txt1", tbDetail[2]);
	self.pPanel:Label_SetText("Details2", self.szContent);

	local tbData = self.tbData;
	local nSuperCount = 0;
	local szSuperKey = "LotteryItem";
	local tbSuperItem = self[szSuperKey];
	local bHasSuper = false;
	for _, tbInfo in ipairs(tbData) do
		if tbInfo.nRank > 1 then
			break;
		end

		bHasSuper = true;

		tbSuperItem.pPanel:Label_SetText("FamilyName", tbInfo.szKinName or "");
		tbSuperItem.pPanel:Label_SetText("PlayerName", tbInfo.szName);

		for i = 2, 1, -1 do
			local szItem = "itemframe0" .. i;
			local tbAward = tbInfo.tbAward[i];
			local bHasAward = tbAward and true or false;
			tbSuperItem.pPanel:SetActive(szItem, bHasAward);

			if bHasAward then
				local tbItem = tbSuperItem[szItem];
				tbItem:SetGenericItem(tbAward);
				tbItem.fnClick = tbItem.DefaultClick;
			end
		end

		nSuperCount = nSuperCount + 1;
	end

	self.pPanel:SetActive(szSuperKey, bHasSuper);

	local fnSetLuckyGuy = function (tbLuckyBuy, nIndex)
		tbLuckyBuy:RefreshUi(tbData[nSuperCount + nIndex]);
	end
	self.ScrollViewBoss:Update(#tbData - nSuperCount, fnSetLuckyGuy);
end

local tbGrid = Ui:CreateClass("Grid_LotteryResult");

function tbGrid:RefreshUi(tbData)
	self.pPanel:Label_SetText("RewordLevel01", string.format("%s等礼包", Lib:TransferDigit2CnNum(tbData.nRank - 1)))
	self.pPanel:Label_SetText("FamilyName", tbData.szKinName or "");
	self.pPanel:Label_SetText("PlayerName", tbData.szName);

	local tbAward = tbData.tbAward[1];
	local tbItem = self["itemframe"];
	tbItem:SetGenericItem(tbAward);
	tbItem.fnClick = tbItem.DefaultClick;
end
