local tbUi = Ui:CreateClass("WelfareActivity");



function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WELFARE_UPDATE, 		self.OnActivityUpdate, 		self },
		{ UiNotify.emNOTIFY_MONEYTREE_RESPOND, 		self.OnRespondMoneyTree,	self },
		{ UiNotify.emNOTIFY_MONEYTREE_DATA_UPDATE, 	self.OnMoneyTreeUpdate,		self },
		{ UiNotify.emNOTIFY_ONHOOK_GET_EXP_FINISH, 	self.OnOnHookUpdate,		self },
		{ UiNotify.emNOTIFY_SUPPLEMENT_RSP, 		self.OnRespondSupplement, 	self },
		{ UiNotify.emNOTIFY_UPDATE_QQ_VIP_INFO, 	self.OnUpdateQQVipInfo, 	self },
		{ UiNotify.emNOTIFY_QQ_INVITE_UNREG_UPDATE, self.OnUpdateQQInviteUnReg, self },
		{ UiNotify.emNOTIFY_SECRETCARD_SYNC_DATA,   self.OnUpdateSecretCard, self },

	};

	return tbRegEvent;
end


tbUi.tbSelectNoPage = {
	-- XinyueVip = function () -- 移出到主界面
	-- 	Sdk:OpenXinyueUrl();
	-- end;
};


function tbUi:OnOpen(szWndType)
	if szWndType then
		local minLevel  = WelfareActivity:GetActivityOpenLevel(szWndType)
		if minLevel and minLevel > me.nLevel then
			me.CenterMsg(string.format("%d级开启",minLevel))
			return 0
		end
	end
end

function tbUi:OnOpenEnd(szWndType, ...)
	self.szCurWndType = szWndType;
	self:InitActiveActivity();
	self:Update(szWndType, ...);
	for i, tbInfo in ipairs(self.tbActiveList) do
		if tbInfo.szKey == self.szCurWndType then
			self.ScrollViewCatalog.pPanel:ScrollViewGoToIndex("Main", i)
			break
		end
	end
	for i, tbInfo in ipairs(self.tbActiveList) do
		local szCheckFunc = tbInfo.szCheckRpFunc or tbInfo.szKey
		if WelfareActivity.tbCheckRedPoint[szCheckFunc] then
			WelfareActivity.tbCheckRedPoint[szCheckFunc](tbInfo)
		end
	end
end

function tbUi:OnClose()
	self:ExecuteActFunc("SupplementPanel", "OnClose")
	self:ExecuteActFunc("MoneyTreePanel", "OnClose")
	self:ExecuteActFunc("FirstRecharge", "OnClose")
	self:ExecuteActFunc("GrowInvest", "OnClose")
	self:ExecuteActFunc("FriendInvitationGift", "OnClose")
	self.tbCurActive = nil
	Pandora:ClosePanel(self.UI_NAME)
end

function tbUi:InitActiveActivity()
	self.tbActiveList = WelfareActivity:GetActivityList()
end

function tbUi:Update(szWndType, ...)
	local tbOldActive = self.tbCurActive
	self:CheckWndType(szWndType);
	self:UpdateActivityList();
	self:UpdateRightPanel();
	if not self.szCurWndType then
		Log("[WelfareActivity Update] Error")
		return
	end
	self:ExecuteActFunc(self.szCurWndType, "OnOpen", ...)
	if tbOldActive and self.tbCurActive ~= tbOldActive then
		WelfareActivity:OnSwitchTab(tbOldActive)
	end

	if self.tbCurActive ~= tbOldActive then
		WelfareActivity:OnClickTab(self.tbCurActive)
	end
end

function tbUi:CheckWndType(szWndType)
	self.szCurWndType = szWndType or self.szCurWndType;
	for _, tbInfo in pairs(self.tbActiveList) do
		if tbInfo.szKey == self.szCurWndType then
			self.tbCurActive = tbInfo;
			return;
		end
	end

	if #self.tbActiveList > 0 then
		self.tbCurActive = self.tbActiveList[1];
		self.szCurWndType = self.tbActiveList[1].szKey;
	end
end

function tbUi:OnActivityUpdate(szWndType)
	if self.szCurWndType == szWndType then
		self:UpdateActivityList()
		self:ExecuteActFunc(self.szCurWndType, "OnOpen")
	end
end

function tbUi:UpdateActivityList()
	local fnOnSelect = function (btn)
		self:ExecuteActFunc(self.szCurWndType, "OnClose")
		if self.tbSelectNoPage[szTouchKey] then
			self.tbSelectNoPage[szTouchKey]();
			return
		end
		local szTouchKey = self.tbActiveList[btn.nIdx].szKey;
		self:Update(szTouchKey);
		Guide.tbNotifyGuide:ClearNotifyGuide(szTouchKey)
	end

	local fnSetItem = function (itemObj, nIdx)
		local tbActivity = self.tbActiveList[nIdx]
		local szRedPoint = tbActivity.szRedPointKey;
		local bActive    = (szRedPoint ~= "") and true or false
		Ui.UnRegisterRedPoint("NG_" .. tbActivity.szKey)
		itemObj.pPanel:RegisterRedPoint("texiao", "NG_" .. tbActivity.szKey)
		if bActive then
			Ui.UnRegisterRedPoint(szRedPoint)
			itemObj.pPanel:RegisterRedPoint("Redmark", szRedPoint)
		else
			itemObj.pPanel:SetActive("Redmark", false)
		end

		local szSprite = tbActivity.szKey == self.szCurWndType and "BtnWelfare_02" or "BtnWelfare_01";
		itemObj.pPanel:Label_SetText("FamilyName", tbActivity.szName);
		itemObj.pPanel:Label_SetText("FamilyName1", tbActivity.szName);
		itemObj.pPanel:Sprite_SetSprite("Main", szSprite);
		itemObj.pPanel:Toggle_SetChecked("Main", tbActivity.szKey == self.szCurWndType)
		itemObj.pPanel:SetActive("NYLabel", tbActivity.bShowNewIcon or false);

		itemObj.nIdx = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end
	self.ScrollViewCatalog:Update(#self.tbActiveList, fnSetItem);
end

function tbUi:UpdateRightPanel()
	local szRealUiKey = self:GetRealUiFromKey(self.szCurWndType)
	self.pPanel:SwitchSubPanel("Main", szRealUiKey)
end

function tbUi:OnRespondMoneyTree(tbGain)
	self:ExecuteActFunc("MoneyTreePanel", "OnRespond", tbGain)
end

function tbUi:OnMoneyTreeUpdate()
	self:ExecuteActFunc("MoneyTreePanel", "Update")
end

function tbUi:OnOnHookUpdate()
	self:ExecuteActFunc("OnHook", "Update")
end

function tbUi:OnUpdateSecretCard()
	self:ExecuteActFunc("WuXunMiLingpanel", "Update")
end

function tbUi:OnRespondSupplement()
	self:ExecuteActFunc("SupplementPanel", "Update")
end

function tbUi:OnUpdateQQVipInfo()
	self:ExecuteActFunc("QQVipPrivilege", "Update")
end

function tbUi:OnUpdateQQInviteUnReg()
	self:ExecuteActFunc("FriendInvitationGift", "Update");
end

tbUi.tbUiReplaceKeyAndParam = {
	["WeiXinBuyGift"] = {
		szReplace = "NewYearBuyGift";
		OnOpen = {"WeiXinBuyGift"};
	};
}

function tbUi:GetRealUiFromKey( szKey )
	local tbReplaceInfo = self.tbUiReplaceKeyAndParam[szKey]
	if  tbReplaceInfo and  tbReplaceInfo.szReplace then
		return tbReplaceInfo.szReplace
	end
	return szKey
end

function tbUi:GetExecuteActFuncReplace( szKey, szFunc )
	local tbInfo = self.tbUiReplaceKeyAndParam[szKey]
	if not tbInfo then
		return
	end
	if tbInfo[szFunc] then
		return tbInfo[szFunc]
	end
end

function tbUi:ExecuteActFunc(szKey, szFunc, ...)
	local szRealUiKey = self:GetRealUiFromKey(szKey)

	local tbInst = self[szRealUiKey]
	if not tbInst then
		return
	end

	if not tbInst[szFunc] then
		return
	end
	local tbParam = {...}
	local tbReplaceParam = self:GetExecuteActFuncReplace(szKey, szFunc)
	if tbReplaceParam then
		tbParam = tbReplaceParam;
	end

	tbInst[szFunc](tbInst, unpack(tbParam))
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow("WelfareActivity")
	end
}
