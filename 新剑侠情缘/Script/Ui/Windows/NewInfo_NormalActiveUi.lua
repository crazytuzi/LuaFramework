
local tbUi = Ui:CreateClass("NewInfo_NormalActiveUi");

function tbUi:OnOpen(tbData)
	self:Clear();

	local szKey = tbData[1];
	self.tbInfoData, self.tbActData = Activity:GetNormalNewInfomationSetting(szKey);
	if not self.tbInfoData then
		local szActKeyName = Activity:GetActKeyName(szKey);
		if not szActKeyName then
			return 0;
		end

		self.tbInfoData, self.tbActData = Activity:GetActUiSetting(szActKeyName)
	end

	self.tbActData = self.tbActData or {};
	self.tbInfoData = self.tbInfoData or {}

	self:Update();

	local WndTransform = self.ScrollViewFestival.pPanel:FindChildTransform("Main");
	local panel = WndTransform:GetComponent("UIPanel");
	panel.bottomAnchor.absolute = self.tbInfoData.nBottomAnchor or 15;
	panel.topAnchor.absolute = self.tbInfoData.nTopAnchor or 0;
end

function tbUi:Clear()
	self.pPanel:Label_SetText("FestivalDetails", "");
	self.pPanel:SetActive("BtnInfo", false);
	self.pPanel:SetActive("ScrollViewFestival", false);
end

function tbUi:Update()
	local szContent = self.tbInfoData.szContent or ""
	if self.tbInfoData.FuncContent then
		szContent = self.tbInfoData.FuncContent(self.tbActData)
	end

	self.FestivalDetails:SetLinkText(szContent);
	self.pPanel:SetActive("BtnInfo", self.tbInfoData.szBtnText and true or false);
	if self.tbInfoData.szBtnText then
		self.pPanel:Label_SetText("BtnLabel", self.tbInfoData.szBtnText);
	end

	local tbSubInfo = self.tbInfoData.FuncSubInfo and self.tbInfoData.FuncSubInfo(self.tbActData) or self.tbInfoData.tbSubInfo
	self.pPanel:SetActive("ScrollViewFestival", tbSubInfo and true or false);
	if not tbSubInfo then
		return;
	end

	local tbItemHeight = {};
	local function fnSetItem(pItemObj, index)
		self:SetSubItem(pItemObj, tbSubInfo[index], tbItemHeight, index);
	end

	local nLen = #tbSubInfo
	Timer:Register(3, function ()
		self.ScrollViewFestival:UpdateItemHeight(tbItemHeight)
		self.ScrollViewFestival:Update(nLen, fnSetItem);
	end);
end

tbUi.tbGridSetFunc = {
	["Item1"] = "SetSubItem1";
	["Item2"] = "SetSubItem2";
	["Item3"] = "SetSubItem3";
}

function tbUi:SetSubItem(pItemObj, tbInfo, tbItemHeight, index)
	local func = self[self.tbGridSetFunc[tbInfo.szType]]
	for k,v in pairs(self.tbGridSetFunc) do
		pItemObj.pPanel:SetActive(k, false);
	end

	pItemObj.pPanel:SetActive(tbInfo.szType, true);
	func(self, pItemObj[tbInfo.szType], tbInfo)

	local tbSize = pItemObj.pPanel:Widget_GetSize(tbInfo.szType)
	tbItemHeight[index] = tbSize.y;
	pItemObj.pPanel:Widget_SetSize("Main", tbSize.x, tbSize.y)
	self.ScrollViewFestival:UpdateItemHeight(tbItemHeight)
end

function tbUi:SetSubItem1(pItemObj, tbInfo)
	pItemObj.pPanel:Label_SetText("FestivalTitle", tbInfo.szInfo or "");
	local tbAwardList = tbInfo.tbItemList
	for i = 1, 4 do
		local tbAward = tbAwardList[i]
		pItemObj.pPanel:SetActive("FestivalItem" .. i, tbAward and true or false);
		-- pItemObj.pPanel:SetActive("FestivalItemName" .. i, tbInfo.tbItemName[i] and true or false);
		if tbAward then
			if type(tbAward) == "number" then
				pItemObj["FestivalItem" .. i]:SetItemByTemplate(tbAward, 0, me.nFaction);
			else
				pItemObj["FestivalItem" .. i]:SetGenericItem(tbAward)
			end
			pItemObj["FestivalItem" .. i].fnClick = pItemObj["FestivalItem" .. i].DefaultClick;
		end

		if tbInfo.tbItemName[i] then
			-- pItemObj.pPanel:Label_SetText("FestivalItemName" .. i, tbInfo.tbItemName[i]);
		end
	end
end

function tbUi:SetSubItem2(pItemObj, tbInfo)
	if tbInfo.szBtnText then
		pItemObj.pPanel:Label_SetText("BtnGo", tbInfo.szBtnText);
		pItemObj.pPanel:SetActive("BtnGo", true);
		pItemObj.BtnGo.pPanel.OnTouchEvent = function ()
			Ui.HyperTextHandle:Handle(tbInfo.szBtnTrap, 0, 0);
			Ui:CloseWindow("NewInformationPanel")
		end;
	else
		pItemObj.pPanel:SetActive("BtnGo", false);
	end
	if tbInfo.szInfo then
		pItemObj.pPanel:SetActive("Details", true);
		local tbLabelSize = pItemObj.pPanel:Widget_GetSize("Details")
		local tbItemSize = pItemObj.pPanel:Widget_GetSize("Main")
		local nDiffY = tbItemSize.y - tbLabelSize.y
		pItemObj.Details:SetLinkText(tbInfo.szInfo);
		tbLabelSize = pItemObj.pPanel:Widget_GetSize("Details")
		pItemObj.Details.pPanel:ChangeBoxColliderSize("Main", tbLabelSize.x, tbLabelSize.y, 0, tbLabelSize.x/2)
		pItemObj.pPanel:Widget_SetSize("Main", tbItemSize.x, tbLabelSize.y + nDiffY)
	else
		pItemObj.pPanel:SetActive("Details", false);
	end
end

function tbUi:SetSubItem3(pItemObj, tbInfo)
	if tbInfo.tbBgSprite then
		pItemObj.pPanel:Sprite_SetSprite("Main", unpack(tbInfo.tbBgSprite))
	else
		pItemObj.pPanel:Sprite_SetSprite("Main", "BtnListFifthNormal", "NewBtn")
	end
	local tbAwardList = tbInfo.tbItemList
	for i = 1, 5 do
		local tbAward = tbAwardList[i]
		pItemObj.pPanel:SetActive("CumulativeItem" .. i, tbAward and true or false);
		-- pItemObj.pPanel:SetActive("CumulativeItemName" .. i, tbInfo.tbItemName[i] and true or false);
		if tbAward then
			if type(tbAward) == "number" then
				pItemObj["CumulativeItem" .. i]:SetItemByTemplate(tbAward, 0, me.nFaction);
			else
				pItemObj["CumulativeItem" .. i]:SetGenericItem(tbAward)
			end
			pItemObj["CumulativeItem" .. i].fnClick = pItemObj["CumulativeItem" .. i].DefaultClick;
		end

		if tbInfo.tbItemName[i] then
			-- pItemObj.pPanel:Label_SetText("CumulativeItemName" .. i, tbInfo.tbItemName[i]);
		end
	end
	pItemObj.pPanel:Label_SetText("Cumulative", tbInfo.nParam)

	local szTitle, szType, szRate
	if tbInfo.szSub == "Recharge" then
		szTitle = "累计充值"
		szType = "元宝"
		szRate = string.format("%d/%d", Recharge:GetActRechageSumVal(me), tbInfo.nParam)
	elseif tbInfo.szSub == "Consume" then
		szTitle = "累计消费"
		szType = "元宝"
		szRate = string.format("%d/%d", Recharge:GetActConsumeSumVal(me) , tbInfo.nParam)
	elseif tbInfo.szSub == "ContinualRecharge_Day" then
		szTitle = "每天充值"
		szType = "元宝"
		szRate = string.format("%d/%d", Recharge:GetActContinualData(me, Recharge.KEY_ACT_CONTINUAL_RECHARGE), tbInfo.nParam)
	elseif tbInfo.szSub == "ContinualRecharge" then
		szTitle = "连续充值"
		szType = "天"
		szRate = string.format("%d/%d", Recharge:GetActContinualData(me, Recharge.KEY_ACT_CONTINUAL_DAYS) , tbInfo.nParam)
	end
	pItemObj.pPanel:Label_SetText("Label",  szTitle or "")
	pItemObj.pPanel:Label_SetText("CurrencyType", szType or "")
	pItemObj.pPanel:Label_SetText("RateNumber", szRate or "")
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnInfo = function (self)

	if not self.tbInfoData then
		return;
	end
	if self.tbInfoData.fnCall then
		self.tbInfoData.fnCall()
		return
	end
	if not self.tbInfoData.szBtnTrap then
		return
	end

	if not self.tbInfoData.szBtnType or self.tbInfoData.szBtnType == "" or self.tbInfoData.szBtnType == "Link" then
		Ui.HyperTextHandle:Handle(self.tbInfoData.szBtnTrap, 0, 0);
	elseif self.tbInfoData.szBtnType == "ClientCmd" then
		NewInformation:OnButtonEvent(self.tbInfoData.szBtnTrap);
	elseif self.tbInfoData.szBtnType == "ServerCmd" then
		RemoteServer.OnNewInfomationButton(self.tbInfoData.szBtnTrap);
	end
	Ui:CloseWindow("NewInformationPanel")
end
