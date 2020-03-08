local tbGrid = Ui:CreateClass("RechargeGrid");

tbGrid.tbOnClick = {}

local fnBuyFunc = function (tbInfo)
	if tbInfo then
		local szGroup = tbInfo.szGroup
		if szGroup == "DaysCard" then
			Recharge:RequestBuyDaysCard(Recharge.PAGE_ID_SHOP, (tbInfo.nGroupIndex == 1 and Recharge.CLICK_ID_SHOP_WEEK or Recharge.CLICK_ID_SHOP_MONTH), tbInfo.nGroupIndex)
		else
			Recharge:RequestBuyGold(tbInfo)
		end
	end
end

tbGrid.tbOnClick.Product1 = function (self)
	fnBuyFunc(self.tbData[1])
end

tbGrid.tbOnClick.Product2 = function (self)
	fnBuyFunc(self.tbData[2])
end

tbGrid.tbOnClick.Product3 = function (self)
	fnBuyFunc(self.tbData[3])
end


local tbUi = Ui:CreateClass("RechargePanel");
tbUi.tbVipLevelDesc = {
	[1]  = "[fefb1a]●  剑侠尊享1专属身份标识[-]",
	[2]  = "[fefb1a]●  2倍红包发放资格[-]",
	[3]  = "[fefb1a]●  3元超值礼包购买资格[-]",
	[4]  = "[fefb1a]●  3倍红包发放资格[-]",
	[5]  = "[fefb1a]●  6元超值礼包购买资格[-]",
	[6]  = "[fefb1a]●  剑侠尊享6专属身份标识[-]",
	[7]  = "[fefb1a]●  6倍红包发放资格[-]",
	[8]  = "[fefb1a]●  剑侠尊享8专属聊天头像框&多彩泡泡[-]",
	[9]  = "[fefb1a]●  剑侠尊享9专属身份标识[-]",
	[10] = "[fefb1a]●  商城外装赠送特权[-]",
	[11] = "[fefb1a]●  家族语音聊天时长增加至每条30秒[-]",
	[12] = "[fefb1a]●  剑侠尊享12专属身份标识[-]",
	[13] = "[fefb1a]●  剑侠尊享13专属聊天头像框&多彩泡泡[-]",
	[14] = "[fefb1a]●  家族捐献获得贡献增加20%[-]",
	[15] = "[fefb1a]●  剑侠尊享15专属聊天头像框&多彩泡泡[-]",
	[16] = "[fefb1a]●  剑侠尊享16专属身份标识[-]",
	[17] = "[fefb1a]●  传功无冷却时间[-]",
	[18] = "[fefb1a]●  剑侠尊享18专属聊天头像框&多彩泡泡[-]",
	[19] = "[fefb1a]●  剑侠尊享19[-]",
	[20] = "[fefb1a]●  剑侠尊享20[-]",
	[21] = "[fefb1a]●  剑侠尊享21[-]",
	[22] = "[fefb1a]●  剑侠尊享22[-]",
	[23] = "[fefb1a]●  剑侠尊享23[-]",
	[24] = "[fefb1a]●  剑侠尊享24[-]",
	[25] = "[fefb1a]●  剑侠尊享25[-]",
}

function tbUi:GenarateSellItems()
	local tbShows = {}
	if Recharge:IsShowProGroupInPanel("DaysCard", "RechargePanel") then
		for i, v in ipairs(Recharge.tbSettingGroup.DaysCard) do
			local nLeftDay = Recharge:GetDaysCardLeftDay(me, v.nGroupIndex)
			if nLeftDay  <= Recharge.tbDaysCardBuyLimitDay[v.nGroupIndex] then
				table.insert(tbShows, v)
			end
		end
	end
	for i,v in ipairs(Recharge.tbSettingGroup.BuyGold) do
		table.insert(tbShows, v)
	end

	local tbGroups = {}
	for i,v in ipairs(tbShows) do
		local tbLastOne = tbGroups[#tbGroups]
		if not tbLastOne or #tbLastOne >= 3 then
			table.insert(tbGroups, {})
			tbLastOne = tbGroups[#tbGroups]
		end
		table.insert(tbLastOne, v)
	end

	return tbGroups;
end

function tbUi:OnOpenEnd(szPage)
	local nVipLevel = me.GetVipLevel();
	if szPage then
		if szPage == "Recharge" then
			self:ShowRecharge()
		elseif szPage == "Vip" then
			self:ShowVip(nVipLevel)
		end
		self.szCurPage = szPage
	else
		if self.szCurPage == "Vip" then
			self:ShowVip()
		else
			self:ShowRecharge()
		end
	end

	if Client:IsCloseIOSEntry() then
		--self.pPanel:SetActive("BtnHelp", false);
		self.pPanel:SetActive("BtnHelpRecharge", false);
	else
		self.pPanel:SetActive("BtnHelpRecharge", Sdk:IsMsdk() or version_xm);
		--self.pPanel:SetActive("BtnHelp", Sdk:IsMsdk());
	end
	self:ShowNextVipLvRecharge()
end

function tbUi:ShowRecharge()
	self.szCurPage = "Recharge"
	self.pPanel:SetActive("RechargePage", true)
	self.pPanel:SetActive("ThaiTopup", false)
	self.pPanel:SetActive("VipPrivilege", false)
	self.pPanel:Button_SetSprite("BtnRecharge", "BtnVIP", 0);

	local bRechareGetted = Recharge:IsRechareGetted()
	self.pPanel:SetActive("NotAccount", not bRechareGetted)

	if version_hk or version_tw then
		self.pPanel:SetActive("BtnMore", Sdk:XGSurportThridPay());
	elseif version_th and Sdk:XGIsWinnerThirdPay() then
		self.pPanel:SetActive("RechargePage", false);
		self.pPanel:SetActive("ThaiTopup", true);
		return;
	end

	local tbGroups = self:GenarateSellItems()
	self.tbGroups = tbGroups
	local nBuyedFlag = Recharge:GetBuyedFlag(me)
	local tbBit = KLib.GetBitTB(nBuyedFlag)

	local fnSetItem = function (tbItem, nIndex)
		local tbOne = tbGroups[nIndex]
		tbItem.tbData = tbOne
		for i = 1, 3 do
			local v = tbOne[i]
			if not v then
				tbItem.pPanel:SetActive("Product".. i, false)
			else
				tbItem.pPanel:SetActive("Product".. i, true)

				local bShowRecommend = false;
				local szTopTip = "";
				local nLeftDay;
				local szGroup = v.szGroup
				local bDaysCard = false;
				if szGroup == "DaysCard" then
					nLeftDay = Recharge:GetDaysCardLeftDay(me, v.nGroupIndex)
					-- if not nLeftDay or nLeftDay <= 0 then
						-- bShowRecommend = true
					-- end
					bDaysCard = true
				else
					bShowRecommend = tbBit[v.nGroupIndex] == 0
				end

				szTopTip = v.szNoromalDesc --首冲双倍时显示默认desc（双倍标签专门显示双倍），其他情况下显示 normal 配置
				if bShowRecommend then
					tbItem.pPanel:SetActive("Recommanded" .. i, true)
					if bDaysCard then
						tbItem.pPanel:SetActive("TagExtra" .. i, false)
					else
						szTopTip = v.szDesc
						tbItem.pPanel:SetActive("TagExtra" .. i, true)
						tbItem.pPanel:Label_SetText("lbExt" .. i, v.szFirstDesc)
					end

				else
					tbItem.pPanel:SetActive("Recommanded" .. i, false)
					if nLeftDay and nLeftDay > 0 then 
						tbItem.pPanel:SetActive("TagExtra" .. i, true)
						tbItem.pPanel:Label_SetText("lbExt" .. i, string.format("剩余%d天", nLeftDay) )
					else
						tbItem.pPanel:SetActive("TagExtra" .. i, false)
					end
				end

				tbItem.pPanel:Label_SetText("LabelNum" .. i, szTopTip )
				tbItem.pPanel:Sprite_SetSprite("Icon" ..i, v.szSprite)
				local tbMoneShowInfo = Recharge.tbMoneyName[v.szMoneyType]
				tbItem.pPanel:Label_SetText("LabelMoney" .. i, tbMoneShowInfo[2] )
				if version_vn then
					tbItem.pPanel:Label_SetText("lbPrice" .. i, Lib:ThousandSplit(v.nMoney * tbMoneShowInfo[4]) or tostring(v.nMoney * tbMoneShowInfo[4]))
				else
					tbItem.pPanel:Label_SetText("lbPrice" .. i, string.format(tbMoneShowInfo[3], v.nMoney * tbMoneShowInfo[4]))
				end
			end
		end
	end
	self.ScrollView:Update(tbGroups, fnSetItem)
end

function tbUi:ShowVip(nVipLevel)
	self.szCurPage = "Vip"
	self.pPanel:SetActive("RechargePage", false)
	self.pPanel:SetActive("ThaiTopup", false)
	self.pPanel:SetActive("VipPrivilege", true)
	self.pPanel:Button_SetSprite("BtnRecharge", "BtnRecharge", 0);

	local nMyVipLevel = me.GetVipLevel()
	local nMaxLevel = 6;
	if nMyVipLevel >= 6 then
		local nNowMaxVipLevel = nMyVipLevel
		for i = nMyVipLevel, #Recharge.tbVipSetting do
			local szTimeFrameNeed = Recharge.tbVipTimeFrameSetting[i]
			if szTimeFrameNeed and  GetTimeFrameState(szTimeFrameNeed) ~= 1 then
				break;
			end
			nNowMaxVipLevel = i;
		end

		nMaxLevel = math.min(nMyVipLevel + 3, nNowMaxVipLevel)
	else
		nMaxLevel = math.max(nMyVipLevel + 1, 6)
	end

	if nVipLevel then
		self.nVipLevel = nVipLevel
	end
	if not self.nVipLevel then
		self.nVipLevel = me.GetVipLevel();
	end

	local fnClickItem = function (itemObj, nVipLevel)
		nVipLevel = nVipLevel or itemObj.nIndex - 1;
		self.nVipLevel = nVipLevel;
		Ui:ClearRedPointNotify("VipAward" .. (nVipLevel))
		if not Ui:GetRedPointState("VipAward") then
			Client:SetFlag("ShowRedPoint", Lib:GetLocalDay())
		end

		self.pPanel:Label_SetText("VIPPrivilegeTitle", string.format("剑侠尊享%d 特权", nVipLevel))
		self.pPanel:Label_SetText("VIPPackageTitle", string.format("剑侠尊享%d 特权礼包", nVipLevel))
		local szDesc = Recharge:GetFilterVipDesc(nVipLevel)

		self.pPanel:Label_SetText("VipTxtDesc", szDesc);
		-- self.pPanel:Label_SetText("VipTxtDesc2", Recharge.tbVipDescFix[nVipLevel + 1])

		local tbTextSize = self.pPanel:Label_GetPrintSize("VipTxtDesc");
		local tbSize = self.pPanel:Widget_GetSize("datagroup");
		self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	    self.pPanel:DragScrollViewGoTop("datagroup");
	    self.pPanel:UpdateDragScrollView("datagroup");

	    self.pPanel:Label_SetText("VipLevelTxt", self.tbVipLevelDesc[nVipLevel] or "")
	    local szVip = Recharge.VIP_SHOW_LEVEL[nVipLevel]
	    self.pPanel:SetActive("VIP", szVip or false)
	    if szVip then
        	self.pPanel:Sprite_Animation("VIP", szVip)
    	end


		local tbVipAward = Recharge.tbVipAward[nVipLevel + 1]
		--特权礼包
		local nParamId = KItem.GetItemExtParam(tbVipAward.nGiveItemId, 1)
		local _, _, tbItems = Item:GetClass("RandomItem"):RandomItemAward(me, nParamId, "VipAward");
		for i=1,6 do
			local tbItem = tbItems[i]
			local tbGrid = self["itemframe" .. i]
			if tbItem then
				tbGrid.pPanel:SetActive("Main", true)

				tbGrid:SetGenericItem(tbItem)
				tbGrid.fnClick = tbGrid.DefaultClick
			else
				tbGrid.pPanel:SetActive("Main", false)
			end
		end

		local nBuyedVal = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD)
		local nBuydeBit = KLib.GetBit(nBuyedVal, nVipLevel + 1)

		self.pPanel:SetActive("BtnBuy", nBuydeBit ~= 1);
		self.pPanel:SetActive("TagBought", nBuydeBit == 1);

		-- local nMyVipLevel = me.GetVipLevel();
		self.pPanel:Label_SetText("lbOriginalPrice", tbVipAward.nShowPrice)
		self.pPanel:Label_SetText("lbNewPrice", tbVipAward.nRealPrice)
		self.pPanel:SetActive("NewPrice", true)
		self.pPanel:SetActive("OriginalPriceDis", true)
		self:ShowNextVipLvRecharge()
	end

	local fnSetLeftItem = function (itemObj, nIndex)
		itemObj.nIndex  = nIndex
		itemObj.pPanel:Label_SetText("VipLevelDark", string.format("剑侠尊享%d", nIndex - 1))
		itemObj.pPanel:Label_SetText("VipLevelLight", string.format("剑侠尊享%d", nIndex - 1))
		Ui.UnRegisterRedPoint("VipAward" .. (nIndex - 1))
		itemObj.pPanel:RegisterRedPoint("New", "VipAward" .. (nIndex - 1))

		itemObj.pPanel.OnTouchEvent = fnClickItem;
		itemObj.pPanel:Toggle_SetChecked("Main", nIndex - 1 == self.nVipLevel)
	end
	self.VipScrollView:Update(nMaxLevel + 1, fnSetLeftItem)
	fnClickItem({}, self.nVipLevel)



end

function tbUi:ShowNextVipLvRecharge()
	local nMyVipLevel = me.GetVipLevel()

	local nTotalCharge   = Recharge:GetTotoalRecharge(me)
	local szMoneyType    = Recharge.tbSettingGroup.BuyGold[1].szMoneyType
	local tbMoneShowInfo = Recharge.tbMoneyName[szMoneyType]
	local nNextLevel     = math.min(nMyVipLevel + 1, #Recharge.tbVipSetting)
	local nLastNeed      = Recharge.tbVipSetting[nMyVipLevel] or 0;
	local nLevelNeed     = Recharge.tbVipSetting[nNextLevel] - nLastNeed
	if nLevelNeed == 0 then
		nLastNeed  = 0
		nLevelNeed = Recharge.tbVipSetting[nNextLevel]
	end
	local nCurLevel = nTotalCharge - nLastNeed
	self.pPanel:ProgressBar_SetValue("VIPlevel", nCurLevel / nLevelNeed)
	self.pPanel:Label_SetText("LbProg", string.format("%s/%s", Recharge:GetMoneyPriceShow(nCurLevel), Recharge:GetMoneyPriceShow(nLevelNeed)) ); 
	
	local nMinus = nLevelNeed - nCurLevel
	if nMinus <= 0 then --满了
		self.pPanel:SetActive("NextVIPTip", false);
	else
		self.pPanel:SetActive("NextVIPTip", true);
		local szMoneyAmount = Recharge:GetMoneyPriceShow(nMinus) 
		if version_vn then
			szMoneyAmount = Lib:ThousandSplit(nMinus * tbMoneShowInfo[4])
		end	
		self.pPanel:Label_SetText("NextVIPTip", string.format("再充值[fefb1a]%s%s[-]，即可成为", tbMoneShowInfo[2], szMoneyAmount ))
		self.pPanel:Sprite_SetSprite("NextVIP", string.format("VIP%d", nNextLevel))
	end
	self.pPanel:Sprite_SetSprite("CurrentVIP", "VIP" .. nMyVipLevel)
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnRecharge = function (self)
	if self.szCurPage == "Vip" then
		self:ShowRecharge()
	else
		self:ShowVip()
	end
end

tbUi.tbOnClick.BtnLeft = function (self)
	self:ShowVip(self.nVipLevel - 1)
end

tbUi.tbOnClick.BtnBuy = function (self)
	if me.GetVipLevel() < self.nVipLevel then
		me.CenterMsg("您的剑侠尊享特权等级不足")
		return
	end
	RemoteServer.BuyVipAward(self.nVipLevel)
end

tbUi.tbOnClick.BtnRefresh = function (self)
	if Recharge:IsRechareGetted() then
		me.CenterMsg("刷新到账成功")
	else
		Sdk:UpdateBalanceInfo();
		me.CenterMsg("已请求刷新！")
	end
end

tbUi.tbOnClick.BtnHelp = function (self)
	if IOS then
		Sdk:OpenUrl("http://www.jxqy.org");
	else
		Sdk:OpenUrl("http://www.jxqy.org");
	end
end

tbUi.tbOnClick.BtnHelpRecharge  = function (self)
	if version_xm then
		Sdk:OpenUrl("http://www.jxqy.org");
	else
		local nVip = me.GetVipLevel()
		if nVip < 12 then
			Sdk:OpenUrl("http://www.jxqy.org");
		else
			Sdk:OpenUrl("http://www.jxqy.org");
		end
	end
end

if Sdk:IsEfunHKTW()then
	tbUi.tbOnClick.BtnMore = function (self)
		if Sdk:XGSurportThridPay() then
			Sdk:XGThirdPay();
		else
			me.CenterMsg("不支持第三方支付");
		end
	end
end

tbUi.tbOnClick.SerialTopup = function (self)
	Sdk:XGThirdPay("");
end

tbUi.tbOnClick.MoreTopup = function (self)
	Sdk:XGThirdPay("mall");
end