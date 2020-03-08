local tbUi = Ui:CreateClass("KinBuildings");

function tbUi:Init()
	--Kin:Ask4AllAuctionData();
	Kin:UpdateBuildingData();
	self:Update();
end

local tbBuildingName = {
	[Kin.Def.Building_Main]         = "Zhudian",
	[Kin.Def.Building_Treasure]     = "Jinku",
	[Kin.Def.Building_DrugStore]    = "Yaopinfang",
	[Kin.Def.Building_WeaponStore]  = "Bingjiafang",
	[Kin.Def.Building_FangJuHouse]	= "fangjufang",
	[Kin.Def.Building_ShouShiHouse]	= "Tiangongfang",
	[Kin.Def.Building_War]          = "Zhanzhengfang",
}

function tbUi:Update()
	for nBuildingId, szItemName in pairs(tbBuildingName) do
		self[szItemName]:Init(nBuildingId);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

local tbOpenDir = {
	[Kin.Def.Building_Main]         = "KinBuildingLevelUp",
	[Kin.Def.Building_Treasure]     = "KinVaultPanel",
	[Kin.Def.Building_DrugStore]    = "KinStore",
	[Kin.Def.Building_WeaponStore]  = "EquipMakerPanel",
	[Kin.Def.Building_FangJuHouse]  = "EquipMakerPanel",
	[Kin.Def.Building_ShouShiHouse] = "EquipMakerPanel",
	[Kin.Def.Building_War]          = "KinStore",
}

for nBuildingId, szBtnName in pairs(tbBuildingName) do
	tbUi.tbOnClick[szBtnName] = function (self)
		local nOpenLevel = Kin:GetBuildingLimitLevel(nBuildingId);
		if Kin:GetLevel() < nOpenLevel then
			me.CenterMsg(string.format("%s在主殿%s级后开放", Kin:GetBuildingName(nBuildingId), nOpenLevel));
			return;
		end

		local tbBuildingData = Kin:GetBuildingData(nBuildingId) or {nLevel = 0};
		if Kin:GetBuildingLevel(nBuildingId) <= 0 then
			Ui:OpenWindow("KinBuildingLevelUp", nBuildingId);
			return;
		end

		Ui:OpenWindow(tbOpenDir[nBuildingId], nBuildingId);
	end
end

local tbItem = Ui:CreateClass("KinBuildingItem");

function tbItem:Init(nBuildingId)
	self.nBuildingId = nBuildingId;

	local tbBuildingData = Kin:GetBuildingData(nBuildingId) or {nLevel = 0};
	self.pPanel:Button_SetText("BtnLevelUp", string.format("%d级", tbBuildingData.nLevel));

	local nOpenLevel = Kin:GetBuildingLimitLevel(nBuildingId);
	local bOpen = (Kin:GetLevel() >= nOpenLevel) and tbBuildingData.nLevel > 0;

	self.pPanel:SetActive("NotOpen", not bOpen);
	self.pPanel:Label_SetText("TxtNotOpenTip", (tbBuildingData.nLevel == 0 and Kin:GetLevel() >= nOpenLevel) and "未建造" or "未开放");
	self.pPanel:SetActive("BtnLevelUp", tbBuildingData.nLevel > 0 and Kin:GetLevel() >= nOpenLevel and Kin.Def.BuildingCanUpdate[nBuildingId]);

	local nMaxLevel = Kin:GetBuildingOpenLevel(nBuildingId);
	local nNextLevel = tbBuildingData.nLevel + 1;
	if nNextLevel <= nMaxLevel
		and tbBuildingData.nLevel > 0
		and Kin:CheckMyAuthority(Kin.Def.Authority_Building)
		and Kin:GetLevel() >= nOpenLevel
		and Kin.Def.BuildingCanUpdate[nBuildingId]
		then

		local nUpgradeCost = Kin:GetBuildingUpgradeCost(nBuildingId, nNextLevel);
		self.pPanel:SetActive("LevelUpTip", Kin:GetFound() >= nUpgradeCost);
	else
		self.pPanel:SetActive("LevelUpTip", false);
	end

	local nNow = GetTime();
	if nBuildingId == Kin.Def.Building_Auction then
		self.pPanel:SetActive("opening", false);
		local tbAuctions = Kin:GetAuctionsData();
		for _, tbAuction in pairs(tbAuctions) do
			if tbAuction.bOpen and tbAuction.nStartTime and tbAuction.nStartTime < nNow then
				self.pPanel:SetActive("opening", true);
				break;
			end
		end
	end
end

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:BtnLevelUp()
	Ui:OpenWindow("KinBuildingLevelUp", self.nBuildingId);
end
