local tbUi = Ui:CreateClass("PartnerCardDevilPanel");

tbUi.TYPE_ZaoRe = PartnerCard.DEVIL_STATE_HOT
tbUi.TYPE_CuoLuan = PartnerCard.DEVIL_STATE_LOST
tbUi.TYPE_KongJu = PartnerCard.DEVIL_STATE_FEAR

tbUi.tbSetting = 
{
	[tbUi.TYPE_ZaoRe] = {
		szEffectName = "BeiJing_ZaoRe";
		szDes = "门客现在身体燥热，需要马上进行降温";
		szState = "[87CEFA]门客状态：[-][FF0000]燥热[-]\n[87CEFA]剩余制服次数：[-]%d次\n[87CEFA]成功制服次数：[-]%d次";
		szCureWaitTxtName = "ColdTime";
		szCureSprite = "IconCold";
	};
	[tbUi.TYPE_CuoLuan] = {
		szEffectName = "BeiJing_JingMaiCuoLuan";
		szDes = "门客现在经脉紊乱，需要马上输入真气";
		szState = "[87CEFA]门客状态：[-][FF0000]经脉紊乱[-]\n[87CEFA]剩余制服次数：[-]%d次\n[87CEFA]成功制服次数：[-]%d次";
		szCureWaitTxtName = "TureTime";
		szCureSprite = "IconTure";
	};
	[tbUi.TYPE_KongJu] = {
		szEffectName = "BeiJing_KongJu";
		szDes = "门客现在异常恐惧，需要马上进行安抚";
		szState = "[87CEFA]门客状态：[-][FF0000]恐惧[-]\n[87CEFA]剩余制服次数：[-]%d次\n[87CEFA]成功制服次数：[-]%d次";
		szCureWaitTxtName = "TouchTime";
		szCureSprite = "IconTouch";
	};
}
function tbUi:OnOpen(nOwnPlayerId, nCardId)
	RemoteServer.PartnerCardOnClientCall("SynDevilCardInfo", nOwnPlayerId, nCardId)
	self:Update(nOwnPlayerId, nCardId)
end

function tbUi:Update(nOwnPlayerId, nCardId)
	self.nOwnPlayerId = nOwnPlayerId or self.nOwnPlayerId
	self.nCardId = nCardId or self.nCardId
	self.pPanel:SetActive("BeiJing_ZaoRe", false)
	self.pPanel:SetActive("BeiJing_JingMaiCuoLuan", false)
	self.pPanel:SetActive("BeiJing_KongJu", false)
	local tbDevilCardInfo = PartnerCard:GetDevilCardInfo()
	local nTriggerDevilTime = tbDevilCardInfo.nTriggerDevilTime or 0
	local nCureCount = tbDevilCardInfo.nCureCount or 0
	local tbIll = tbDevilCardInfo.tbIll or {}
	local nLift = tbDevilCardInfo.nLife or 100
	local nCureOk = tbDevilCardInfo.nCureOk or 0
	local tbMsg = tbDevilCardInfo.tbMsg or {}
	self.nCureCount = nCureCount 
	self.nCureOk = nCureOk
	self.nLift = nLift
	local nNowTime = GetTime()

	if nTriggerDevilTime > nNowTime or nTriggerDevilTime + PartnerCard.nDevilStayTime <= nNowTime then
		return
	end
	local nIllIndex = PartnerCard:GetDevilIllIndex(nTriggerDevilTime)
	local nIll = tbIll[nIllIndex]
	if not nIll then
		return
	end
	self.nIllIndex = nIllIndex
	self.nTriggerDevilTime = nTriggerDevilTime
	self.tbIll = tbIll
	self.tbMsg = tbMsg
	for nType, v in pairs(self.tbSetting) do
		if nIll == nType then
			self.pPanel:SetActive(v.szEffectName, self.nLift > 0)
			self:UpdateInfo()
		end
		self.pPanel:SetActive(v.szCureWaitTxtName, false)
		self.pPanel:Sprite_SetFillPercent(self.tbSetting[nType].szCureSprite, 1)
	end
	self:UpdateMsg()
	self:CloseTimer()
	-- 先把当前病态的剩余时间播放
	local nNextRemainTime = PartnerCard.nDevilChangeStateInterval - (nNowTime - nTriggerDevilTime) % PartnerCard.nDevilChangeStateInterval
	self.nStartEffectTimer = Timer:Register(math.max(1, Env.GAME_FPS * nNextRemainTime), self.StartChangeEffect, self)

	local tbCardInfo = PartnerCard:GetCardInfo(nCardId)
	if tbCardInfo then
		local _, nResId = KNpc.GetNpcShowInfo(tbCardInfo.nNpcTempleteId);
		self.pPanel:NpcView_Open("PartnerView");
		self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	end
end

function tbUi:UpdateInfo(nCureCount, nCureOk)
	self.nCureCount = nCureCount or self.nCureCount
	self.nCureOk = nCureOk or self.nCureOk
	local nIll = self.tbIll[self.nIllIndex] 
	local tbSettingInfo = self.tbSetting[nIll]
	if not tbSettingInfo then
		return
	end
	self.pPanel:SetActive("Tip", self.nLift > 0)
	self.pPanel:SetActive("Text", self.nLift > 0)
	self.pPanel:Label_SetText("Tip", tbSettingInfo.szDes)
	local szState = string.format(tbSettingInfo.szState, PartnerCard.DEVIL_MAX_CURE - self.nCureCount, self.nCureOk) 
	self.pPanel:Label_SetText("Text", szState)
	self:UpdateLift(self.nLift)
end

function tbUi:StartCureTimer(nType)
	self:CloseCureTimer()
	self.nWaitCure = PartnerCard.DEVIL_CURE_WAIT
	for nIll, v in pairs(self.tbSetting) do
		if nIll == nType then
			self.pPanel:SetActive(v.szCureWaitTxtName, true)
			self.pPanel:Label_SetText(v.szCureWaitTxtName, string.format("%d秒", self.nWaitCure))
		else
			self.pPanel:SetActive(v.szCureWaitTxtName, false)
		end
		self.pPanel:Sprite_SetFillPercent(self.tbSetting[nIll].szCureSprite, 1)
	end
	
	self.nCureTimer = Timer:Register(Env.GAME_FPS, self.UpdateCurWait, self, nType)
end

function tbUi:UpdateCurWait(nType)
	self.nWaitCure = self.nWaitCure - 1
	self.pPanel:Label_SetText(self.tbSetting[nType].szCureWaitTxtName, string.format("%d秒", self.nWaitCure))
	local nPercent = self.nWaitCure / PartnerCard.DEVIL_CURE_WAIT
	self.pPanel:Sprite_SetFillPercent(self.tbSetting[nType].szCureSprite, nPercent)
	if self.nWaitCure <= 0 then
		self.nCureTimer = nil
		self.pPanel:SetActive(self.tbSetting[nType].szCureWaitTxtName, false)
		RemoteServer.PartnerCardOnClientCall("CureDevil", self.nOwnPlayerId, self.nCardId, nType)
		self.pPanel:Sprite_SetFillPercent(self.tbSetting[nType].szCureSprite, 1)
	end
	return self.nWaitCure > 0
end

function tbUi:CloseCureTimer()
	if self.nCureTimer then
		Timer:Close(self.nCureTimer)
		self.nCureTimer = nil
	end
end

function tbUi:UpdateLift(nLift)
	self.nLift = nLift
	local nPercent = nLift / PartnerCard.DEVIL_MAX_LIFE
	nPercent = math.min(nPercent, 1)
	nPercent = math.max(nPercent, 0)
	self.pPanel:Sprite_SetFillPercent("Bar01", nPercent)
end

function tbUi:StartChangeEffect()
	self:ChangeEffect()
	self.nStartEffectTimer = nil
	self.nEffectTimer = Timer:Register(Env.GAME_FPS * PartnerCard.nDevilChangeStateInterval, self.ChangeEffect, self)
end

function tbUi:CloseEffectTimer()
	if self.nStartEffectTimer then
		Timer:Close(self.nStartEffectTimer)
		self.nStartEffectTimer = nil
	end
	if self.nEffectTimer then
		Timer:Close(self.nEffectTimer)
		self.nEffectTimer = nil
	end
end

function tbUi:ChangeEffect()
	self.nIllIndex = PartnerCard:GetDevilIllIndex(self.nTriggerDevilTime)
	local nIll = self.tbIll[self.nIllIndex]
	if nIll then
		for nType, v in pairs(self.tbSetting) do
			self.pPanel:SetActive(v.szEffectName, false)
			if nIll == nType then
				self.pPanel:SetActive(v.szEffectName,  self.nLift > 0)
				self:UpdateInfo()
			end
		end
	end
	return true
end

function tbUi:CloseTimer()
	self:CloseEffectTimer()
	self:CloseCureTimer()
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:OnLiftChnage(nOwnPlayerId, nCardId, nLife)
	if self.nOwnPlayerId == nOwnPlayerId and self.nCardId == nCardId then
		self:UpdateLift(nLife)
	end
end

function tbUi:UpdateMsg(tbMsg)
	self.tbMsg = tbMsg or self.tbMsg
	local tbShowMsg = Lib:CopyTB(self.tbMsg)
	local szMsg = table.concat(tbShowMsg, "\n")
	self.pPanel:Label_SetText("DonationRecordItem", szMsg or "")
end

function tbUi:OnMsgChange(nOwnPlayerId, nCardId, tbMsg)
	if self.nOwnPlayerId == nOwnPlayerId and self.nCardId == nCardId then
		self:UpdateMsg(tbMsg)
	end
end

function tbUi:OnEnd(nOwnPlayerId, nCardId)
	if self.nOwnPlayerId == nOwnPlayerId and self.nCardId == nCardId then
		Ui:CloseWindow(self.UI_NAME)
	end
end


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PARTNER_CARD_SSYN_DEVIL, self.Update, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_LIFE_CHANGE, self.OnLiftChnage, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_COUNT_CHANGE, self.UpdateInfo, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_MSG_CHANGE, self.OnMsgChange, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_END, self.OnEnd, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnCold = function (self)
	if self.nCureCount >=  PartnerCard.DEVIL_MAX_CURE then
		me.CenterMsg("没有剩余制服次数", true)
		return 
	end
	self:StartCureTimer(self.TYPE_ZaoRe)
end

tbUi.tbOnClick.BtnTouch = function (self)
	if self.nCureCount >=  PartnerCard.DEVIL_MAX_CURE then
		me.CenterMsg("没有剩余制服次数", true)
		return 
	end
	self:StartCureTimer(self.TYPE_KongJu)
end

tbUi.tbOnClick.BtnTure = function (self)
	if self.nCureCount >=  PartnerCard.DEVIL_MAX_CURE then
		me.CenterMsg("没有剩余制服次数", true)
		return 
	end
	self:StartCureTimer(self.TYPE_CuoLuan)
end
