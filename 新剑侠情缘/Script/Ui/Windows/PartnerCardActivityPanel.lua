local tbUi = Ui:CreateClass("PartnerCardActivityPanel");
tbUi.tbUiSetting = 
{
	[PartnerCard.CARD_ACT_STATE_VISIT] = {
		szDes = "正在拜访中...";
		szTexturePath = "UI/Textures/BigHomeGuest1.png";
	};
	[PartnerCard.CARD_ACT_STATE_TRIP] = {
		szDes = "正在游历中...";
		szTexturePath = "UI/Textures/BigHomeGuest2.png";
	};
	[PartnerCard.CARD_ACT_STATE_MUSE] = {
		szDes = "正在冥想中...";
		szTexturePath = "UI/Textures/BigHomeGuest3.png";
	};
}
function tbUi:OnOpen()
	self.nCardId = nil
	self.nActTime = nil
	self.nActState = nil
	RemoteServer.PartnerCardOnClientCall("SynActData")
	self:Update()
end

function tbUi:GetHouseCardInfo(tbCardHouse, nCardId)
	for i,v in ipairs(tbCardHouse) do
		if v.nCardId == nCardId then
			return v.nActTime, v.nActState
		end
	end
end

function tbUi:Update()
	self.tbShowFlag = {}
	self.bChangeFlag = false 
	self:CloseActTimer()
	local tbCardHouse = PartnerCard:GetLiveHouseCard()
	self.nCardId = self.nCardId or (tbCardHouse[1] and tbCardHouse[1].nCardId)
	local nActTime, nActState = self:GetHouseCardInfo(tbCardHouse, self.nCardId)
	self.nActTime = nActTime or 0
	self.nActState = nActState
	self.nRemainActTime = 0
	local nNowTime = GetTime()
	local nPassActTime = nNowTime - self.nActTime
	local bActing = nPassActTime < PartnerCard.CARD_ACT_ACTIVE_TIME and true or false
	self.pPanel:SetActive("PanelGroup", not bActing)
	self.pPanel:SetActive("Panel4", bActing)
	self.pPanel:SetActive("BtnHelp", false)
	self:UpdateTimePanel()
	local fnUpdateBtn = function (itemObj)
		local bOutSide = PartnerCard:IsActing(me.dwID, itemObj.nCardId, PartnerCard.CARD_ACT_STATE_VISIT) or PartnerCard:IsActing(me.dwID, itemObj.nCardId, PartnerCard.CARD_ACT_STATE_TRIP)

		local bCanAcceptTask = PartnerCard:CheckAcceptTask(me, itemObj.nCardId)
		local bShow = itemObj.bShow
		local bEnableTask = (bShow and bCanAcceptTask and not bOutSide)
		local bGrayTask = (not bShow or not bCanAcceptTask or bOutSide)
		local bEnableGo = bShow and not bOutSide
		local bGrayGo = not bShow or bOutSide
		
		--itemObj["BtnTask"].pPanel:Button_SetEnabled("Main", bEnableTask and true or false);
		--itemObj["BtnTask"].pPanel:Sprite_SetGray("Main", bGrayTask and true or false);
		itemObj["BtnGo"].pPanel:Button_SetEnabled("Main", bEnableGo and true or false);
		itemObj["BtnGo"].pPanel:Sprite_SetGray("Main", bGrayGo and true or false);
	end
	local fnChangeShow = function (itemObj)
		self.bChangeFlag = true
		local bShow = not self.tbShowFlag[itemObj.nCardId]
		self.tbShowFlag[itemObj.nCardId] = bShow
		itemObj.pPanel:SetActive("Sprite", bShow and true or false)
		local parentObj = itemObj.parentObj
		parentObj.bShow = bShow
		parentObj.nCardId = itemObj.nCardId
		fnUpdateBtn(parentObj)
	end;
	local fnSelect = function (itemObj)
		self.nCardId = itemObj.nCardId
		self.nActTime = itemObj.nActTime
		self.nActState = itemObj.nActState
		self:HideMark()
		self:UpdateActType(self.nCardId)
		self:UpdateTimePanel()
		itemObj.pPanel:SetActive("Mark", true)
	end;

	local fnGo = function (itemObj)
		RemoteServer.PartnerCardOnClientCall("GoLiveNpc", itemObj.nCardId)
	end;
	local fnTask = function (itemObj)
		local bCanAcceptTask, szMsg = PartnerCard:CheckAcceptTask(me, itemObj.nCardId)
		if not bCanAcceptTask then
			me.CenterMsg(szMsg, true)
			return
		end
		local bOutSide = PartnerCard:IsActing(me.dwID, itemObj.nCardId, PartnerCard.CARD_ACT_STATE_VISIT) or PartnerCard:IsActing(me.dwID, itemObj.nCardId, PartnerCard.CARD_ACT_STATE_TRIP)
		if bOutSide then
			me.CenterMsg("该门客已被派遣外出", true)
			return 
		end
		if not itemObj.bShow then
			me.CenterMsg("门客已被隐藏", true)
			return
		end
		RemoteServer.PartnerCardOnClientCall("GoLiveNpc", itemObj.nCardId)
	end;
	local tbActSetting = PartnerCard:GetActSetting()
	local fnSetItem = function (itemObj, nIdx)
		local tbCardData = tbCardHouse[nIdx]
		itemObj["Guest"]:SetHeadByCardInfo(tbCardData.nPartnerTempleteId, tbCardData.nLevel)
		itemObj["Toggle"].pPanel:SetActive("Sprite", tbCardData.bShow and true or false)
		self.tbShowFlag[tbCardData.nCardId] = tbCardData.bShow
		itemObj["Toggle"].nCardId = tbCardData.nCardId
		itemObj["Toggle"].parentObj = itemObj
		itemObj["Toggle"].pPanel.OnTouchEvent = fnChangeShow;
		itemObj["BtnTask"].nCardId = tbCardData.nCardId
		itemObj["BtnTask"].bShow = tbCardData.bShow
		itemObj["BtnTask"].pPanel.OnTouchEvent = fnTask;
		itemObj["BtnGo"].nCardId = tbCardData.nCardId
		itemObj["BtnGo"].pPanel.OnTouchEvent = fnGo;
		itemObj.nCardId = tbCardData.nCardId
		itemObj.nActTime = tbCardData.nActTime
		itemObj.nActState = tbCardData.nActState
		itemObj.bShow = tbCardData.bShow
		fnUpdateBtn(itemObj)
		itemObj.pPanel.OnTouchEvent = fnSelect;
		itemObj.pPanel:SetActive("Mark", tbCardData.nCardId == self.nCardId and true or false)
		local bCardActAward
		for nActType in ipairs(tbActSetting) do
			if PartnerCard:CanGetActAward(me, tbCardData.nCardId, nActType) then
				bCardActAward = true 
				break
			end
		end
		itemObj.pPanel:SetActive("RedPoint", bCardActAward)
	end
	self.ScrollView:Update(tbCardHouse, fnSetItem);
	self:UpdateActType(self.nCardId)
	local bCanStart = PartnerCard:CheckStartTripFuben(me, self.nCardId)
	self.pPanel:SetActive("BtnHelp2", bCanStart)
	local nHouseLevel = PartnerCard:GetHouseLevel(me.dwID)
	local nMaxLiveHouse = PartnerCard.tbMaxLiveHouse[nHouseLevel] or 0 
	self.pPanel:Label_SetText("Tip1", string.format("入住数量（%s/%s）", #tbCardHouse, nMaxLiveHouse))
end

function tbUi:UpdateActType(nCardId)
	local tbUnlockActType = PartnerCard:GetCardUnlockActType(me.dwID, nCardId)
	local tbActSetting = PartnerCard:GetActSetting()
	for nActType, v in ipairs(tbActSetting) do
		local bUnLock = tbUnlockActType[nActType]
		self.pPanel:Button_SetEnabled("Btn" ..nActType, bUnLock and true or false);
		self.pPanel:Sprite_SetGray("Btn" ..nActType, (not bUnLock) and true or false);
		self.pPanel:Label_SetText("GuestTextDesc" ..nActType, string.format(v.szDes))
		self.pPanel:ResizeScrollViewBound("GuestDescScrollView" ..nActType, -180, 120);
		self.pPanel:DragScrollViewGoTop("GuestDescScrollView" ..nActType);

		local bCanGetActAward = PartnerCard:CanGetActAward(me, self.nCardId, nActType)
		self.pPanel:SetActive("Btn" ..nActType, not bCanGetActAward)
		self.pPanel:SetActive("BtnReceive" ..nActType, bCanGetActAward)
		self["BtnReceive" ..nActType].pPanel:SetActive("RedPoint" ..nActType, bCanGetActAward)

		self["Btn" ..nActType].pPanel:SetActive("Cost" ..nActType, false)
		self["Btn" ..nActType].pPanel:ChangePosition("Txt" ..nActType, 0, 0)
		self["Btn" ..nActType].pPanel:Label_SetFontSize("Txt" .. nActType, 25)
		local nActDegree = PartnerCard:GetActCount(me)
		local tbCost = PartnerCard.tbActCost[nActDegree] or {}
		local tbShowCost = tbCost[1]
		if tbShowCost then
			local szIcon, szIconAtlas
			local nType = Player.AwardType[tbShowCost[1]];
			local bLack
			local nCount, nHave = 0, 0

			if nType == Player.award_type_money then
				szIcon, szIconAtlas = Shop:GetMoneyIcon(tbShowCost[1])
				nHave = me.GetMoney(tbShowCost[1])
				nCount = tbShowCost[2]
				bLack = nHave < nCount
			elseif nType == Player.award_type_item then
				szIconAtlas, szIcon = Item:GetIcon(tbShowCost[2]);
				print(szIcon, szIconAtlas)
				nHave = me.GetItemCountInAllPos(tbShowCost[2]);
				nCount = tbShowCost[3]
				bLack = nHave < nCount
			end
			if szIcon and szIconAtlas then
				self["Btn" ..nActType].pPanel:SetActive("Cost" ..nActType, true)
				self["Btn" ..nActType].pPanel:Sprite_SetSprite("CostIcon" ..nActType, szIcon, szIconAtlas)
				self["Btn" ..nActType].pPanel:ChangePosition("Txt" ..nActType, 0, 9)
				self["Btn" ..nActType].pPanel:Label_SetFontSize("Txt" .. nActType, 20)

				local szColor = "FFFFFFFF"
				if bUnLock then
					szColor = bLack and "FF0000FF" or "6cff00" 
				end
				self["Btn" ..nActType].pPanel:Label_SetText("Cost" .. nActType, string.format("[%s]%s[-]", szColor, nCount))
			end
		end
	end
	local bCanStart = PartnerCard:CheckStartTripFuben(me, nCardId)
	self.pPanel:SetActive("BtnHelp2", bCanStart)
end

function tbUi:UpdateTimePanel()
	self:CloseActTimer()
	local tbActSetting = PartnerCard:GetActSetting()
	local nNowTime = GetTime()
	local nActType = self.nActState or 0
	local nActTime = self.nActTime or 0
	local bActing = false
	local tbUiSetting = self.tbUiSetting[nActType] or {}
	local szDes = tbUiSetting.szDes or ""
	local szTexturePath = tbUiSetting.szTexturePath or ""
	if not Lib:IsEmptyStr(szTexturePath) then
		self.pPanel:Texture_SetTexture("BigTexture", szTexturePath)
	end
	self.pPanel:Label_SetText("State", szDes)
	for nType, v in ipairs(tbActSetting) do
		self.pPanel:SetActive("Time" ..nType, false)
		if nActType == nType then
			local nPassActTime = nNowTime - nActTime
			if nPassActTime < PartnerCard.CARD_ACT_ACTIVE_TIME then
				bActing = true
				--self.pPanel:SetActive("Time" ..nType, true)
				self.nRemainActTime = PartnerCard.CARD_ACT_ACTIVE_TIME - nPassActTime - 1
				self.pPanel:Label_SetText("StateTime", Lib:TimeDesc3(self.nRemainActTime))
				self:StartActTimer()
			end
		end
	end
	self.pPanel:SetActive("PanelGroup", not bActing)
	self.pPanel:SetActive("Panel4", bActing)
end

function tbUi:StartActTimer()
	self.nActTimer = Timer:Register(Env.GAME_FPS, self.UpdateActTime, self)
end

function tbUi:UpdateActTime()
	if not self.nActState or not self.nRemainActTime then
		return false
	end
	self.pPanel:Label_SetText("StateTime", Lib:TimeDesc3(self.nRemainActTime))
	--self.pPanel:Label_SetText("Time" ..self.nActState, Lib:TimeDesc3(self.nRemainActTime))
	self.nRemainActTime = self.nRemainActTime - 1
	if self.nRemainActTime > 0 then
		return true
	else
		--self.pPanel:SetActive("Time" ..self.nActState, false)
		self.nActTimer = nil
		self:Update()
		return false
	end
end

function tbUi:CloseActTimer()
	if self.nActTimer then
		Timer:Close(self.nActTimer)
		self.nActTimer = nil
	end
end

function tbUi:HideMark()
	for i=0,100 do
		local pObj = self.ScrollView.Grid["Item" ..i]
		if not pObj then
			break
		end
		pObj.pPanel:SetActive("Mark", false)
	end
end

function tbUi:OnClose()
	if self.bChangeFlag then
		RemoteServer.PartnerCardOnClientCall("UpdateHouseCardShow", self.tbShowFlag)
	end
	self:CloseActTimer()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PARTNER_CARD_SYN_ACT_DATA, self.Update, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_ADD_STATE, self.Update, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD, self.Update, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

for nActType = 1, 3 do
	tbUi.tbOnClick["Btn" .. nActType] = function (self)
		local fnAddState = function ()
			local bRet, szMsg = PartnerCard:CheckAddStateCommon(me, self.nCardId, nActType)
			if not bRet then
				me.CenterMsg(szMsg, true)
				return 
			end
			if nActType == PartnerCard.CARD_ACT_STATE_VISIT then
				RemoteServer.PartnerCardOnClientCall("AddCardVisitState", self.nCardId)
			elseif nActType == PartnerCard.CARD_ACT_STATE_TRIP then
				RemoteServer.PartnerCardOnClientCall("AddCardTripState", self.nCardId)
			elseif nActType == PartnerCard.CARD_ACT_STATE_MUSE then
				RemoteServer.PartnerCardOnClientCall("AddCardMuseState", self.nCardId)
			end
		end
		local bRet, szMsg = PartnerCard:CheckAddStateCommon(me, self.nCardId, nActType)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end

		if nActType ~= PartnerCard.CARD_ACT_STATE_MUSE then
			local bCanAccept = PartnerCard:CheckAcceptTask(me, self.nCardId)
			if bCanAccept then
				me.MsgBox("派遣后，今日将无法接取该门客的任务，确定现在派遣吗？", {{"确定", fnAddState}, {"取消"}});
			else
				fnAddState()
			end
		else
			fnAddState()
		end
	end
	tbUi.tbOnClick["BtnReceive" .. nActType] = function (self)
		local bRet, szMsg = PartnerCard:CanGetActAward(me, self.nCardId, nActType)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end
		RemoteServer.PartnerCardOnClientCall("GetActAward", self.nCardId, nActType)
	end
end

tbUi.tbOnClick.BtnHelp2 = function (self)
	RemoteServer.PartnerCardOnClientCall("StartTripFuben", self.nCardId)
end

