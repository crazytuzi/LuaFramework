local tbUi = Ui:CreateClass("MapLoading");
local function Load()
	tbUi.tbAllTips = LoadTabFile("Setting/LoadingTips.tab", "dss", nil, {"nLevel", "szTimeFrame", "szTips"});
	tbUi.tbAllTimeFrame = {};
	for _, tbRow in pairs(tbUi.tbAllTips) do
		tbUi.tbAllTimeFrame[tbRow.szTimeFrame] = 0;
	end
end
Load();

tbUi.tbShowMinIcon = {
	["UI/Textures/Loading/Loading_wuxing.jpg"] = 1,
}

tbUi.tbFactionInfo = {
	[1] = "Faction_TianWang",		--天王
	[2] = "Faction_Emei",			--峨嵋
	[3] = "Faction_TaoHua",			--桃花
	[4] = "Faction_XiaoYao",		--逍遥
	[5] = "Faction_WuDang",			--武当
	[6] = "Faction_TianRen",		--天忍
	[7] = "Faction_ShaoLin",			--少林
	[8] = "Faction_CuiYan",		--翠烟
	[8] = "Faction_TangMen",			--唐门
	[10] = "Faction_KunLun",		--昆仑
}

function tbUi:UpdateTips()
	local nLevel = 0;
	local dwMeId = 0;
	if me then
		dwMeId = me.dwID or 0;
		nLevel = me.nLevel or 0;
	end

	if self.nPlayerId and self.nPlayerId == dwMeId and self.nLastUpdateTime and GetTime() - self.nLastUpdateTime <= 3600 * 12 then
		return;
	end

	self.tbAllowTimeFrame = {};
	for szTimeFrame in pairs(self.tbAllTimeFrame) do
		if szTimeFrame == "OpenLevel39" or GetTimeFrameState(szTimeFrame) == 1 then
			self.tbAllowTimeFrame[szTimeFrame] = 1;
		end
	end

	self.nPlayerId = dwMeId;
	self.nLastUpdateTime = GetTime();
	self.tbCurTips = {};
	for _, tbRow in pairs(self.tbAllTips) do
		if tbRow.nLevel <= nLevel and self.tbAllowTimeFrame[tbRow.szTimeFrame] then
			table.insert(self.tbCurTips, tbRow.szTips);
		end
	end
end

function tbUi:GetTips()
	self:UpdateTips();
	if not self.tbCurTips or #self.tbCurTips <= 0 then
		return "";
	end

	return self.tbCurTips[MathRandom(#self.tbCurTips)];
end

function tbUi:OnOpen(nMapTemplateId, nCurMapTemplateId)
	local tbDstMapInfo = Map.tbMapList[nMapTemplateId or -1];
	local tbCurMapInfo = Map.tbMapList[nCurMapTemplateId or -1];
	if tbDstMapInfo and tbCurMapInfo and tbDstMapInfo.ResName == tbCurMapInfo.ResName then
		return 0;
	end
end

function tbUi:OnOpenEnd(nMapTemplateId, nCurMapTemplateId)
	self.nMapTemplateId = nMapTemplateId;
	local szTips = self:GetTips();
	if szTips then
		self.pPanel:Label_SetText("Tips", szTips);
	end
	self.pPanel:Tween_ProgressBarWhithCallback("Percent", 0.4, 0.99, 2, function () end);
end

function tbUi:OnClose()
	local szTexture = Map:GetLoadingTexture();
	local szIcon;

	if me and tbUi.tbShowMinIcon[szTexture] then
		szIcon = tbUi.tbFactionInfo[me.nFaction];
	end
	self.pPanel:SetActive("SpecialSprite", szIcon and true or false);
	self.pPanel:SetActive("Logo", not szIcon);
	if szIcon then
		self.pPanel:Sprite_SetSprite("SpecialSprite", szIcon);
	end
	self.pPanel:Texture_SetTexture("bg", szTexture);
end
