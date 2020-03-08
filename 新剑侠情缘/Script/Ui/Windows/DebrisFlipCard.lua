local tbUi = Ui:CreateClass("DebrisFlipCard");
local tbGrid = Ui:CreateClass("DebrisCardItem")

tbGrid.tbOnClick = {}

tbGrid.tbOnClick.CardBack = function (self)
	Ui("DebrisFlipCard"):SelAward(self.nIndex)
end

function tbUi:OnOpen(bSuccess, nItemId, nIndex)
	self.nSel = nil
	self.nGetDebrrisItemId = nItemId

	self.pPanel:SetActive("Failure", not bSuccess)
	self.pPanel:SetActive("Success", bSuccess)

	self.pPanel:SetActive("txt", true) --TODO 提示战力暂时隐藏
	self.pPanel:SetActive("txtPowerUp", false)

	if bSuccess and nItemId and nIndex then
		self.pPanel:SetActive("ItemDebris", true)
		self.pPanel:SetActive("PowerUp", false)
		self.pPanel:SetActive("CardGroup", false)

		self.pPanel:Label_SetText("txt", "抢得碎片")

		self.Itemframe:SetItemByTemplate(nItemId, nil, nil, nil, nil, nIndex)
		local tbBaseInfo = KItem.GetItemBaseProp(nItemId);
		self.pPanel:Label_SetText("ItemName", tbBaseInfo.szName.. "碎片" .. Lib:Transfer4LenDigit2CnNum(nIndex)) 
		local szNameColor = Item:GetQualityColor(tbBaseInfo.nQuality) or "White";
		self.pPanel:Label_SetColorByName("ItemName", szNameColor);
	else
		self.pPanel:SetActive("ItemDebris", false)
		if bSuccess then
			self.pPanel:SetActive("PowerUp", false)
			self.pPanel:SetActive("CardGroup", true)
			for i = 1, 4 do
				local tbCard = self["group" .. i]
				tbCard.nIndex = i;
			end

			self.pPanel:Label_SetText("txt", string.format("击败了[f9ffa3]%s[-]，但对方携带碎片逃跑了", Debris.tbDebrisRobNpcInfo.szName))
		else
			self.pPanel:SetActive("PowerUp", Player.Stronger:CheckVisible())
			-- self.pPanel:Label_SetText("txt", "提示战力")
			self.pPanel:SetActive("txt", false)
			self.pPanel:SetActive("txtPowerUp", true)

			self.pPanel:SetActive("CardGroup", false)
		end
	end
end

function tbUi:OnClose()
	if self.nSel then
		local tbCard = self["group" .. self.nSel]
		tbCard.pPanel:PlayUiAnimation("TurnoverCardReset", false, false, {tostring(tbCard.pPanel)});
	end

	if  self.nGetDebrrisItemId then
		UiNotify.OnNotify(UiNotify.emNOTIFY_GET_DEBRIS, self.nGetDebrrisItemId)
	end
	
	Debris.tbDebrisRobNpcInfo = nil
end

function tbUi:UpdateSeldAward(tbAward)
	local nSel = self.nSel
	if not nSel then
		Log("Error!! DebrisFlipCard UpdateSeldAward ")
		return
	end
	
	local tbCard = self["group" .. self.nSel]

	local itemGrid = tbCard.Item
	
	local szAwardDesc = ""
	if tbAward[1] == "Coin" then
		szAwardDesc = string.format("%d银两", tbAward[2])
	else
		local tbBaseInfo = KItem.GetItemBaseProp(tbAward[2]);

		if tbBaseInfo then
			szAwardDesc = tbBaseInfo.szName
		end
	end

	if tbAward[1] == "EquipDebris" then
		self.nGetDebrrisItemId = tbAward[2];
	end

	itemGrid:SetGenericItem(tbAward)

	tbCard.pPanel:Label_SetText("TxtResultName", szAwardDesc)

	tbCard.pPanel:PlayUiAnimation("TurnoverCard", false, false, {tostring(tbCard.pPanel)});
end

function tbUi:SelAward(nIndex)
	if self.nSel then
		me.CenterMsg("您已经翻过牌了")
		return
	end
	self.nSel = nIndex
	RemoteServer.DebrisFlipCard()
end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnFinish()
	if self.pPanel:IsActive("CardGroup") and not self.nSel then
		me.CenterMsg("大侠还是先翻牌吧")
		return
	end

	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:PowerUp()
	Ui:OpenWindow("StrongerPanel")
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
	return
	{
		{ UiNotify.emNOTIFY_ON_DEBRIS_CARD_AWARD, self.UpdateSeldAward },
	};
end


