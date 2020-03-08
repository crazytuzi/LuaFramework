
local tbUi = Ui:CreateClass("PersonalFubenEntrance");
tbUi.nMaxItemCount = 6;

function tbUi:OnOpen(nSectionIdx, nSubSectionIdx, nFubenLevel)
	self.nFubenLevel = nFubenLevel;
	self.nSectionIdx = nSectionIdx;
	self.nSubSectionIdx = nSubSectionIdx;

	self:Update();
end

function tbUi:Update()
	local tbSection = PersonalFuben:GetSectionInfo(self.nSectionIdx, self.nFubenLevel);
	local tbSectionInfo = tbSection.tbSectionInfo[self.nSubSectionIdx];

	local tbFubenInfo = PersonalFuben:GetPersonalFubenInfo(tbSectionInfo.nFubenIndex);
	local tbTimesData = PersonalFuben:GetFubenTimesData(me, tbSectionInfo.nFubenIndex, self.nFubenLevel);
	local nSweepItemCount = me.GetItemCountInAllPos(PersonalFuben.PERSONAL_SWEEP_COST_ITEM);

	self.pPanel:Label_SetText("SweepItemCount", nSweepItemCount);
	self.pPanel:Label_SetText("SectionName", string.format("%d_%d %s", self.nSectionIdx, self.nSubSectionIdx, tbSectionInfo.szTitle));
	self.pPanel:Label_SetText("FubenDesc", tbFubenInfo.szDesc);
	self.pPanel:Label_SetText("NeedGatherPoint", tbFubenInfo.tbGatherPoint[self.nFubenLevel]);
	self.pPanel:Label_SetText("NeedLevel", tbFubenInfo.nNeedLevel);
	self.pPanel:Label_SetText("LastCount", tbTimesData.nLastAvailable or 0);
	self.pPanel:Label_SetText("TimeLimite", tbFubenInfo.nTimeLimite);

	local nRecommend = tbFubenInfo.tbRecommendEdge[self.nFubenLevel] or 0;
	local nMyFightPower = me.GetNpc().GetFightPower() or 0;
	self.pPanel:Label_SetText("RecommendEdge", string.format("%s / %s", nMyFightPower, nRecommend));
	self.pPanel:Sprite_SetFillPercent("BarRed", nMyFightPower >= nRecommend and 1 or (nMyFightPower / nRecommend));
	self.pPanel:SetActive("BarGreen", nMyFightPower >= nRecommend);

	local nStarLevel = PersonalFuben:GetFubenStarLevel(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	for i = 1, 3 do
		local szSprite = "Star_02";
		if i <= nStarLevel then
			szSprite = "Star_01";
		end

		self.pPanel:Sprite_SetSprite("star_" .. i, szSprite);
	end

	local tbExtAward = ((Fuben.tbFubenTemplate[tbFubenInfo.nMapTemplateId or -1] or {}).tbStarAward or {})[self.nFubenLevel];
	local tbAward;
	for _, tbInfo in pairs(tbExtAward or {}) do
		if tbInfo.nItemId > 0 then
			tbAward = {"item", tbInfo.nItemId, tbInfo.nCount};
		elseif tbInfo.SubType and tbInfo.SubType ~= "" then
			tbAward = {tbInfo.szType, tbInfo.SubType, tbInfo.nCount};
		else
			tbAward = {tbInfo.szType, tbInfo.nCount};
		end
	end
	self.pPanel:SetActive("FirstAward", tbAward and true or false);
	self["itemframeAward"].fnClick = self["itemframeAward"].DefaultClick;
	self["itemframeAward"]:SetGenericItem(tbAward);
	self.pPanel:SetActive("HaveReceived", nStarLevel >= 3);

	local tbFubenTemplate = Fuben.tbFubenTemplate[tbFubenInfo.nMapTemplateId or -1] or {};
	local tbAllAward = tbFubenTemplate.tbAllAward or {};
	local tbAward = tbAllAward[self.nFubenLevel] or {};

	for i = 1, self.nMaxItemCount do
		if tbAward[i] then
			self["itemframe" .. i]:SetGenericItem(tbAward[i]);
			self["itemframe" .. i].fnClick = self["itemframe" .. i].DefaultClick;
		else
			self["itemframe" .. i]:Clear();
			self["itemframe" .. i].fnClick = nil;
		end
	end
end

function tbUi:Sweep(bConfirm)
	local bRet, szMsg, nFubenIndexOrErrCode, pItem, nNeedGold, nAvailableTimes, bUseGold = PersonalFuben:CheckCanSweep(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	local tbParam = {nSectionIdx = self.nSectionIdx, nSubSectionIdx = self.nSubSectionIdx, nFubenLevel = self.nFubenLevel};
	if not bRet then
		if not PersonalFuben:ProcessErr(me, nFubenIndexOrErrCode, tbParam) then
			me.CenterMsg(szMsg or "未知原因，无法扫荡！");
		end
		return;
	end

	if bUseGold then
		PersonalFuben:ProcessErr(me, PersonalFuben.tbErr.SweepItem_Err, tbParam);
		return;
	end

	Ui:OpenWindow("ShowAward")
	RemoteServer.TrySweep(self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	Timer:Register(Env.GAME_FPS * 2, self.Update, self);
end

function tbUi:MultiSweep(bConfirm)
	local bRet, szMsg, nAvailableTimesOrErrCode, bUseGold = PersonalFuben:CheckMultiSweep(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	local tbParam = {nSectionIdx = self.nSectionIdx, nSubSectionIdx = self.nSubSectionIdx, nFubenLevel = self.nFubenLevel, nSweepTimes = nAvailableTimesOrErrCode};
	if not bRet then
		if not PersonalFuben:ProcessErr(me, nAvailableTimesOrErrCode, tbParam) then
			me.CenterMsg(szMsg or "未知原因，无法扫荡！");
		end
		return;
	end

	if bUseGold then
		PersonalFuben:ProcessErr(me, PersonalFuben.tbErr.SweepItem_Err, tbParam);
		return;
	end

	Ui:OpenWindow("ShowAward")
	RemoteServer.TryMultiSweep(self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	Timer:Register(Env.GAME_FPS * 2, self.Update, self);
end

function tbUi:OnFubenTimesChange(nFubenIndex, nFubenLevel)
	self:Update();
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_PERSONALFUBEN_TIMES_CHANGE,      	self.OnFubenTimesChange},
    };

    return tbRegEvent;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnBack = function (self)
	Ui:CloseWindow("PersonalFubenEntrance");
end

tbUi.tbOnClick.BtnJoinFuben = function (self)

	local function TryJoinFuben(tbHelperInfo)
		if PersonalFuben:CheckCanCreateFuben(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel) then
			Ui:CloseWindow("PersonalFubenEntrance");
		end
		Fuben:JoinPersonalFuben(self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel, tbHelperInfo);
	end

	if self.nFubenLevel == PersonalFuben.PERSONAL_LEVEL_ELITE then
		Ui:OpenWindow("HelperList", TryJoinFuben)
	else
		TryJoinFuben();
	end
end

tbUi.tbOnClick.BtnSweep = function (self)
	self:Sweep();
end

tbUi.tbOnClick.BtnSweep10 = function (self)
	self:MultiSweep();
end

