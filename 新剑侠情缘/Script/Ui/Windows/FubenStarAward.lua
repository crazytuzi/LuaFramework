local tbUi = Ui:CreateClass("FubenStarAward");

function tbUi:OnOpen(nSectionIdx, nFubenLevel)
	self.nSectionIdx = nSectionIdx;
	self.nFubenLevel = nFubenLevel;

	self:Update();
end

function tbUi:Update()
	local nTotalStar = PersonalFuben:GetSectionTotalStarLevel(me, self.nSectionIdx, self.nFubenLevel);
	local tbSection  = PersonalFuben:GetSectionInfo(self.nSectionIdx, self.nFubenLevel) or {};
	local tbRecord   = PersonalFuben:GetPlayerFubenRecord(me);
	tbRecord.tbStarAward = tbRecord.tbStarAward or {};

	for nIdx = 1, 3 do
		local bCanGet  = nTotalStar >= PersonalFuben.tbStarAwardNum[nIdx];
		local nFlagIdx = PersonalFuben:GetStarFlagIdx(self.nSectionIdx, self.nFubenLevel, nIdx);
		local bHadGet  = tbRecord.tbStarAward[nFlagIdx] and tbRecord.tbStarAward[nFlagIdx] > 0;
		self.pPanel:SetActive("StarComplete" .. nIdx, bHadGet);
		self.pPanel:SetActive("BtnAward".. nIdx, not bHadGet);
		self.pPanel:Button_SetEnabled("BtnAward" .. nIdx, bCanGet);
		self.pPanel:Label_SetText("StarCount" .. nIdx, PersonalFuben.tbStarAwardNum[nIdx]);
		
		local tbAward     = (tbSection.tbAllAward or {})[nIdx] or {};
		local tbAwardInfo = tbAward[1];
		if tbAwardInfo and next(tbAwardInfo) then
			self["itemframe" .. nIdx]:SetGenericItem(tbAwardInfo);
			self["itemframe" .. nIdx].fnClick = self["itemframe" .. nIdx].DefaultClick;

			self.pPanel:SetActive("Available" .. nIdx, bCanGet and not bHadGet);
		else
			self["itemframe" .. nIdx]:Clear();
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClick(nIdx)
	self.pPanel:SetActive("BtnAward" .. nIdx, false);
	self.pPanel:SetActive("Available" .. nIdx, false);
	RemoteServer.TryGetStarAward(self.nSectionIdx, self.nFubenLevel, nIdx);
end

function tbUi:OnGetStarAward(nSectionIdx, nFubenLevel, nAwardIdx)
	self:Update();
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_GET_STAR_AWARD,				self.OnGetStarAward},
    };

    return tbRegEvent;
end

tbUi.tbOnClick = {};
for i = 1, 3 do
	tbUi.tbOnClick["BtnAward" .. i] = function (self) self:OnClick(i) end;
end

tbUi.tbOnClick.BtnClose = function ()
	Ui:CloseWindow("FubenStarAward");
end