
local tbUi = Ui:CreateClass("PersonalFubenSucces");

tbUi.nMaxItemCount = 5;

function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	local tbFuben = PersonalFuben:GetCurFubenInstance();
	local tbCurAward = tbFuben.tbCurAward;
	local nCostTime = tbFuben.tbClientData.nCostTime or tbFuben.tbClientData.nEndTime - tbFuben.tbClientData.nStartTime;
	local nStarLevel = PersonalFuben:CalcFubenStarLevel(tbFuben.nFubenIndex, tbFuben.nFubenLevel, tbFuben.tbClientData);

	local bStartAward = false;
	local tbAllAward = PersonalFuben:GetAwardInfo(tbFuben.tbAllAward);
	local function fnSortAward(a, b)
		return Player:GetAwardValue(a) > Player:GetAwardValue(b);
	end
	table.sort(tbAllAward, fnSortAward);

	self.nSectionIdx, self.nSubSectionIdx = PersonalFuben:GetSectionIdx(tbFuben.nFubenIndex, tbFuben.nFubenLevel);
	local nOldStarLevel = PersonalFuben:GetFubenStarLevel(me, self.nSectionIdx, self.nSubSectionIdx, tbFuben.nFubenLevel);
	if nOldStarLevel < 3 and nStarLevel >= 3 then
		local tbStarAward = (tbFuben.tbStarAward or {})[tbFuben.nFubenLevel];
		for _, tbInfo in pairs(tbStarAward or {}) do
			if tbInfo.nItemId and tbInfo.nItemId > 0 and tbInfo.nCount and tbInfo.nCount > 0 then
				table.insert(tbAllAward, 1, {"item", tbInfo.nItemId, tbInfo.nCount});
				bStartAward = true;
				break;
			end
		end
	end

	self.nFubenLevel = tbFuben.nFubenLevel;

	self.pPanel:SetActive("shengli", true);
	local function fnCloseShengli()
		if Ui:WindowVisible("PersonalFubenSucces") ~= 1 then
			return;
		end

		self.pPanel:SetActive("shengli", false);
	end
	Timer:Register(Env.GAME_FPS * 2.5, fnCloseShengli);

	self.pPanel:Label_SetText("Min", math.floor(nCostTime / 60));
	self.pPanel:Label_SetText("Sce", nCostTime % 60);

	local tbFubenInfo = PersonalFuben:GetPersonalFubenInfo(tbFuben.nFubenIndex);
	local nNeedGatherPoint = tbFubenInfo.tbGatherPoint[tbFuben.nFubenLevel] or 0;
	local nAwardExp = nNeedGatherPoint * me.GetBaseAwardExp();

	local tbOldFubenData = me.tbBeforePersonFuben
	local nOldExpPercent = tbOldFubenData.nOldExpPercent
	self.pPanel:Label_SetText("ExpCount", string.format("+%d", nAwardExp));
	self.pPanel:Label_SetText("PlayerLevel", tbOldFubenData.nOldLevel);
	self.pPanel:ProgressBar_SetValue("ExpInfo", nOldExpPercent);
	self.pPanel:Label_SetText("ExpP", string.format("%s%%", math.floor(nOldExpPercent * 100)));

	self.pPanel:Label_SetText("MoneyInfo", tbCurAward.nCoin or 0);

	local nCurBoxIdx = 1;
	for nIdx, tbAward in pairs(tbAllAward or {}) do
		nCurBoxIdx = nIdx;
		self["itemframe" .. nCurBoxIdx]:SetGenericItem(tbAward);
		self["itemframe" .. nCurBoxIdx].pPanel:SetActive("Main", true);
		self["itemframe" .. nCurBoxIdx].fnClick = self["itemframe" .. nCurBoxIdx].DefaultClick;

		nCurBoxIdx = nCurBoxIdx + 1;
		if nCurBoxIdx > self.nMaxItemCount then
			break;
		end
	end

	self["itemframe1"].pPanel:SetActive("TagTip", bStartAward);

	if bStartAward then
		self["itemframe1"].pPanel:Sprite_SetSprite("TagTip", "itemtag_StarAward");
	end

	for i = nCurBoxIdx, self.nMaxItemCount do
		self["itemframe" .. i]:Clear();
		self["itemframe" .. i].fnClick = nil;
		self["itemframe" .. i].pPanel:SetActive("Main", false);
	end

	self.pPanel:Button_SetEnabled("BtnFightAgain", true);
	self.pPanel:Button_SetEnabled("BtnNext", true);

	self.pPanel:PlayUiAnimation(string.format("PersonalFubenSucces%d", nStarLevel), false, false, {});
end

function tbUi:OnAniEnd(szAniName)
	if string.find(szAniName, "PersonalFubenSucces") then
		local tbOldFubenData = me.tbBeforePersonFuben
		self.pPanel:PlayProgressBarAni("ExpInfo", tbOldFubenData.nOldLevel, me.nLevel, tbOldFubenData.nOldExpPercent, me.GetExp()/me.GetNextLevelExp())
	end
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnClose = function (self)
	PersonalFuben:DoLeaveFuben(false, true);
end

tbUi.tbOnClick.BtnNext = function (self)
	local nNextSectionIdx, nNextSubSectionIdx = PersonalFuben:GetNextFubenSection(self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	local bRet, szMsg, nMapTemplateIdOrErrCode = PersonalFuben:CheckCanCreateFuben(me, nNextSectionIdx, nNextSubSectionIdx, self.nFubenLevel);
	if not bRet then
		local tbParam = {nSectionIdx = nNextSectionIdx, nSubSectionIdx = nNextSubSectionIdx, nFubenLevel = self.nFubenLevel};
		if not PersonalFuben:ProcessErr(me, nMapTemplateIdOrErrCode, tbParam) then
			me.CenterMsg(szMsg);
		end
		return;
	end

	RemoteServer.TryCreatePersonalFuben(nNextSectionIdx, nNextSubSectionIdx, self.nFubenLevel);

	self.pPanel:Button_SetEnabled("BtnNext", false);
	self.pPanel:Button_SetEnabled("BtnFightAgain", false);
	Ui:CloseWindow("PersonalFubenSucces");
end

tbUi.tbOnClick.BtnFightAgain = function (self)
	local bRet, szMsg, nMapTemplateIdOrErrCode = PersonalFuben:CheckCanCreateFuben(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	if not bRet then
		local tbParam = {nSectionIdx = self.nSectionIdx, nSubSectionIdx = self.nSubSectionIdx, nFubenLevel = self.nFubenLevel};
		if not PersonalFuben:ProcessErr(me, nMapTemplateIdOrErrCode, tbParam) then
			me.CenterMsg(szMsg);
		end
		return;
	end

	RemoteServer.TryCreatePersonalFuben(self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);

	self.pPanel:Button_SetEnabled("BtnNext", false);
	self.pPanel:Button_SetEnabled("BtnFightAgain", false);
	Ui:CloseWindow("PersonalFubenSucces");
end

function tbUi:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_ANIMATION_FINISH, self.OnAniEnd, self},
    };
end