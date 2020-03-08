local tbUi = Ui:CreateClass("CardPicking");

function tbUi:Init()
	RemoteServer.SynPartnerCardPickData();
	CardPicker:UpdateRemoteInfo();
	self:Update();

	self.pPanel:Label_SetText("TxtGoldPickCost", CardPicker.Def.nGoldCost);
	self.pPanel:Label_SetText("TxtJadePickCost", CardPicker.Def.nCoinCost);
	self.pPanel:Label_SetText("TxtJadePickTenCost", CardPicker.Def.nCoinTenCost);

	if not self.nCountDownTimer then
		self.nCountDownTimer = Timer:Register(Env.GAME_FPS, self.LeftTimeCountDown, self);
	end

	self:LeftTimeCountDown();
	local szGoldTip = GetTimeFrameState(PartnerCard.szFuncOpenTimeFrame) ~= 1 and "购买有机会赠送\n#956#955#954 级同伴及洗髓" or "购买有机会赠送\n#858#956 级同伴及本命武器\n#858#956 级门客及友好道具"
	self.pPanel:Label_SetText("CardPickingGoldTip", string.format(szGoldTip))
end

function tbUi:LeftTimeCountDown()
	local nNow = GetTime();
	local nLeftFreeTime = CardPicker:GetNextFreePickTime() - nNow;
	if nLeftFreeTime <= 0 then
		self.pPanel:Label_SetText("TxtGoldFreePickCountdown", "本次免费");
		self.pPanel:SetActive("BtnGoldFreePick", true);
		self.pPanel:SetActive("BtnGoldPick", false);
	else
		self.pPanel:SetActive("BtnGoldFreePick", false);
		self.pPanel:SetActive("BtnGoldPick", true);

		local szLeftTime = Lib:TimeDesc3(nLeftFreeTime);
		local szCountdown = string.format("%s 后免费", szLeftTime);
		self.pPanel:Label_SetText("TxtGoldFreePickCountdown", szCountdown);
	end

	local nLeftCoinFreeTime = CardPicker:GetNextCoinFreePickTime() - nNow;
	if nLeftCoinFreeTime <= 0 then
		self.pPanel:Label_SetText("TxtCoinFreePickCountdown", "本次免费");
		self.pPanel:SetActive("BtnJadeFreePick", true);
		self.pPanel:SetActive("BtnJadePick", false);
	else
		self.pPanel:SetActive("BtnJadeFreePick", false);
		self.pPanel:SetActive("BtnJadePick", true);

		local szLeftTime = Lib:TimeDesc3(nLeftCoinFreeTime);
		local szCountdown = string.format("%s 后免费", szLeftTime);
		self.pPanel:Label_SetText("TxtCoinFreePickCountdown", szCountdown);
	end

	return true;
end

function tbUi:Update()
	Partner:UpdateRedPoint();
	self.pPanel:Label_SetText("TxtMyJade", me.GetMoney("Coin"));
	self.pPanel:Label_SetText("TxtMyGold", me.GetMoney("Gold"));

	local nGoldTenCost, nOnSaleFlag = CardPicker:GetGoldTenCost();
	self.pPanel:Label_SetText("TxtGoldTenPickCost", nGoldTenCost);
	self.pPanel:Label_SetText("TxtOriginalPrice", CardPicker.Def.nGoldTenCost);
	self.pPanel:Label_SetText("TxtPresentprice", nGoldTenCost);
	self.pPanel:SetActive("Discount", nOnSaleFlag and true or false);
	self.pPanel:SetActive("WeekenderTip", nOnSaleFlag and true or false);
	self.pPanel:SetActive("IconGoldTenCost", not nOnSaleFlag);

	if nOnSaleFlag then
		local szSpriteName = string.format("Discount%d", nGoldTenCost * 10 / CardPicker.Def.nGoldTenCost);
		self.pPanel:Sprite_SetSprite("Discount", szSpriteName);
	end

	self:SetAllButtonState(true);

	local nLeftSTime = CardPicker:GetLeftSTime();
	if not nLeftSTime or nLeftSTime == 10 then
		self.pPanel:SetActive("GoldPickLeft10Tip", true);
		self.pPanel:SetActive("GoldPickLeftTip", false);
	else
		self.pPanel:SetActive("GoldPickLeft10Tip", false);
		self.pPanel:SetActive("GoldPickLeftTip", true);
		local szPickCountDown = string.format("再招募%d次必得  #956  级同伴", nLeftSTime);
		self.pPanel:Label_SetText("TxtGoldPickTips", szPickCountDown);
	end
	local bRunningAct = Activity:__IsActInProcessByType("PartnerCardPickAct") and PartnerCard:IsOpen()
	local nTenGoldPickCount = PartnerCard.nTenGoldPickCount
	if not bRunningAct or not nTenGoldPickCount or nTenGoldPickCount >= PartnerCard.nMaxPickCard then
		self.pPanel:SetActive("EntourageTime", false)
	else
		self.pPanel:SetActive("EntourageTime", true)
		local nRemain = PartnerCard.nMaxPickCard - nTenGoldPickCount
		self.pPanel:Label_SetText("TxtPickCountdown", string.format("门客招募剩余[FFD700]%s[-]次", nRemain))
	end
end

function tbUi:SetAllButtonState(bEnable)
	self.pPanel:Button_SetEnabled("BtnGoldPick", bEnable);
	self.pPanel:Button_SetEnabled("BtnGoldFreePick", bEnable);
	self.pPanel:Button_SetEnabled("BtnJadePick", bEnable);
	self.pPanel:Button_SetEnabled("BtnJadeFreePick", bEnable);
	self.pPanel:Button_SetEnabled("BtnJadeTenPick", bEnable);
	self.pPanel:Button_SetEnabled("BtnGoldTenPick", bEnable);
end

function tbUi:OnClose()
	if self.nCountDownTimer then
		Timer:Close(self.nCountDownTimer);
		self.nCountDownTimer = nil;
	end
end

function tbUi:CheckTooManyPartners()
	local tbAllPartner = me.GetAllPartner();
	if Lib:CountTB(tbAllPartner) < Partner.MAX_PARTNER_COUNT then
		return false;
	end

	me.MsgBox(string.format("你携带的同伴过多，请先遣散部分同伴后再来招募吧！"), {{"前去遣散", function () Ui:OpenWindow("Partner", "PartnerDecomposePanel"); end}, {"取消"}});

	return true;
end

tbUi.tbOnClick = {};
if version_kor then
	function tbUi.tbOnClick:BtnProbability()
		Sdk:OpenUrl("https://cafe.naver.com/clansmobile/7662")
	end
end

function tbUi.tbOnClick:BtnJadePick()
	if self:CheckTooManyPartners() then
		return;
	end

	if me.GetMoney("Coin") < CardPicker.Def.nCoinCost then
		me.CenterMsg("您的银两不足");
		return false;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 1 then
		me.CenterMsg(szMsg)
		return false;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "CoinPick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("CoinPick");
end

function tbUi.tbOnClick:BtnJadeFreePick()
	if self:CheckTooManyPartners() then
		return;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 1 then
		me.CenterMsg(szMsg)
		return false;
	end

	local nLeftFreeTime = CardPicker:GetNextCoinFreePickTime() - GetTime();
	if nLeftFreeTime > 0 then
		me.CenterMsg("免费招募时间未到");
		return;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "CoinPick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("CoinFreePick");
end

function tbUi.tbOnClick:BtnJadeTenPick()
	if self:CheckTooManyPartners() then
		return;
	end

	if me.GetMoney("Coin") < CardPicker.Def.nCoinTenCost then
		me.CenterMsg("您的银两不足");
		return false;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 10 then
		me.CenterMsg(szMsg)
		return false;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "CoinTenPick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("CoinTenPick");
end

function tbUi.tbOnClick:BtnGoldPick()
	if self:CheckTooManyPartners() then
		return;
	end

	if me.GetMoney("Gold") < CardPicker.Def.nGoldCost then
		me.CenterMsg("您的元宝不足");
		return false;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 1 then
		me.CenterMsg(szMsg)
		return false;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "GoldPick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("GoldPick");
end

function tbUi.tbOnClick:BtnGoldTenPick()
	if self:CheckTooManyPartners() then
		return;
	end

	local nGoldTenCost = CardPicker:GetGoldTenCost();
	if me.GetMoney("Gold") < nGoldTenCost then
		me.CenterMsg("您的元宝不足");
		return false;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 10 then
		me.CenterMsg(szMsg)
		return false;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "GoldTenPick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("GoldTenPick", nGoldTenCost);
end

function tbUi.tbOnClick:BtnGoldFreePick()
	if self:CheckTooManyPartners() then
		return;
	end

	self.pPanel:SetActive("BtnGoldFreePick", false);
	local nNow = GetTime();
	local nLeftFreeTime = CardPicker:GetNextFreePickTime() - nNow;
	if nLeftFreeTime > 0 then
		me.CenterMsg("免费招募时间未到");
		return;
	end

	local nFree, szMsg = me.GetFreeBagCount()
	if nFree < 1 then
		me.CenterMsg(szMsg)
		return false;
	end

	self:SetAllButtonState(false);
	Ui:OpenWindow("CardPickingResult", "GoldFreePick");
	CardPicker:ClearResultCache();
	RemoteServer.OnCardPickerRequest("GoldFreePick");

	Guide.tbNotifyGuide:ClearNotifyGuide("PickCard", true);
end

function tbUi.tbOnClick:BtnPreview1()
	Ui:OpenWindow("CardPreview", "Coin");
end

function tbUi.tbOnClick:BtnPreview2()
	Ui:OpenWindow("CardPreview", "Gold");
end
