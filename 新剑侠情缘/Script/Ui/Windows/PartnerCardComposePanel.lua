local tbUi = Ui:CreateClass("PartnerCardComposePanel");

function tbUi:OnOpen(nCardId, nItemTemplateId)
	self:Update(nCardId, nItemTemplateId)
end

function tbUi:Update(nCardId, nItemTemplateId)
	local tbComposeInfo = PartnerCard:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return
	end
	self.nCardId = nCardId
	self.nItemTID = nItemTemplateId
	local tbComposeData = PartnerCard:GetComposeData()
	local tbCardCompose = tbComposeData[nCardId] or {}
	local nNowTime = GetTime()
	local nRequestComposeTime = tbCardCompose.nComposeTime or 0
	local tbComposeInfo = PartnerCard:GetComposeInfo(nCardId)
	self.nWaitTime = math.max(PartnerCard.CARD_COMPOSE_TIME + nRequestComposeTime - nNowTime, 0) 
	self:UpdateTxt()
	local szWaitTime = Lib:TimeDesc3(self.nWaitTime)
	self.pPanel:Label_SetText("Time", szWaitTime)
	local szName = tbComposeInfo.szName or ""
	local szIntro = tbComposeInfo.szIntro or ""
	local tbDetail = tbComposeInfo.tbDetail or ""
	local tbAward = tbComposeInfo.tbAward
	self.pPanel:Label_SetText("Name", szName)
	self.pPanel:Label_SetText("Describe", szIntro)
	local szDetail = ""
	for _, v in ipairs(tbDetail) do
		local szDes = v[1]
		local szDetailCheck = v[2]
		local szCheckFun = string.format("Compose%s", szDetailCheck)
		local tbParam = v[3] or {}
		if PartnerCard[szCheckFun] then
			local bRet = PartnerCard[szCheckFun](PartnerCard, me, nCardId, unpack(tbParam))
			szDes = bRet and string.format("[00FF00]%s[-]", szDes) or string.format("[EE0000]%s[-]", szDes)
		end
		szDetail = szDetail .. szDes
	end
	self.pPanel:Label_SetText("Condition", szDetail)
	local bCanCompose = PartnerCard:CanComposeCard(me, nCardId, true)
	local bCanUse = (bCanCompose and nItemTemplateId) and true or false
	local szButtonTxt = "布阵解除"
	if not nItemTemplateId then
		szButtonTxt = "解除中..."
		local bCanFinish = PartnerCard:CheckFinishComposeCard(me, nCardId)
		if bCanFinish then
			bCanUse = true
			szButtonTxt = "完成解封"
		end
	end
	self.pPanel:Label_SetText("BtnTxt", szButtonTxt)
	self.pPanel:Button_SetEnabled("BtnUnsealing", bCanUse and true or false);
	self.pPanel:Sprite_SetGray("BtnUnsealing", not bCanUse and true or false);
	self["Item"]:SetGenericItem({"item", tbComposeInfo.nShowItem, 1})
	self:CloseTimer()
	if self.nWaitTime > 0 then
		self:StartTimer()
	end
end

function tbUi:UpdateTxt()
	self.pPanel:SetActive("Time", self.nWaitTime > 0)
end

function tbUi:StartTimer()
	self.nComposeTimer = Timer:Register(Env.GAME_FPS, function () 
			self.nWaitTime = self.nWaitTime - 1
			self:UpdateTxt()
			local szWaitTime = Lib:TimeDesc3(math.max(self.nWaitTime, 0))
			self.pPanel:Label_SetText("Time", szWaitTime)
			if self.nWaitTime <= 0 then
				self.nComposeTimer = nil
				self.pPanel:Button_SetEnabled("BtnUnsealing", true);
				self.pPanel:Sprite_SetGray("BtnUnsealing", false);
				self.pPanel:Label_SetText("BtnTxt", "完成解封")
				return false
			end
			return true
		end)
end

function tbUi:CloseTimer()
	if self.nComposeTimer then
		Timer:Close(self.nComposeTimer)
		self.nComposeTimer = nil
	end
end

function tbUi:OnClose()
	self.nItemTID = nil
	self.nCardId = nil
	self:CloseTimer()
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnUnsealing = function (self)
	if not House.bHasHouse then
		me.CenterMsg("大侠还没有家园", true)
		return
	end
	if not self.nItemTID then
		local bCanFinish, szMsg = PartnerCard:CheckFinishComposeCard(me, self.nCardId)
		if not bCanFinish then
			me.CenterMsg(szMsg, true)
			return
		end
		RemoteServer.PartnerCardOnClientCall("FinishComposeCard", self.nCardId)
	else
		if House:IsInOwnHouse(me) then
			local bRet, szMsg = PartnerCard:CanComposeCard(me, self.nCardId)
			if not bRet then
				me.CenterMsg(szMsg, true)
				return 
			end
			RemoteServer.PartnerCardOnClientCall("ApplyComposeCard", self.nItemTID)
		else
			RemoteServer.PartnerCardOnClientCall("GoComposeCard")
		end
	end
end