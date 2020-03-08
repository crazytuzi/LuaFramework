
local tbUi = Ui:CreateClass("RechargeGift");

function tbUi:OnOpen()
	self:RefreshUi();
end

function tbUi:OnClose()
end

function tbUi:RefreshUi()
	local tbShowType = {1,2}
	if Recharge:IsCanBuySuperDaysCard(me, 3) or Recharge:GetDaysCardLeftDay(me, 3) > 0 then
		table.insert(tbShowType, 3)
	end

	local _,_,nExtra = Recharge:IsOnActvityDay()
	if nExtra > 0 then
		self.pPanel:SetActive("RechargeGiftTip", false)	
	else
		self.pPanel:SetActive("RechargeGiftTip", false)
	end

	local tbGroup = Recharge.tbSettingGroup.DaysCard
	local bIsLotteryOpen = Lottery:IsOpen();

	local fnSetItem = function (itemObj, i)
		Ui.UnRegisterRedPoint("DaysCard" .. i)
		itemObj.BtnReceive.pPanel:RegisterRedPoint("redspot", "DaysCard" .. i)
		if nExtra > 0 then
			itemObj.pPanel:SetActive("Extra", true)
			itemObj.pPanel:Label_SetText("ExtraAmount", string.format("%d%%", nExtra))
		else
			itemObj.pPanel:SetActive("Extra", false)
		end

		local nState, nLeftAwardDay = Recharge:GetDayCardAwardState(i)
		local tbBuyInfo = tbGroup[i];
		itemObj.pPanel:Sprite_SetSprite("SpriteItem", tbBuyInfo.szSprite)
		itemObj.pPanel:Label_SetText("RechargeTitle", tbBuyInfo.szNoromalDesc)
		local nBuyGetGold = Recharge:GetGoldNumFromAward(tbBuyInfo.tbAward)
		local nDayGetGold = Recharge:GetGoldNumFromAward(Recharge:GetDayCardAward(i))

		local nTotalGold = nBuyGetGold + nDayGetGold * tbBuyInfo.nLastingDay
		if version_vn or version_kor or version_th  then
			itemObj.pPanel:Label_SetText("RechargeDetails", string.format("立得   [FF8613]%d[-]   元宝，每天领   [FF8613]%d[-]  元宝", nBuyGetGold, nDayGetGold))
			itemObj.pPanel:Label_SetText("Label1_1", string.format("总计  [FF8613] %d [-]  元宝", nTotalGold))
		else
			itemObj.pPanel:Label_SetText("Label1_1", nBuyGetGold)
			itemObj.pPanel:Label_SetText("Label1_2", nDayGetGold)
			itemObj.pPanel:Label_SetText("Label1_3", nTotalGold)
		end
		local szMoneyType = tbBuyInfo.szMoneyType
		local tbMoneShowInfo = Recharge.tbMoneyName[szMoneyType]
		local szMoneyName = tbMoneShowInfo[1]

		if nState == 0 then --只是购买
			itemObj.pPanel:SetActive("BtnBuy", true)
			itemObj.BtnBuy.pPanel.OnTouchEvent = function ()
				Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_MON_NEW, i)
			end
			itemObj.pPanel:SetActive("BtnRenew", false)
			itemObj.pPanel:SetActive("BtnReceive", false)
			itemObj.pPanel:SetActive("LimitTxt", false) 
			local tbMoneyShowInfo = Recharge.tbMoneyName[tbBuyInfo.szMoneyType]
			local szMoneyAmout = string.format(tbMoneyShowInfo[3], tbBuyInfo.nMoney * tbMoneyShowInfo[4])
			if version_vn then
				szMoneyAmout = Lib:ThousandSplit(tbBuyInfo.nMoney * tbMoneyShowInfo[4])
			end
			if version_kor then
				itemObj.pPanel:Button_SetText("BtnBuy", string.format("%s%s", szMoneyName, szMoneyAmout))
			else
				itemObj.pPanel:Button_SetText("BtnBuy", string.format("%s%s购买", szMoneyAmout, tbMoneyShowInfo[1]))
			end
		else
			--已买
			itemObj.pPanel:SetActive("BtnBuy", false)
			local nLeftTime = Recharge:GetDaysCardLeftTime(me, i)
			local bShowRenew = false;
			if nLeftTime <= Recharge.tbDaysCardBuyLimitDay[i] * 3600 * 24 and Recharge:IsCanBuySuperDaysCard(me, i) then
				bShowRenew = true
			end
			itemObj.pPanel:SetActive("BtnRenew", bShowRenew)
			itemObj.BtnRenew.pPanel.OnTouchEvent = function ()
				Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_GIFT, Recharge.CLICK_ID_GIFT_MON_RE, i)
			end
			itemObj.pPanel:SetActive("BtnReceive", true)
			itemObj.pPanel:SetActive("LimitTxt", true)

			itemObj.pPanel:Label_SetText("LimitTxt", string.format("剩余%d天", nLeftAwardDay))

			if nState == 1 then --领取
				itemObj.pPanel:Button_SetEnabled("BtnReceive", true)
				itemObj.pPanel:Button_SetText("BtnReceive", "领取")
				itemObj.BtnReceive.pPanel.OnTouchEvent = function ()
					RemoteServer.TakeDaysCardAward(i)
				end
			elseif nState == 2 then   --已领
				itemObj.pPanel:Button_SetEnabled("BtnReceive", false)
				itemObj.pPanel:Button_SetText("BtnReceive", "已领取")
			end
		end
		itemObj.pPanel:SetActive("Vips", bIsLotteryOpen);
		if bIsLotteryOpen then
			itemObj.pPanel:Label_SetText("Vips", string.format("每次领取获盟主的馈赠%d张", Lottery:GetAwardTicketCount(i == 2 and "Monthly" or "Weekly")));
		end
	end
	self.ScrollView:Update(tbShowType, fnSetItem)

    local bNotGetedFirst = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 0
    self.pPanel:SetActive("RechargeGiftTxt", bNotGetedFirst)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_LOTTERY_DATA,      self.RefreshUi },
    };
    return tbRegEvent;
end
