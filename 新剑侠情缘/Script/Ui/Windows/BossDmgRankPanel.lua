
local tbUi = Ui:CreateClass("BossDmgRankPanel");

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen(szType, szTitle, szTips, tbRankInfo)
	Log("OnOpen", szType, szTitle, szTips, tbRankInfo)
	self.szType = szType;
	self.szTitle = szTitle;
	self.szTips = szTips;

	

	
end

function tbUi:OnScreenClick(szClickUi)
	if szClickUi ~= self.UI_NAME then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function tbUi:RequestData()
	if self.szType == "ImperialTomb" then
		RemoteServer.ImperialTombEmperorDmgReq()
	end
end

function tbUi:Update(tbRankInfo)
	if tbRankInfo.szTargetName then
		self.pPanel:Label_SetText("OutputTarget", string.format("对%s的伤害输出排名：", tbRankInfo.szTargetName));
	else
		self.pPanel:Label_SetText("OutputTarget", "");
	end

	
	for nI = 1, 5 do
		self.pPanel:Label_SetText("OutputDamage"..nI, "-");
		self.pPanel:Label_SetText("FamilyName"..nI, "-");
		self.pPanel:Sprite_SetFillPercent("OutputBar"..nI, 0);
	end

	local nMaxPercent = nil;
	for nRank, tbInfo in ipairs(tbRankInfo) do
		if not nMaxPercent then
			nMaxPercent = tbInfo[2]
		end
		self.pPanel:Label_SetText("OutputDamage"..nRank, string.format("%s%%",tostring(tbInfo[2])));
		self.pPanel:Label_SetText("FamilyName"..nRank, tbInfo[1]);
		self.pPanel:Sprite_SetFillPercent("OutputBar"..nRank, tbInfo[2] / nMaxPercent);
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_DMG_RANK_UPDATE, self.Update},
	};

	return tbRegEvent;
end