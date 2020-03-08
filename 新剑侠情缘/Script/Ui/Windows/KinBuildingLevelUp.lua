local tbUi = Ui:CreateClass("KinBuildingLevelUp");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
	};

	return tbRegEvent;
end

function tbUi:OnOpenEnd(nBuildingId)
	self.pPanel:SetActive("LevelUpEffect", false);
	self.nCurBuildingId = nBuildingId or Kin.Def.Building_Main;
	self:InitSideBar();

	local tbUserSet = Ui:GetPlayerSetting();
	self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice);
end

function tbUi:UpdateData(szType)
	if szType == "Building" then
		self:InitSideBar();
	end
end

local tbLevelUpBuildings = {
	Kin.Def.Building_Main,
	Kin.Def.Building_War,
	Kin.Def.Building_Treasure,
	Kin.Def.Building_DrugStore,
	Kin.Def.Building_WeaponStore,
	Kin.Def.Building_FangJuHouse,
	Kin.Def.Building_ShouShiHouse,
};

function tbUi:InitSideBar()
	local tbItems = {};
	local nKinLevel = Kin:GetLevel();
	for _, nBuildingId in ipairs(tbLevelUpBuildings) do
		local nOpenLevel = Kin:GetBuildingLimitLevel(nBuildingId);
		if nKinLevel >= nOpenLevel then
			table.insert(tbItems, nBuildingId);
		end
	end

	local fnOnSelect = function (btnObj)
		Kin:UpdateBaseInfo();
		self:Update(btnObj.nBuildingId);
	end

	local bTouchCurBuilding = true;
	local fnSetItem = function (itemObj, nIdx)
		local nBuildingId = tbItems[nIdx];
		local szBuildingName = Kin:GetBuildingName(nBuildingId);
		itemObj.nBuildingId = nBuildingId;
		itemObj.pPanel:Label_SetText("DarkName", szBuildingName);
		itemObj.pPanel:Label_SetText("LightName", szBuildingName);
		itemObj.pPanel.OnTouchEvent = function (btnObj)
			fnOnSelect(btnObj);
			Guide.tbNotifyGuide:ClearNotifyGuide("KinBuildUpgrade");
		end

		itemObj.pPanel:SetActive("Tip", false);
		local tbBuildingData = Kin:GetBuildingData(nBuildingId);
		if not tbBuildingData then
			Log("[x] KinBuildingLevelUp, tbBuildingData nil", nBuildingId, me.dwKinId)
			return
		end
		local nMaxLevel = Kin:GetBuildingOpenLevel(nBuildingId);
		local bHasAuthority = Kin:CheckMyAuthority(Kin.Def.Authority_Building);

		if tbBuildingData.nLevel < nMaxLevel and bHasAuthority then
			local nUpgradeCost = Kin:GetBuildingUpgradeCost(nBuildingId, tbBuildingData.nLevel + 1);
			if Kin:GetFound() >= nUpgradeCost then
				itemObj.pPanel:SetActive("Tip", true);
			end
		end

		if bTouchCurBuilding and self.nCurBuildingId == nBuildingId then
			bTouchCurBuilding = nil;
			itemObj.pPanel:Toggle_SetChecked("Main", true);
			fnOnSelect(itemObj);
		end
	end

	self.BtnScrollView:Update(#tbItems, fnSetItem);
end

local tbBuildingPic = {
	[Kin.Def.Building_Main]         = "TextureZhudian";
	[Kin.Def.Building_Auction]      = "TexturePaimaihang";
	[Kin.Def.Building_Treasure]     = "TextureJinku";
	[Kin.Def.Building_DrugStore]    = "TextureYaopinfang";
	[Kin.Def.Building_WeaponStore]  = "TextureBingjiafang";
	[Kin.Def.Building_FangJuHouse]  = "TexturePaimaihang";
	[Kin.Def.Building_ShouShiHouse] = "TextureTiangongfang";
	[Kin.Def.Building_War]          = "TextureZhanzhengfang";
}

function tbUi:Update(nBuildingId)
	self.nCurBuildingId = nBuildingId or self.nCurBuildingId;

	local tbBuildingData = Kin:GetBuildingData(self.nCurBuildingId);
	self.nNextLevel = tbBuildingData.nLevel + 1;
	local nFound = Kin:GetFound();
	local nUpgradeCost, nDiscountRate = Kin:GetBuildingUpgradeCost(self.nCurBuildingId, self.nNextLevel);

	self.nDiscountRate = nDiscountRate;
	self.pPanel:Button_SetText("BtnLevelUp", tbBuildingData.nLevel == 0 and "建造" or "升级");
	self.pPanel:Label_SetText("TxtCurFound", nFound);
	self.pPanel:Label_SetText("TxtCostFound", nUpgradeCost);
	self.pPanel:Sprite_SetSprite("Building", tbBuildingPic[self.nCurBuildingId]);

	local szDesc = self:GetUpgradeDesc(self.nCurBuildingId, self.nNextLevel);
	self.pPanel:Label_SetText("TxtFamilyUpgradeDesc", szDesc);

	local szBuildingName = Kin:GetBuildingName(self.nCurBuildingId);
	local szBuildingFullName = string.format("%d级%s", tbBuildingData.nLevel, szBuildingName);
	self.szBuildingName = szBuildingName;
	self.pPanel:Label_SetText("TxtBuildingFullName", tbBuildingData.nLevel > 0 and szBuildingFullName or szBuildingName);

	local bCanUpgrade, szUpgradeRequirement = self:GetUpgradeRequirement(self.nCurBuildingId, self.nNextLevel);
	self.pPanel:Label_SetText("TxtUpgradeRequirementGreen", szUpgradeRequirement);
	self.pPanel:Label_SetText("TxtUpgradeRequirementRed", szUpgradeRequirement);
	self.pPanel:SetActive("TxtUpgradeRequirementRed", not bCanUpgrade);
	self.pPanel:SetActive("TxtUpgradeRequirementGreen", bCanUpgrade);
end

function tbUi:GetUpgradeDesc(nBuildingId, nNextLevel)
	local tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nNextLevel)
	if not tbBuildingInfo then
		tbBuildingInfo = Kin:GetBuildingInfo(nBuildingId, nNextLevel-1) or {}
	end
	local szDesc = tbBuildingInfo.szDesc or "";
	if nBuildingId==Kin.Def.Building_FangJuHouse or nBuildingId==Kin.Def.Building_WeaponStore or nBuildingId==Kin.Def.Building_ShouShiHouse then
		local nNextOpenDay, nNextQuality = Shop:EquipMakerGetNextQualityInfo()
		if nNextOpenDay then
			szDesc = string.format("%s\n●  [FFFE0D]%d天后[-] 开放打造 [FFFE0D]%d阶装备[-]",
				szDesc, nNextOpenDay, nNextQuality)
		else
			local nCurQuality = Shop:EquipMakerGetCurMaxQuality()
			szDesc = string.format("%s\n●  当前打造已开放至 [FFFE0D]%d阶装备[-]", szDesc, nCurQuality)
		end
	end

	if self.nDiscountRate<1 and self.nDiscountRate>0 then
		local tbBuildingData = Kin:GetBuildingData(nBuildingId)
		local szAction = tbBuildingData.nLevel==0 and "建造" or "升级"
		local szBuildingName = Kin:GetBuildingName(nBuildingId)
		szDesc = string.format("%s\n●  [FFFE0D]%s[-] 低于当前作坊等级上限，%s所需的建设资金为原来的 [FFFE0D]%d%%[-]",
			szDesc, szBuildingName, szAction, self.nDiscountRate * 100);
	end
	return string.gsub(szDesc, "\\n", "\n");
end

function tbUi:GetUpgradeRequirement(nBuildingId, nNextLevel)
	local nOpenLevel, szNextLevelTimeFrame = Kin:GetBuildingOpenLevel(nBuildingId);
	local bCanLevelup, nMainBuildeRequre = Kin:CanLevelUp(nBuildingId, nNextLevel, Kin:GetLevel());
	local nMaxLevel = Kin:GetBuildingMaxLevel(nBuildingId);
	local szRequire = string.format("需主殿达到%d级", nMainBuildeRequre);

	if nBuildingId == Kin.Def.Building_Main then
		szRequire = string.format("当前等级上限：%s级", nOpenLevel);

		if not bCanLevelup and szNextLevelTimeFrame then
			local nOpenTime = CalcTimeFrameOpenTime(szNextLevelTimeFrame);
			local nNexDay = Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay();
			local szTip = "即将";
			if nNexDay > 0 then
				szTip = nNexDay .. "天后"
			end
			szRequire = string.format("%s (%s开放新等级上限)", szRequire, szTip);
		end
	end

	if nNextLevel > nMaxLevel then
		szRequire = "达到最大等级";
	end

	if nNextLevel == 1 then
		bCanLevelup = false;
		szRequire = "未建造";
	end

	return bCanLevelup, szRequire;
end


tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
	Guide.tbNotifyGuide:ClearNotifyGuide("KinBuildUpgrade");
end

function tbUi.tbOnClick:BtnLevelUp()
	if not Kin:CheckMyAuthority(Kin.Def.Authority_Building) then
		me.CenterMsg("没有相应权限");
		return;
	end

	local nUpgradeCost = Kin:GetBuildingUpgradeCost(self.nCurBuildingId, self.nNextLevel);
	if Kin:GetFound() < nUpgradeCost then
		me.CenterMsg("资金不足以支付建造费用");
		return;
	end

	local nMaxLevel = Kin:GetBuildingOpenLevel(self.nCurBuildingId);
	if self.nNextLevel > nMaxLevel then
		me.CenterMsg("已达到当前最大等级");
		return;
	end

	local nOpenLevel = Kin:GetBuildingLimitLevel(self.nCurBuildingId);
	if Kin:GetLevel() < nOpenLevel then
		me.CenterMsg("未开启");
		return;
	end

	local fnAgree = function ()
		Kin:BuildingUpgrade(self.nCurBuildingId);
		self.pPanel:SetActive("LevelUpEffect", false);
		self.pPanel:SetActive("LevelUpEffect", true);
		Ui:CloseWindow("MessageBox");
	end

	local fnCancel = function ()
		Ui:CloseWindow("MessageBox");
	end

	local szInfo = self.nNextLevel > 1 and "确定要提升 [FFFE0D]%s[-] 等级吗？" or "确定要建造 [FFFE0D]%s[-] 吗？";
	Ui:OpenWindow("MessageBox",
		string.format(szInfo , Kin:GetBuildingName(self.nCurBuildingId)),
		{{fnAgree}, {fnCancel}},
		{"确定", "取消"});
end

function tbUi.tbOnClick:BtnVoice()
	ChatMgr:OnSwitchNpcGuideVoice()
end