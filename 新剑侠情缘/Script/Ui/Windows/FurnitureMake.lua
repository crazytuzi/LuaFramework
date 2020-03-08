
local tbUi = Ui:CreateClass("FurnitureMake");

tbUi.nAniTime = 4;
function tbUi:OnOpen()
	self.pPanel:SetActive("AniBg", true);
	self.pPanel:NpcView_Open("ShowRole");
	self.pPanel:NpcView_ShowNpc("ShowRole", 20000);

	self.bOnlyShowCanMake = nil;
	self.pPanel:SetActive("SpOnlyShowCanMake", self.bOnlyShowCanMake and true or false);

	local nType, nItemId = nil, nil;
	if self.nShowPlayerId and self.nShowPlayerId == me.dwID then
		nType = self.nCurType;
		nItemId = self.nFurnitureItemId;
	end

	self:UpdateFurnitureList(nType, nItemId);
	self:UpdateFurnitureTypeList()
end

function tbUi:OnClose()
	self:CloseAllTimer();
	self.pPanel:NpcView_Close("ShowRole");
end

function tbUi:UpdateFurnitureList(nType, nItemId)
	self.nCurType = nType or 1;
	self.pPanel:Label_SetText("BtnSelectLabel", Furniture:GetTypeName(self.nCurType));

	local tbShowInfo = self:GetShowTypeInfo(self.nCurType);

	local function fnSetItem(itemObj, index)
		local nItemId = tbShowInfo[index][1];
		local tbFurniture = tbShowInfo[index][2];

		local szName = Item:GetItemTemplateShowInfo(nItemId);
		itemObj.nItemId = nItemId;
		itemObj.itemframe:SetItemByTemplate(nItemId, 0);
		itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick;

		itemObj.pPanel:Label_SetText("Name", szName);
		itemObj.pPanel:Label_SetText("Number", tbFurniture.nLevel);
		itemObj.pPanel:Button_SetCheck("Main", nItemId == self.nFurnitureItemId);
		itemObj.pPanel.OnTouchEvent = function ()
			self:UpdateFurniture(nItemId);
		end
	end

	self.pPanel:SetActive("ScrollView1", true);
	self.pPanel:SetActive("ScrollView2", false);
	self.ScrollView1:Update(tbShowInfo, fnSetItem);

	local tbInfo = tbShowInfo[1] or {};
	self:UpdateFurniture(nItemId or tbInfo[1]);
end

function tbUi:GetShowTypeInfo(nType, bShowAll)
	local nHouseLevel = House.nHouseLevel or 1;
	local tbShowInfo = {};
	local nCanMakeCount = 0;
	for nFurnitureItemId, tbInfo in pairs(House.tbFurnitureMakeSetting) do
		local fnCheckFunc = self.bOnlyShowCanMake and House.CheckCanMakeFurniture or House.CheckCanMakeFurnitureCommon;
		if bShowAll then
			fnCheckFunc = House.CheckCanMakeFurnitureCommon;
		end
		local bRet, szMsg, tbFurniture = fnCheckFunc(House, me, nFurnitureItemId);
		if bRet and tbFurniture.nType == nType then
			table.insert(tbShowInfo, {nFurnitureItemId, tbFurniture});
		end

		if bShowAll or not self.bOnlyShowCanMake then
			bRet, szMsg, tbFurniture = House:CheckCanMakeFurniture(me, nFurnitureItemId);
			if bRet and tbFurniture.nType == nType then
				nCanMakeCount = nCanMakeCount + 1;
			end
		else
			nCanMakeCount = #tbShowInfo;
		end
	end

	table.sort(tbShowInfo, function (a, b)
		if a[2].nLevel ~= b[2].nLevel then
			return a[2].nLevel > b[2].nLevel;
		end

		if a[2].nComfortValue ~= b[2].nComfortValue then
			return a[2].nComfortValue > b[2].nComfortValue;
		end

		return a[1] > b[1];
	end);

	return tbShowInfo, nCanMakeCount;
end

function tbUi:UpdateFurniture(nFurnitureItemId)
	for i = 0, 1000, 1 do
		local itemObj = self.ScrollView1.Grid["Item" .. i];
		if not itemObj then
			break;
		end

		itemObj.pPanel:Button_SetCheck("Main", nFurnitureItemId == itemObj.nItemId and true or false);
	end

	self:CloseAllTimer();

	self.nFurnitureItemId = nFurnitureItemId or self.nFurnitureItemId;
	self.nFurnitureItemId = self.nFurnitureItemId or 0;
	self.nShowPlayerId = me.dwID;
	local tbMakeSetting = House.tbFurnitureMakeSetting[self.nFurnitureItemId] or {tbPosition = {0, 0, 0}, tbRotation = {0, 0, 0}};
	local tbFurniture = House:GetFurnitureInfo(self.nFurnitureItemId) or {};
	local tbDecoration = Decoration.tbAllTemplate[tbFurniture.nDecorationId or 0] or {};

	self.pPanel:NpcView_ShowPrefab("ShowRole", tbDecoration.szResPath or "");
	self.pPanel:NpcView_SetScale("ShowRole", tbMakeSetting.nScale or 1);
	self.pPanel:NpcView_SetModePos("ShowRole", tbMakeSetting.tbPosition[1], tbMakeSetting.tbPosition[2], tbMakeSetting.tbPosition[3]);
	self.pPanel:NpcView_ChangeAllDir("ShowRole", tbMakeSetting.tbRotation[1], tbMakeSetting.tbRotation[2], tbMakeSetting.tbRotation[3], false);

	self:UpdateCostInfo();

	self.pPanel:SetActive("FinishedProduct", false);
	self.pPanel:SetActive("Zhizuochenggong", false);
	self.pPanel:Button_SetEnabled("BtnMake", true);
end

function tbUi:UpdateCostInfo()
	local tbMakeSetting = House.tbFurnitureMakeSetting[self.nFurnitureItemId] or {tbPosition = {0, 0, 0}, tbRotation = {0, 0, 0}};
	local nCostContrib = 0;
	local tbCost = {};
	for _, tbInfo in ipairs(tbMakeSetting.tbCost or {}) do
		if tbInfo[1] == "Contrib" then
			nCostContrib = tbInfo[2];
		else
			table.insert(tbCost, tbInfo);
		end
	end

	self.pPanel:Label_SetText("TxtCostMoney", nCostContrib);
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney("Contrib"));

	for i = 1, 6 do
		local itemObj = self["Item" .. i];
		if itemObj then
			itemObj.pPanel:SetActive("Main", false);
			if tbCost[i] then
				local tbInfo = tbCost[i];
				itemObj.pPanel:SetActive("Main", true);
				itemObj:SetGenericItem(tbInfo);
				itemObj.fnClick = itemObj.DefaultClick;

				if Player.AwardType[tbInfo[1]] == Player.award_type_item then
					local nItemTId = tbInfo[2];
					local nNeedCount = tbInfo[3];
					local nCount = me.GetItemCountInBags(nItemTId);
					local szColor = nCount >= nNeedCount and "[ffffff]" or "[ff0000]";
					itemObj.pPanel:Label_SetText("LabelSuffix", string.format("%s%s/%s[-]", szColor, nCount, nNeedCount));
					itemObj.pPanel:SetActive("LabelSuffix", true);
				end
			end
		end
	end
end

function tbUi:UpdateFurnitureTypeList()
	local tbAllCanShowType = {};
	local tbMakeCount = {};
	for nType in ipairs(Furniture.tbNormalFurniture) do
		local tbShowInfo, nCanMakeCount = self:GetShowTypeInfo(nType, true);
		if #tbShowInfo > 0 then
			table.insert(tbAllCanShowType, nType);
			tbMakeCount[nType] = nCanMakeCount;
		end
	end

	table.sort(tbAllCanShowType, function(nType1, nType2)
		local nIdx1 = Furniture.tbNormalFurniture[nType1].nIdx or math.huge
		local nIdx2 = Furniture.tbNormalFurniture[nType2].nIdx or math.huge
		return nIdx1<nIdx2 or (nIdx1==nIdx2 and nType1<nType2)
	end)

	local function fnSetItem(itemObj, index)
		local nIdx = index * 2 - 2;
		for i = 1, 2 do
			local nType = tbAllCanShowType[nIdx + i];
			local nCanMakeCount = tbMakeCount[nType] or 0;
			local szTypeName = Furniture:GetTypeName(nType);
			local pObj = itemObj["BtnName" .. i];

			pObj.pPanel:SetActive("Tip" .. i, nCanMakeCount > 0 and true or false);
			pObj.pPanel:SetActive("Main", szTypeName and true or false);
			if szTypeName then
				pObj.pPanel:Label_SetText("Light", szTypeName);
			end
			local bShowRedPoint = false
			if nType==Furniture.TYPE_MAGIC_BOWL and House:CanMakeMagicBowl() then
				bShowRedPoint = true
			end
			pObj.pPanel:SetActive("Mark"..i, bShowRedPoint)
			pObj.nType = nType;
			pObj.pPanel.OnTouchEvent = function (pObj)
				self:UpdateFurnitureList(pObj.nType);
			end
		end
	end
	self.pPanel:SetActive("ScrollView1", false);
	self.pPanel:SetActive("ScrollView2", true);
	self.ScrollView2:Update(math.ceil(#tbAllCanShowType / 2), fnSetItem);
end

function tbUi:OnSyncMakeFurniture(nFurnitureItemId, bResult)
	if not bResult or not nFurnitureItemId or nFurnitureItemId ~= self.nFurnitureItemId then
		self:UpdateFurniture();
		return;
	end

	self.pPanel:NpcView_ShowNpc("ShowRole", 20000);
	self.pPanel:NpcView_SetScale("ShowRole", 0.7);
	self.pPanel:NpcView_SetModePos("ShowRole", -30.5, -3.7, -234);
	self.pPanel:NpcView_ChangeAllDir("ShowRole", 20, 145, -10, false);
	self.pPanel:Button_SetEnabled("BtnMake", false);
	self.pPanel:SetActive("FinishedProduct", false);

	self:CloseAllTimer();
	self.nPlayAniTimerId = Timer:Register(Env.GAME_FPS * 0.5, function ()
		self.pPanel:NpcView_PlayAnimation("ShowRole", "at01", 1, false);
		self.pPanel:PlayUiAnimation("HomeMakePanelMuxie", false, false, {});
		self.nPlayAniTimerId = nil;
	end);

	self.nFinishAniTimerId = Timer:Register(Env.GAME_FPS * tbUi.nAniTime, function ()
		self.pPanel:SetActive("FinishedProduct", true);
		self.pPanel:Button_SetEnabled("BtnMake", true);
		self.pPanel:SetActive("Zhizuochenggong", true);
		self.pPanel:NpcView_PlayAnimation("ShowRole", "st", 1, true);
		self.FinishedProduct:SetItemByTemplate(nFurnitureItemId, 0, me.nFaction);
		self.FinishedProduct.fnClick = self.FinishedProduct.DefaultClick;
		self.nFinishAniTimerId = nil;

		local szName = Item:GetItemTemplateShowInfo(nFurnitureItemId, me.nFaction, me.nSex);
		me.CenterMsg(string.format("[FFFE0D]%s[-]已放入家具仓库", szName));
	end);
end

function tbUi:CloseAllTimer()
	if self.nPlayAniTimerId then
		Timer:Close(self.nPlayAniTimerId);
		self.nPlayAniTimerId = nil;
		self.pPanel:StopUiAnimation("HomeMakePanelMuxie");
	end

	self.pPanel:SetActive("Zhizuochenggong", fa);

	if self.nFinishAniTimerId then
		Timer:Close(self.nFinishAniTimerId);
		self.nFinishAniTimerId = nil;
	end
end

function tbUi:OnSyncItem()
	self:UpdateCostInfo();
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_MAKE_FURNITURE,		self.OnSyncMakeFurniture };
		{ UiNotify.emNOTIFY_SYNC_ITEM,					self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,					self.OnSyncItem},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnMake = function (self)
	local bRet, szMsg = House:CheckCanMakeFurniture(me, self.nFurnitureItemId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	self.pPanel:NpcView_ShowNpc("ShowRole", 20000);
	self.pPanel:NpcView_SetScale("ShowRole", 0.7);
	self.pPanel:NpcView_SetModePos("ShowRole", -30.5, -3.7, -234);
	self.pPanel:NpcView_ChangeAllDir("ShowRole", 20, 145, -10, false);
	self.pPanel:Button_SetEnabled("BtnMake", false);
	RemoteServer.MakeFurniture(self.nFurnitureItemId);
end

tbUi.tbOnClick.BtnSelect = function (self)
	if self.pPanel:IsActive("ScrollView2") then
		self:UpdateFurnitureList(self.nCurType);
	else
		self:UpdateFurnitureTypeList();
	end
end

tbUi.tbOnClick.BtnOnlyShowCanMake = function (self)
	self.bOnlyShowCanMake = not self.bOnlyShowCanMake;
	self.pPanel:SetActive("SpOnlyShowCanMake", self.bOnlyShowCanMake and true or false);
	if self.pPanel:IsActive("ScrollView2") then
		return;
	end

	self:UpdateFurnitureList(self.nCurType);
end

tbUi.tbOnClick.BtnTxt = function (self)
	Ui:OpenWindow("HouseComfortablePanle");
end