
local tbUi = Ui:CreateClass("MissionAward");
tbUi.MAX_CELL_COUNT = 16;
tbUi.MAX_GAIN_COUNT = 5;
tbUi.tbAni = {
	{20, 1},	
	{30, 2},	
	{35, 3},	
	{37, 4},	
	{40, 5},
};
tbUi.nMaxCount = tbUi.tbAni[#tbUi.tbAni][1];

function tbUi:OnOpen(szTitle, nType, nRecordId, nGrade, tbAwardPos, tbAllAward)
	if not nRecordId then
		self:Clear();
		return;
	end

	self.szTitle = szTitle;
	self.nType = nType;
	self.nRecordId = nRecordId;
	self.nGrade = nGrade;
	self.tbAwardPos = tbAwardPos;
	self.tbAllAward = tbAllAward;
	self:UpdateMissionAward();
end

function tbUi:Clear()
	self.nType = nil;
	self.tbAwardPos = nil;
	self.tbAllAward = nil;
	self.tbRecord = nil;
	for i = 1, self.MAX_CELL_COUNT do
		self["itemframe" .. i]:Clear();
	end
end

function tbUi:UpdateMissionAward()
	for i = 1, 6 do
		self.pPanel:SetActive("AwardLevel" .. i, self.nGrade == i);
	end

	self.pPanel:Label_SetText("CountInfo", string.format("%s / %s", #self.tbAwardPos, MissionAward:GetMaxAwardTimes(me, self.nType)));
	self.pPanel:Label_SetText("SectionName", self.szTitle or "--");
	for i = 1, self.MAX_CELL_COUNT do
		local tbAward = self.tbAllAward[i];
		if not tbAward then
			self["itemframe" .. i]:Clear();
		else
			if tbAward.szType and tbAward.szType ~= "" then
				self["itemframe" .. i]:SetDigitalItem(tbAward.szType, tbAward.nCount);
			else
				self["itemframe" .. i]:SetItemByTemplate(tbAward.nItemId, nil, me.nFaction);
			end
			self["itemframe" .. i].fnClick = self["itemframe" .. i].DefaultClick;
		end
	end

	for i = 1, self.MAX_GAIN_COUNT do
		if i <= #self.tbAwardPos then
			self["itemframe" .. self.tbAwardPos[i]]:Clear();
	
			local tbAward = self.tbAllAward[self.tbAwardPos[i]];
			if tbAward then
				if tbAward.szType and tbAward.szType ~= "" then
					self["Award" .. i]:SetDigitalItem(tbAward.szType, tbAward.nCount);
				else
					self["Award" .. i]:SetItemByTemplate(tbAward.nItemId, nil, me.nFaction);
				end
				self["Award" .. i].fnClick = self["Award" .. i].DefaultClick;
			end
		else
			self["Award" .. i]:Clear();
		end
	end

	self.pPanel:Button_SetEnabled("BtnGetAward", #self.tbAwardPos < self.MAX_GAIN_COUNT);
	self:HightLine(self.tbAwardPos[#self.tbAwardPos]);
end

function tbUi:UpdateInfo(nType, nRecordId, tbAwardPos)
	if self.nType ~= nType or self.nRecordId ~= nRecordId then
		return;
	end

	self.tbAwardPos = tbAwardPos;
	self:UpdateMissionAward();
end

function tbUi:OnGetAwardPos(nPos)
	self.nDesPos = nPos;
	self:StartAni(nPos);
end

function tbUi:HightLine(nPos)
	nPos = nPos or 0;
	for i = 1, self.MAX_CELL_COUNT do
		self.pPanel:SetActive("HightLine" .. i, i == nPos);
	end
end

function tbUi:StartAni(nPos, nCurIdx)
	nCurIdx = nCurIdx or 1;
	if nCurIdx < self.nMaxCount then

		-- 尽可能不随到已经拿过的物品
		local nNextPos = MathRandom(self.MAX_CELL_COUNT);
		for i = 1, 10 do
			if self["itemframe" .. nNextPos].nTemplate then
				break;
			end

			nNextPos = MathRandom(self.MAX_CELL_COUNT);
		end

		local nTime = 1;
		for _, tbInfo in ipairs(self.tbAni) do
			if nCurIdx <= tbInfo[1] then
				nTime = tbInfo[2];
				break;
			end
		end
		self:HightLine(nNextPos);
		Timer:Register(nTime, self.StartAni, self, nPos, nCurIdx + 1);
	else
		self:HightLine(nPos);
		self:OnEndAin();
	end
end

function tbUi:OnEndAin()
	if not self.nType or not self.nRecordId then
		return;
	end

	RemoteServer.CallMissionAwardFunc("GetAward", self.nType, self.nRecordId);
end

function tbUi:AskConsumeItem(nGold)
	if not nGold then
		Log("[MissionAward] AskConsumeItem ERR ?? nGold is nil", self.nType, #self.tbAwardPos);
		return;
	end

	local _, szMoneyEmotion = Shop:GetMoneyName("Gold");
	local szConsumeName = string.format("%s%s", nGold, szMoneyEmotion);
	local szMsg = string.format("已经没有免费抽奖次数，继续抽奖需花费%s，是否进行抽奖？", szConsumeName);
	me.MsgBox(szMsg, {{"确认", self.DoGetMoreAward, self, nGold}, {"放弃"}}, "MissionAwardUseGold");
	self.pPanel:Button_SetEnabled("BtnGetAward", true);
end

function tbUi:DoGetMoreAward(nGold)
	if nGold and me.GetMoney("Gold") < nGold then
		Timer:Register(1, function() me.MsgBox("元宝不足，是否前去充值？", {{"确认", Ui.OpenWindow, Ui, "CommonShop", "Recharge", "Recharge"}, {"取消"}}) end);
		return;
	end

	self.pPanel:Button_SetEnabled("BtnGetAward", false)
	RemoteServer.CallMissionAwardFunc("AddAwardIdx", self.nType, self.nRecordId)
end

function tbUi:OnGetResult(bResult, nValue)
	if bResult then
		self:OnGetAwardPos(nValue);
	else
		self:AskConsumeItem(nValue);
	end
end

function tbUi:OnMissionUpdate(nType, nRecordId, tbAwardPos)
	self:UpdateInfo(nType, nRecordId, tbAwardPos);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_MISSION_AWARD_ONRESULT, self.OnGetResult, 		self },
		{ UiNotify.emNOTIFY_MISSION_AWARD_UPDATE, 	self.OnMissionUpdate, 	self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnGetAward = function (self)
	if not self.nType or not self.nRecordId then
		return;
	end

	local nMaxAwardCount = MissionAward:GetMaxAwardTimes(me, self.nType);
	if #self.tbAwardPos >= nMaxAwardCount then
		me.CenterMsg("已达抽奖最大次数！");
		self.pPanel:Button_SetEnabled("BtnGetAward", false);
		return;
	end

	RemoteServer.CallMissionAwardFunc("GetAwardInfo", self.nType, self.nRecordId);
	self.pPanel:Button_SetEnabled("BtnGetAward", false);
end

tbUi.tbOnClick.BtnLeave = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

