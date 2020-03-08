
local uiTips = Ui:CreateClass("InscriptionTips");

function uiTips:OnOpen(nItemId, nTemplateId)
	if not nTemplateId and not nItemId then
		return 0;
	end
end

function uiTips:OnOpenEnd(nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, nSex)
	local bIsCompare = self.UI_NAME == "CompareTips"
	nFaction = nFaction or me.nFaction
	nSex = nSex or me.nSex;

	local pItem, nValue;
	local szName, nIcon, nView, nQuality, nMaxAttribQuality;
	self.fnBtnClick = {}

	if nItemId then
		pItem = KItem.GetItemObj(nItemId)
		if not pItem then
			return;
		end
		nTemplateId = pItem and pItem.dwTemplateId or nTemplateId;
		szName, nIcon, nView = Item:GetDBItemShowInfo(pItem, nFaction, nSex)
		nQuality = pItem.nQuality
	else
		szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTemplateId, nFaction, nSex)
	end

	self.nItemId = nItemId
	self.nTemplateId = nTemplateId

	local tbInfo = KItem.GetItemBaseProp(nTemplateId)
	if not tbInfo then
		return;
	end

	if Item.EQUIPTYPE_NAME[tbInfo.nItemType] then
		self.pPanel:Label_SetText("TxtEquipType", Item.EQUIPTYPE_NAME[tbInfo.nItemType]);
	end

	--出售
	local nPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, pItem and pItem.nCount or 1);
	self.nPrice = nPrice;
	self.szMoneyType = szMoneyType
	if szMoneyType and nPrice then
		self.pPanel:SetActive("SalePrice", true);
		self.pPanel:Label_SetText("TxtCoin", nPrice);
		local szMoneyIcon, szMoneyIconAtlas = Shop:GetMoneyIcon(szMoneyType);
		self.pPanel:Sprite_SetSprite("Ylicon", szMoneyIcon, szMoneyIconAtlas);
	else
		self.pPanel:SetActive("SalePrice", false);
	end


	--强化等级
	self.pPanel:SetActive("TxtEnhLevel", false);

	--图标
	if nView and nView ~= 0 then
		local szIconAtlas, szIconSprite = Item:GetIcon(nView);
		self.pPanel:SetActive("ItemLayer", true)
		self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas);
	else
		self.pPanel:SetActive("ItemLayer", false);
	end


	--等级限制与描述
	self.pPanel:Label_SetText("TxtLevelLimit", string.format("%d级", tbInfo.nRequireLevel));
	self.pPanel:Label_SetText("TxtIntro", "");
	self.pPanel:Label_SetText("Rank", string.format("%d阶", tbInfo.nLevel));


	--属性
	local szClassName = tbInfo.szClass
	local tbClass = Item.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end

	local tbAttrib;
	if pItem then
		local pPlayer = me;
		local bNotShowAll = bIsCompare; --看自己背包里的装备比较时是不带强化的，但是看别人的装备比较时是带强化的
		if  szOpt == "ViewOtherEquip" then
			bNotShowAll = false;
		end

		tbAttrib, nMaxAttribQuality = tbClass:GetTip(pItem, pPlayer, bNotShowAll);
		nValue = pItem.nValue;
		local nFightPower = pItem.nFightPower;

		self.pPanel:Label_SetText("TxtFightPower", "战力：".. tostring(nFightPower));
	else
		if not tbSaveRandomAttrib then
			tbSaveRandomAttrib = Item.tbRefinement:GetCustomAttri(nTemplateId)
		end
		tbAttrib, nMaxAttribQuality = tbClass:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
		nValue = tbInfo.nValue
		local nFightPower = 0
		local bHasRandomAttrib = false; -- bHasRandomAttrib 有非0值时则以随机属性进行计算
		for _, v in pairs(tbSaveRandomAttrib or {}) do
			if v ~= 0 then
				bHasRandomAttrib = true;
				break;
			end
		end

		if bHasRandomAttrib then
			nFightPower = nFightPower + Item.tbRefinement:GetFightPowerFromSaveAttriEx(tbInfo.nLevel, tbSaveRandomAttrib, tbInfo.nItemType)
		end

		self.pPanel:Label_SetText("TxtFightPower", "战力：".. nFightPower );
	end
	self:SetTips(tbAttrib or {})
	self.bHasAttrib = false
	if #(tbAttrib or {})>1 then
		self.bHasAttrib = true
	end

	self.pPanel:SetActive("Equipped", false);

	local szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nMaxAttribQuality or 0)
	self.pPanel:Sprite_SetSprite("Color", szFrameColor);
	if szAnimation and szAnimation ~= "" and szAnimationAtlas ~= "" then
		self.pPanel:SetActive("LightAnimation", true);
		self.pPanel:Sprite_Animation("LightAnimation", szAnimation, szAnimationAtlas);
		local nEffect = Item:GetQualityEffect(nQuality)
		if  nEffect ~= 0 then
			self.pPanel:ShowEffect("LightAnimation", nEffect, 1)
		end
	else
		self.pPanel:SetActive("LightAnimation", false);
	end

	--名字
	if szName then
		self.pPanel:Label_SetText("TxtTitle", szName);
		local szNameColor = Item:GetQualityColor(nMaxAttribQuality) or "White";
		self.pPanel:Label_SetColorByName("TxtTitle", szNameColor);
	end

	--星级
	local nStarLevel = Item:GetStarLevel(tbInfo.nItemType, nValue)
	local nBrightStar = math.ceil(nStarLevel / 2)
	for i = 1, 10 do
		if nBrightStar >= i then
			self.pPanel:SetActive("SprStar"..i, true)
			if (nBrightStar == i and nStarLevel % 2 == 1) then
				self.pPanel:Sprite_SetSprite("SprStar"..i, "Star_02")
			else
				self.pPanel:Sprite_SetSprite("SprStar"..i, "Star_01")
			end
		else
			self.pPanel:SetActive("SprStar"..i, false)
		end
	end

	--按钮
	if pItem and me.GetItemInBag(nItemId) and szOpt and self.Option[szOpt] then
		self.pPanel:SetActive("BtnGroup", true)
		local nIndex = 1;
		for _,tbButton in ipairs(self.Option[szOpt]) do
			local fnVisible, szBtnName, fnCallback, fnSowRedPoint = unpack(tbButton);
			if fnVisible == true or fnVisible(self) then
				local szButton = "Btn" .. nIndex

				self.pPanel:Button_SetText(szButton, szBtnName)
				self.pPanel:SetActive(szButton, true)
				self.fnBtnClick[szButton] = fnCallback;
				local bShowRed = fnSowRedPoint and fnSowRedPoint(self)
				self.pPanel:SetActive("BtnNew" .. nIndex, bShowRed)
				nIndex = nIndex + 1;

			end
		end

		for i = nIndex, 4 do
			local szButton = "Btn" .. i
			self.pPanel:SetActive(szButton, false);
			self.fnBtnClick[szButton] = nil;
		end
	else
		self.pPanel:SetActive("BtnGroup", false)
	end

	Ui:OpenWindow("BgBlackAll", 0.7, Ui.LAYER_NORMAL)
end

function uiTips:SetTips(tbAttribs)
	local tbHeight = {};
	local fnSetItem = function (itemObj, nIndex)
		local tbDesc = tbAttribs[nIndex];
		local nHeight = itemObj:SetText(tbDesc, self);
		tbHeight[nIndex] = nHeight
		self.ScrollView:UpdateItemHeight(tbHeight);
	end

	self.ScrollView:Update(#tbAttribs, fnSetItem);
	self.ScrollView:UpdateItemHeight(tbHeight);
	self.ScrollView:GoTop();
	self.pPanel:SetActive("down", false)
end

function uiTips:Refinement()
	if not self.nItemId or not self:CanRefinement() then
		return;
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return;
	end

	me.CallClientScript("Ui:OpenWindow", "MagicBowlRefinementPanel", pItem.dwId)
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:Sell()
	if not self.nItemId then
		return;
	end

	Shop:ConfirmSell(self.nItemId)
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:CanRefinement()
	if not self.nItemId then
		return false
	end
	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return false
	end
	return Furniture.MagicBowl:CanRefinement(pItem)
end

function uiTips:CanSell()
	return self.nItemId and self.szMoneyType and self.nPrice
end

uiTips.Option =
{
	ItemBox =
	{
		{uiTips.CanRefinement, "洗练", uiTips.Refinement},
		{uiTips.CanSell, "出售", uiTips.Sell},
	},
}


function uiTips:OnButtonClick(szWnd)
	if self.fnBtnClick[szWnd] then
		self.fnBtnClick[szWnd](self)
	end
end

function uiTips:OnScreenClick(szClickUi)
	if szClickUi ~= "CompareTips" and szClickUi ~= "EquipTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function uiTips:OnTipsClose(szWnd)
	if szWnd == "CompareTips" or szWnd == "EquipTips" or szWnd == "StoneTipsPanel" or szWnd == "ItemTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function uiTips:OnClose()
	if Ui:WindowVisible("CompareTips") == 1 and Ui:WindowVisible("EquipTips") == 1 then
		return
	end
	Ui:CloseWindow("BgBlackAll")
end

function uiTips:OnResponseSell(bSuccess)
	if bSuccess then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function uiTips:OnDelItem(nItemId)
	if nItemId == self.nItemId then
		Ui:CloseWindow(self.UI_NAME)
	end
end

uiTips.tbOnClick =
{
	Btn1 = uiTips.OnButtonClick,
	Btn2 = uiTips.OnButtonClick,
	Btn3 = uiTips.OnButtonClick,
	Btn4 = uiTips.OnButtonClick,
}

function uiTips:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WND_CLOSED, 		self.OnTipsClose},
		{ UiNotify.emNOTIFY_SHOP_SELL_RESULT,   self.OnResponseSell},
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnDelItem },

	}

	return tbRegEvent;
end
