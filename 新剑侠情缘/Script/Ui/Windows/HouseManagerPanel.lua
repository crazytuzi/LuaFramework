
local tbUi = Ui:CreateClass("HouseManagerPanel");
tbUi.MAX_ROOMER_COUNT = 6;

tbUi.DESC_COMFORT_PRIVILEGE =
[[
●  家园冥想时基础元气获得[FFFE0D]增加%d%%[-]
●  传功时，传功者和被传功者经验获得[FFFE0D]增加%d%%[-]
]]

tbUi.DESC_ROOMER_PRIVILEGE =
[[
●  房客的家园享有[FFFE0D]%d级[-]舒适等级加成
●  享有在本家园内的拍照功能

]]

tbUi.DESC_ROOMER_INVALID =
[[
[FF6464FF]注：房客特权凌晨4:00以后生效[-]
]]

tbUi.DESC_EXT_COMFORTLEVEL =
[[
[FF6464FF]注：当前你的家园实际享有%d级舒适等级加成[-][00FF00][url=openwnd:了解房客特权, GeneralHelpPanel, "RoomeHelp"][-]
]]

function tbUi:OnOpen()
	self.nExtComfortLevel = House.nExtComfortLevel or 0;
	self.nExtComfortOwnerId = House.nExtComfortOwnerId;
	RemoteServer.TryGetExtComfortLevel();
end

function tbUi:OnOpenEnd()
	self:ResetComfortSelect();

	local bIsInOwnHouse = House:IsInOwnHouse(me);
	local bIsInLivingRoom = House:IsInLivingRoom(me);
	self.pPanel:SetActive("BtnManage", bIsInOwnHouse);
	self.pPanel:SetActive("BtnComfort", bIsInOwnHouse);
	self.pPanel:SetActive("BtnWing", true);
	local tbCanMakeList = Item.tbZhenYuan:GetCanMakeLevelSettingList();
	local bShowZhenYuan = (bIsInLivingRoom or bIsInOwnHouse) and next(tbCanMakeList)
	self.pPanel:SetActive("BtnVitality", bShowZhenYuan and true or false);

	if bIsInOwnHouse and not self.szPanel then
		self.tbOnClick.BtnManage(self);
	elseif bIsInLivingRoom and (not self.szPanel or self.szPanel == "Manage" or self.szPanel == "Comfort") then
		self.tbOnClick.BtnWing(self);
	end

	self.pPanel:Toggle_SetChecked("BtnManage", false);
	self.pPanel:Toggle_SetChecked("BtnComfort", false);
	self.pPanel:Toggle_SetChecked("BtnWing", false);
	self.pPanel:Toggle_SetChecked("BtnVitality", false);
	self.pPanel:Toggle_SetChecked("Btn" .. self.szPanel, true);

	self:Update();

	if self.szPanel == "Vitality" then
		self.Vitality:Update();
	end
end

function tbUi:OnClose()
	self:CloseAllTimer();
	self.Vitality:OnClose();
end

function tbUi:Update()
	local nCurComfort, tbAllInfo = House:GetComfortableShowInfo();
	self.nComfortValue = nCurComfort;
	self.tbMapFurniture = tbAllInfo;
	self.nComfortLevel = House:CalcuComfortLevel(nCurComfort);
	self:RefreshUI();
end

function tbUi:RefreshUI()
	local bIsInOwnHouse = House:IsInOwnHouse(me);
	local bIsInLivingRoom = House:IsInLivingRoom(me);
	if bIsInOwnHouse then
		self:UpdateManagerPanel();
		self:UpdateComfortPanel();
		self:UpdateRoomPanel(true);
	elseif bIsInLivingRoom then
		self:UpdateRoomPanel(false);
	end
end

function tbUi:UpdateManagerPanel()
	self:CloseAllTimer();

	local nMaxLevel, szNextOpenTimeFrame = House:GetMaxOpenHouseLevel();
	local bIsMaxLevel = nMaxLevel == House.nHouseLevel;
	local tbHouseSetting = House.tbHouseSetting[House.nHouseLevel];
	self.pPanel:Label_SetText("HomeLevel", string.format("%d级家园", House.nHouseLevel));

	local szLevelDesc = string.format("[%s]等级上限：%s级[-]", bIsMaxLevel and "FF6464FF" or "00FF00", nMaxLevel);
	if bIsMaxLevel then
		if szNextOpenTimeFrame then
			szLevelDesc = szLevelDesc .. string.format("[FF6464FF](%d天后开放新等级上限)[-]", Lib:GetTimeFrameRemainDay(szNextOpenTimeFrame));
		else
			szLevelDesc = "[FF6464FF]家园已达等级上限[-]";
		end
	end
	self.pPanel:Label_SetText("LevelLimite", szLevelDesc);
	self.pPanel:Label_SetText("NeedTime", string.format("[92D2FF]升级时间：[-]%s", bIsMaxLevel and "--" or Lib:TimeDesc2(tbHouseSetting.nLevelupTime)));
	self.pPanel:Label_SetText("TxtCostMoney", bIsMaxLevel and "--" or tbHouseSetting.nLevelupCost);
	self.pPanel:Label_SetText("Content", tbHouseSetting.szDescription .. string.format("\n●  %s", House:GetFurnitureMakeOpenTips()));

	self.pPanel:SetActive("Shengjiayuan", false);
	self.pPanel:SetActive("LevelUpTime", false);
	self.pPanel:SetActive("BtnLevelUp", true);
	self.pPanel:Button_SetEnabled("BtnLevelUp", not bIsMaxLevel);

	if House.nStartLeveupTime and House.nStartLeveupTime > 0 then
		local nLeftTime = House.nStartLeveupTime + tbHouseSetting.nLevelupTime - GetTime();
		if nLeftTime > 0 then
			self.LevelUpTime:SetLinkText(string.format("[C8FF00]家园正在扩建升级中，剩余：%s[-]", Lib:TimeDesc2(nLeftTime)));
			self.nUpdateLeveupTimerId = Timer:Register(Env.GAME_FPS, function ()
				local nLastTime = House.nStartLeveupTime + tbHouseSetting.nLevelupTime - GetTime();
				if nLastTime <= 0 then
					self.LevelUpTime:SetLinkText("[C8FF00]家园扩建升级已完成，请前往[url=npc:颖宝宝, 2279, 10]处确认[-]");
					self.nUpdateLeveupTimerId = nil;
					return false;
				end

				self.LevelUpTime:SetLinkText(string.format("[C8FF00]家园正在扩建升级中，剩余：%s[-]", Lib:TimeDesc2(nLastTime)));
				return true;
			end);
		else
			self.LevelUpTime:SetLinkText("[C8FF00]家园扩建升级已完成，请前往[url=npc:颖宝宝, 2279, 10]处确认[-]");
		end
		self.pPanel:SetActive("Shengjiayuan", true);
		self.pPanel:SetActive("LevelUpTime", true);
		self.pPanel:SetActive("BtnLevelUp", false);
	end

	for i = 1, 3 do
		local tbAccess = House.tbAccessInfo or {};
		self.pPanel:SetActive("TSprite" .. i, tbAccess[i] and true or false);
	end
end

function tbUi:UpdateComfortPanel()
	self:UpdateComfortValue();
	self:UpdateComfortLevel();
	self:UpdateComfortPrivilege();
	self:UpdateComfortList();
end

function tbUi:UpdateComfortValue()
	local nNextLevel = math.min(self.nComfortLevel + 1, House:GetMaxComfortLevel());
	local tbSetting = House:GetComfortSetting(nNextLevel);
	local nNextComfort = tbSetting.nComfort;
	self.pPanel:Sprite_SetFillPercent("Bar2", math.min(self.nComfortValue / nNextComfort, 1));
	self.pPanel:Label_SetText("BarNumber2", string.format("%d / %d", self.nComfortValue, nNextComfort));
end

function tbUi:UpdateComfortLevel()
	local szCurComfortLevel = string.format("当前舒适等级：%d级", self.nComfortLevel);
	if self.nExtComfortLevel > 0 then
		local bIsLoverHouse = self.nExtComfortOwnerId and Wedding:IsLover(me.dwID, self.nExtComfortOwnerId) or false;
		self.pPanel:Label_SetText("ComfortTip", string.format("[00FF00]＊当前享有%d级舒适等级加成（来自%s的房客特权）[-]", self.nExtComfortLevel, bIsLoverHouse and "伴侣家园" or "寄居家园"));
		self.pPanel:SetActive("ComfortTip", true);
		szCurComfortLevel = szCurComfortLevel .. string.format(" + %d级", self.nExtComfortLevel);
	else
		self.pPanel:SetActive("ComfortTip", false);
	end
	self.pPanel:Label_SetText("ComfortLevel", szCurComfortLevel);
end

function tbUi:UpdateComfortPrivilege()
	local nCurComfortLevel = self.nComfortLevel + self.nExtComfortLevel;
	local tbSetting = House:GetComfortSetting(nCurComfortLevel);
	local nMaxComfortLevel = House:GetMaxComfortLevel();

	local szNextDesc = "[00FF00]舒适等级已达最高等级[-]";
	if nCurComfortLevel < nMaxComfortLevel then
		local tbNextSetting = House:GetComfortSetting(nCurComfortLevel + 1);
		szNextDesc = string.format(self.DESC_COMFORT_PRIVILEGE, House:GetEnergyRatio(tbNextSetting.nEnergy), tbNextSetting.fChuangGongRatio * 100);
	end

	self.pPanel:Label_SetText("CurrentTxt", string.format(self.DESC_COMFORT_PRIVILEGE, House:GetEnergyRatio(tbSetting.nEnergy), tbSetting.fChuangGongRatio * 100));
	self.pPanel:Label_SetText("NextTxt", szNextDesc);
end

function tbUi:UpdateComfortList()
	local tbComfort = House.tbComfortValueLimit[House.nHouseLevel];
	local tbFurniture = Furniture.tbNormalFurniture;
	local tbValidFurnitureTypes = {}
	for nType, tbValue in ipairs(tbFurniture) do
		local nAddCount = House.tbComfortValueLimit[House.nHouseLevel or 1][nType] or 0
		if nAddCount>0 then
			table.insert(tbValidFurnitureTypes, nType)
		end
	end

	local fnSetItem = function (tbItem, i)
		local nType = tbValidFurnitureTypes[i]
		local nTotalCount = tbComfort[nType] or 0;
		local szTypeName = tbFurniture[nType].szName;
		tbItem.pPanel:Label_SetText("Name", string.format("[92D2FF]%s[-]", szTypeName));

		local nCurCount = #(self.tbMapFurniture[nType] or {})
		tbItem.pPanel:Label_SetText("Number", string.format("[%s]（%s/%s）[-]", House:GetFurnitureCountColor(nCurCount, nTotalCount), nCurCount, nTotalCount));

		tbItem.pPanel.OnTouchEvent = function (tbObj)
			if nCurCount <= 0 then
				Ui:AddCenterMsg("家园内未摆放此类型家具");
				return;
			end

			self:ResetComfortSelect();
			self:SelectComfortType(i);
			Ui:OpenWindowAtPos("HouseComfortableDetailsPanle", 28, -2, szTypeName, self.tbMapFurniture[nType], nTotalCount, function ()
				self:ResetComfortSelect();
			end);
		end
	end
	self.ScrollView:Update(#tbValidFurnitureTypes, fnSetItem);
end

function tbUi:SelectComfortType(nType)
	self.nComfortSelectIndex = nType - 1;
	local tbItem = self.ScrollView.Grid["Item" .. self.nComfortSelectIndex];
	if not tbItem then
		return;
	end
	tbItem.pPanel:Sprite_SetSprite("Bg", "ListBgLight");
end

function tbUi:ResetComfortSelect()
	if self.nComfortSelectIndex then
		local tbItem = self.ScrollView.Grid["Item" .. self.nComfortSelectIndex];
		if tbItem then
			tbItem.pPanel:Sprite_SetSprite("Bg", "ListBgDark");
		end
		self.nComfortSelectIndex = nil;
	end
end

function tbUi:UpdateRoomPanel(bIsInOwnHouse)
	self:ResetRoomerSelect();

	local tbSetting = House:GetComfortSetting(self.nComfortLevel);
	local szNotify = nil;
	local bIsInLoverHouse = false;
	if not bIsInOwnHouse then
		bIsInLoverHouse = Wedding:IsLover(me.dwID, House.dwOwnerId);
		if not bIsInLoverHouse and not House:IsValidRoomer(me) then
			szNotify = self.DESC_ROOMER_INVALID;
		elseif self.nExtComfortLevel < tbSetting.nAddLevel then
			szNotify = string.format(self.DESC_EXT_COMFORTLEVEL, self.nExtComfortLevel);
		end
	end

	local szDesc = string.format(self.DESC_ROOMER_PRIVILEGE, tbSetting.nAddLevel);
	if szNotify then
		szDesc = szDesc .. szNotify;
	end
	self.RoomTxt:SetLinkText(szDesc);
	self.pPanel:SetActive("BtnLeave", not bIsInOwnHouse and not bIsInLoverHouse);

	local bMuseOpened = House:IsMuseOpened(me)
	self.pPanel:SetActive("BtnMeditation", bMuseOpened)
	self.pPanel:SetActive("MeditationTime", bMuseOpened)
	if bMuseOpened then
		self.pPanel:Button_SetEnabled("BtnMeditation", DegreeCtrl:GetDegree(me, "Muse") > 0);
		self.pPanel:Label_SetText("MeditationTime", string.format("[92D2FF]剩余冥想次数：[-]%d/%d", DegreeCtrl:GetDegree(me, "Muse"), DegreeCtrl:GetMaxDegree("Muse", me)));
	end

	local bMagicBowlOpened = Furniture.MagicBowl:IsOpened(me)
	local bHasAttr = false
	local tbMagicBowlData = House:GetMagicBowlData(me.dwID)
	if tbMagicBowlData then
		bHasAttr = #tbMagicBowlData.tbNewAttrs > 0
	end
	self.pPanel:SetActive("PrayingTime", bHasAttr and bMagicBowlOpened)
	self.pPanel:SetActive("BtnPraying", bHasAttr and bMagicBowlOpened)
	if bHasAttr and bMagicBowlOpened then
		local nLeftMagicBowlFree, nTotalMagicBowlFree = House:MagicBowlGetPrayFreeCounts(me.dwID)
		self.pPanel:Label_SetText("PrayingTime", string.format("[92D2FF]剩余免费祈福次数：[-]%d/%d", nLeftMagicBowlFree, nTotalMagicBowlFree))
	end

	local bHasLover = House.tbLover and true or false;
	self.pPanel:SetActive("Guest0", bHasLover);
	self.pPanel:SetActive("Guest6", bHasLover);
	self.pPanel:SetActive("Guest1", not bHasLover);

	self.tbRoomer = House.tbRoomer;
	if bHasLover then
		self.tbRoomer[0] = House.tbLover;
	end

	local tbHouseSetting = House.tbHouseSetting[House.nHouseLevel];
	for i = 0, self.MAX_ROOMER_COUNT do
		local nIndex = i;
		local szRoleHead = "Role" .. nIndex;
		local szRoleName = "Name" .. nIndex;
		local szInvite = "InvitationTxt" .. nIndex;
		local szAdd = "BtnAdd" .. nIndex;
		local szLock = "Lock" .. nIndex;
		local szLight = "PitchOn" .. nIndex;
		local szAllow = "Allow" .. nIndex;
		local szRoomNumber = "RoomNumber" .. nIndex;

		local nRealIndex = self:GetRealRoomerIndex(nIndex);
		local tbRoomer = self.tbRoomer[nRealIndex];
		local bHasRoomer = tbRoomer and true or false;
		local bIsOpen = nRealIndex <= tbHouseSetting.nRoomerCount;
		self.pPanel:SetActive(szRoleHead, bHasRoomer);
		self.pPanel:SetActive(szRoleName, bHasRoomer);
		self.pPanel:SetActive(szAdd, bIsOpen and not bHasRoomer);
		self.pPanel:SetActive(szInvite, bIsOpen and not bHasRoomer);
		self.pPanel:SetActive(szLock, not bIsOpen);
		self.pPanel:SetActive(szLight, false);
		self.pPanel:SetActive(szAllow, false);

		if nRealIndex > 0 then
			self.pPanel:Label_SetText(szRoomNumber, string.format("厢房%s", Lib:Transfer4LenDigit2CnNum(nRealIndex)));
		end

		if not bIsOpen then
			self.pPanel:Label_SetText(szLock, string.format("%d级家园开放", nRealIndex + 1));
		end

		if bHasRoomer then
			local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbRoomer.nBigFace, tbRoomer.nPortrait,
				tbRoomer.nFaction, tbRoomer.nSex);
			local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
   			self.pPanel:Sprite_SetSprite(szRoleHead, szBigIcon, szBigIconAtlas);
   			self.pPanel:Label_SetText(szRoleName, tbRoomer.dwPlayerId == me.dwID and string.format("[C8FF00]%s[-]", tbRoomer.szName) or tbRoomer.szName);

   			local bAllow = true;
   			if nRealIndex > 0 then
   				bAllow = House:CheckDecorationAccess(House.dwOwnerId, tbRoomer.dwPlayerId);
   			end
   			self.pPanel:SetActive(szAllow, bAllow);
   		end
	end
end

function tbUi:BtnToggle(nType)
	if nType ~= House.nAccessType_Friend and
		nType ~= House.nAccessType_Kin and
		nType ~= House.nAccessType_Stranger then
		return;
	end

	local tbAccessInfo = House.tbAccessInfo or {};
	RemoteServer.ChangeHouseAccess(nType, not tbAccessInfo[nType]);
end

function tbUi:OnSyncAccess(nType, bAccess)
	self.pPanel:SetActive("TSprite" .. nType, bAccess and true or false);
end

function tbUi:OnSyncHouseInfo()
	self:Update();
end

function tbUi:CloseAllTimer()
	if self.nUpdateLeveupTimerId then
		Timer:Close(self.nUpdateLeveupTimerId);
		self.nUpdateLeveupTimerId = nil;
	end
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_HOUSE_ACCESS,		self.OnSyncAccess },
		{ UiNotify.emNOTIFY_SYNC_HOUSE_INFO, 		self.OnSyncHouseInfo },
		{ UiNotify.emNOTIFY_MAP_LEAVE, 				self.OnLeaveMap },
		{ UiNotify.emNOTIFY_HOUSE_LEVELUP, 			self.Update },
		{ UiNotify.emNOTIFY_CHANGE_MONEY, 			self.RefreshMoney },
		{ UiNotify.emNOTIFY_ZHEN_YUAN_MAKE, 		self.OnMakeResult },
		{ UiNotify.emNOTIFY_SYNC_EXT_COMFORTLEVEL, 	self.OnSyncExtComfortLevel },
	};

	return tbRegEvent;
end

function tbUi:RefreshMoney()
	if self.szPanel ~= "Vitality" then
		return
	end
	self.Vitality:RefreshMoney()
end

function tbUi:OnMakeResult(nItemId)
	if self.szPanel ~= "Vitality" then
		return
	end
	self.Vitality:OnMakeResult(nItemId)
end

function tbUi:ChangePanel(szPanel)
	if self.szPanel and self.szPanel == szPanel then
		return;
	end
	self.szPanel = szPanel;
	self.pPanel:SetActive("Manage", self.szPanel == "Manage");
	self.pPanel:SetActive("Comfort", self.szPanel == "Comfort");
	self.pPanel:SetActive("Wing", self.szPanel == "Wing");
	self.pPanel:SetActive("Vitality", self.szPanel == "Vitality");

	if self.szPanel == "Vitality" then
		self.Vitality:Update();
	end
end

function tbUi:AddRoomer()
	if not House:IsInOwnHouse(me) then
		me.CenterMsg("只有房主才能邀请房客哦");
		return;
	end
	Ui:OpenWindow("HouseInvitePanel");
end

function tbUi:GetRealRoomerIndex(nIndex)
	local nRoomerIndex = nIndex;
	if self.tbRoomer[0] and nIndex ~= 0 then
		nRoomerIndex = nIndex - 1;
	end
	return nRoomerIndex;
end

function tbUi:SelectRoomer(nIndex)
	local nRealIndex = self:GetRealRoomerIndex(nIndex);
	local tbRoomer = self.tbRoomer[nRealIndex];
	if not tbRoomer then
		return;
	end

	self:ResetRoomerSelect();

	self.nRoomerIndex = nIndex;
	self.pPanel:SetActive("PitchOn" .. self.nRoomerIndex, true);

	local tbPos = self.pPanel:GetRealPosition("Guest" .. nIndex);
	Ui:OpenWindowAtPos("RightPopup", tbPos.x + 190, tbPos.y - 320, "HouseRoomerSelect", { dwRoleId = tbRoomer.dwPlayerId, szRoleName = tbRoomer.szName }, function ()
		self:ResetRoomerSelect();
	end);
end

function tbUi:ResetRoomerSelect()
	if self.nRoomerIndex then
		local szLight = "PitchOn" .. self.nRoomerIndex;
		self.pPanel:SetActive(szLight, false);
		self.nRoomerIndex = nil;

		Ui:CloseWindow("RightPopup");
	end
end

function tbUi:OnSyncExtComfortLevel()
	if self.nExtComfortLevel ~= House.nExtComfortLevel or self.nExtComfortOwnerId ~= House.nExtComfortOwnerId then
		self.nExtComfortLevel = House.nExtComfortLevel;
		self.nExtComfortOwnerId = House.nExtComfortOwnerId;
		self:RefreshUI();
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnLevelUp = function (self)
	local nMaxLevel = House:GetMaxOpenHouseLevel();
	if House.nHouseLevel >= nMaxLevel then
		return;
	end

	local tbHouseSetting = House.tbHouseSetting[House.nHouseLevel];
	Ui:OpenWindow("MessageBox", string.format("本次家园升级需花费[FFFE0D]%d元宝[-]\n确定升级吗？", tbHouseSetting.nLevelupCost), {{ function ()
		RemoteServer.HouseStartLevelUp();
	end}, {}});
end

tbUi.tbOnClick.BtnManage = function (self)
	self:ChangePanel("Manage");
end

tbUi.tbOnClick.BtnWing = function (self)
	self:ChangePanel("Wing");
end

tbUi.tbOnClick.BtnComfort = function (self)
	self:ChangePanel("Comfort");
end

tbUi.tbOnClick.BtnVitality = function (self)
	self:ChangePanel("Vitality");
end


tbUi.tbOnClick.BtnMeditation = function (self)
	RemoteServer.TryMuse();
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnPraying = function(self)
	if not House:GetMagicBowlData(me.dwID) then
		me.CenterMsg("没有聚宝盆")
		return
	end
	Ui:OpenWindow("MagicBowlPanel", nil, me.dwID)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnLeave = function (self)
	Ui:OpenWindow("MessageBox", "确定要搬离吗？", {{ function ()
		RemoteServer.CheckOut();
		Ui:CloseWindow(self.UI_NAME);
	end}, {}});
end

for i = 0, tbUi.MAX_ROOMER_COUNT do
	tbUi.tbOnClick["BtnAdd" .. i] = function (self)
		self:AddRoomer();
	end

	tbUi.tbOnClick["Guest" .. i] = function (self)
		self:SelectRoomer(i);
	end
end

for i = 1, 3 do
	tbUi.tbOnClick["Toggle" .. i] = function (self)
		self:BtnToggle(i);
	end
end