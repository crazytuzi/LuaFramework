local tbUi = Ui:CreateClass("KinVaultPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
		{UiNotify.emNOTIFY_CHANGE_MONEY, self.RefreshMoney, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	if not Kin:HasKin() then
		me.CenterMsg("当前没有家族，请先加入一个家族");
		Ui:OpenWindow("KinJoinPanel");
		return 0;
	end

	Kin:UpdateBaseInfo()
	Kin:UpdateDonationRecord();

	if Kin:GetBuildingLevel(Kin.Def.Building_Treasure) <= 0 then
		Kin:UpdateBuildingData();
		return;
	end

	self:UpdateDonation();
	self:UpdateRecord();
	self:UpdateGiftBox();
	self:UpdateVipPrivilegeDesc()
	self:RefreshMoney()
end

function tbUi:UpdateData(szType)
	if szType == "DonationRecord" then
		self:UpdateRecord();
		self:UpdateDonation();
	elseif szType == "GiftBox" or szType == "Building" then
		self:UpdateGiftBox();
	end
end

function tbUi:UpdateDonation()
	local nLeftDonateCount, nDonationTotalCount = Kin:GetDonationData();
	local nCurDonateCount = nDonationTotalCount - nLeftDonateCount;

	self.pPanel:Label_SetText("TxtDontaonCount", string.format("%d/%d", nLeftDonateCount, nDonationTotalCount));

	self.nDonateCost = Kin:GetDonationsCost(me.GetVipLevel(), nCurDonateCount + 1, nCurDonateCount + 1);
	self.pPanel:Label_SetText("TxtDonetionCost", self.nDonateCost);
	local nContribut = Kin.Def.nDonate2ContribPerTime
	local fVipInc = Kin:GetVipDonateContributeInc(me.GetVipLevel())
	nContribut = math.ceil(nContribut*(1+fVipInc))
	self.DonationRewardItem:SetDigitalItem("Contrib", nContribut);

	self.DonationRewardItem.fnClick = self.DonationRewardItem.DefaultClick;
	self.pPanel:Button_SetEnabled("BtnDonate", nLeftDonateCount > 0);
end

function tbUi:RefreshMoney()
	self.pPanel:Label_SetText("ContributionNumber", me.GetMoney("Contrib"))
end

function tbUi:UpdateGiftBox()
	local nNow = GetTime();
	local nLeftCount, nNextBuyTime = Kin:GetGiftBoxData();
	nLeftCount = nLeftCount or 0;
	nNextBuyTime = nNextBuyTime or nNow;

	self.pPanel:Label_SetText("TxtGiftBoxCost", Kin.Def.nGiftBoxCost);
	self.pPanel:Label_SetText("TxtGiftBoxLeftCount", string.format("%d/%d", nLeftCount, Kin:GetGiftMaxCount(me.GetVipLevel())));
	self.pPanel:Button_SetEnabled("BtnBuyGiftBox", nLeftCount > 0 and nNow > nNextBuyTime);

	local nTreaserBuildingLevel = Kin:GetBuildingLevel(Kin.Def.Building_Treasure);
	local nPriceItemId = assert(Kin.Def.GiftBoxItemIdByLevel[nTreaserBuildingLevel]);
	self.GiftBoxRewardItem:SetItemByTemplate(nPriceItemId, 1);
	self.GiftBoxRewardItem.fnClick = self.GiftBoxRewardItem.DefaultClick;

	if self.nGiftBoxCountDownTimer then
		Timer:Close(self.nGiftBoxCountDownTimer);
		self.nGiftBoxCountDownTimer = nil;
	end

	self.pPanel:Label_SetText("TxtCountDownTime", "");
	if nLeftCount <= 0 or nNow >= nNextBuyTime then
		return;
	end

	self.nGiftBoxCountDownTimer = Timer:Register(Env.GAME_FPS, function ()
		local nLeftTime = nNextBuyTime - GetTime();
		if nLeftTime < 0 then
			self.nGiftBoxCountDownTimer = nil;
			self.pPanel:Label_SetText("TxtCountDownTime", "");
			self.pPanel:Button_SetEnabled("BtnBuyGiftBox", nLeftCount > 0);
			return false;
		end

		local szLeftTime = Lib:TimeDesc3(nLeftTime);
		self.pPanel:Label_SetText("TxtCountDownTime", szLeftTime);
		return true;
	end);
end

function tbUi:UpdateRecord()
	local tbDonationRecord = Kin:GetDonationRecord() or {};

	local fnSetItem = function (itemObj, nIdx)
		local tbItemData = tbDonationRecord[nIdx];
		local szName, nFoundAdd, nCount = unpack(tbItemData)
		if not nCount then
			nCount = 1
		end
		local szRecord = string.format("[FFFE0D]%s[-][92D2FF]捐献了%d次，建设资金增加了%d[-]", szName, nCount, nFoundAdd);
		itemObj.pPanel:Label_SetText("Main", szRecord);
	end
	self.RecordScrollView:Update(#tbDonationRecord, fnSetItem);
end

function tbUi:UpdateVipPrivilegeDesc()
	local szDesc = Recharge:GetVipPrivilegeDesc("KinDonate") or ""
	self.pPanel:Label_SetText("Tip01", szDesc)
	szDesc = Recharge:GetVipPrivilegeDesc("KinGift") or ""
	self.pPanel:Label_SetText("Tip02", szDesc)
end

function tbUi:OnClose()
	if self.nGiftBoxCountDownTimer then
		Timer:Close(self.nGiftBoxCountDownTimer);
		self.nGiftBoxCountDownTimer = nil;
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnDonate()
	Ui:OpenWindow("VaultDonationPanel")
end

function tbUi.tbOnClick:BtnBuyGiftBox()
	Kin:BuyGiftBox();
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

---------------

local tbVaultDonationPanel = Ui:CreateClass("VaultDonationPanel")
function tbVaultDonationPanel:OnOpen()
	self.nMaxCount = Kin:GetDonationData()
	self.pPanel:Label_SetText("Desc", string.format("剩余次数：%d", self.nMaxCount))

	self.nMaxGoldDonateCount = self:GetMaxDonateCount(self.nMaxCount)
	local nCount = self:LoadCount()
	self:SetCurCount(math.min(nCount, self.nMaxGoldDonateCount))

	self:UpdateSetting()
end

function tbVaultDonationPanel:UpdateSetting()
	local nVip = me.GetVipLevel()
	local tbSetting = Kin:GetDonateVipSetting(nVip)
	local tbEntries = {}
	local nIdx = 0
	local nLeftDonateCount, nDonationTotalCount = Kin:GetDonationData()
	local nCurDonateCount = nDonationTotalCount - nLeftDonateCount
	for _, tb in ipairs(tbSetting) do
		local nMax, nGold = unpack(tb)
		table.insert(tbEntries, {
			string.format("%d~%d", nIdx + 1, nMax),
			nGold,
			nCurDonateCount >= nMax,
		})
		nIdx = nMax
	end

	self.ScrollViewVoteItem:Update(#tbEntries, function(itemObj, nIdx)
		local szCount, nGold, bOver = unpack(tbEntries[nIdx])
		itemObj.pPanel:Label_SetText("Frequency", szCount)
		itemObj.pPanel:Label_SetText("Price", nGold)
		itemObj.pPanel:SetActive("RedThread", bOver)
	end)
end

local szSaveKey = "KinDonationCount"
function tbVaultDonationPanel:LoadCount()
	local nCount = tonumber(Client:GetFlag(szSaveKey) or 0)
	if not nCount or nCount<=0 then
		nCount = 1
	end
	return nCount
end

function tbVaultDonationPanel:SaveCount()
	local nCount = self:GetCurCount()
	Client:SetFlag(szSaveKey, nCount)
end

function tbVaultDonationPanel:UpdateNumberInput(nInput)
	local nRet = nInput
	if nInput>self.nMaxGoldDonateCount then
		nRet = self.nMaxGoldDonateCount
	end

	self:SetCurCount(nRet)
	return nRet
end

function tbVaultDonationPanel:GetCurCount()
	return tonumber(self.pPanel:Label_GetText("Number"))
end

function tbVaultDonationPanel:SetCurCount(count)
	self.pPanel:Label_SetText("Number", count)
	self:UpdateInfo()
end

function tbVaultDonationPanel:GetMaxDonateCount(nMaxCount)
	local nLeftDonateCount, nDonationTotalCount = Kin:GetDonationData()
	local nCurDonateCount = nDonationTotalCount - nLeftDonateCount

	local tbFirstSetting = Kin:GetDonateSetting(me.GetVipLevel(), nCurDonateCount+1)
	local nHaveGold = me.GetMoney("Gold")
	if nHaveGold<tbFirstSetting.nPrice then
		return 0
	end

	local nMaxSetting = Kin.tbDonateSetting[#Kin.tbDonateSetting].nMax
	local function fnSearch(nBegin, nEnd)
		if nEnd<=0 then
			return 0
		end
		if nBegin>=nEnd then
			return nEnd
		end
		if nBegin>=nMaxSetting then
			return nMaxSetting
		end
		local nMid = math.floor((nEnd-nBegin)/2 + nBegin)
		local tbSetting = Kin:GetDonateSetting(me.GetVipLevel(), nMid)
		local nTotalCost = tbSetting.nTotalPrice-tbFirstSetting.nTotalPrice+tbFirstSetting.nPrice
		if nHaveGold>nTotalCost then
			local tbNextSetting = Kin:GetDonateSetting(me.GetVipLevel(), nMid+1)
			local nNextTotalCost = nTotalCost+tbNextSetting.nPrice
			if nHaveGold<nNextTotalCost then
				return nMid
			end
			return fnSearch(nMid+1, nEnd)
		elseif nHaveGold<nTotalCost then
			local nPrevTotalCost = nTotalCost-tbSetting.nPrice
			if nHaveGold>=nPrevTotalCost then
				return nMid-1
			end
			return fnSearch(nBegin, nMid-1)
		else
			return nMid
		end
	end

	local nMaxIdx = fnSearch(nCurDonateCount+1, nCurDonateCount+nMaxCount)
	local nMaxDonate = nMaxIdx-nCurDonateCount
	return nMaxDonate
end

function tbVaultDonationPanel:GetCostGainInfo(nCount)
	if nCount<=0 then
		return true, 0, 0
	end

	local nLeftDonateCount, nDonationTotalCount = Kin:GetDonationData()
	local nCurDonateCount = nDonationTotalCount - nLeftDonateCount

	local nTotalCost = Kin:GetDonationsCost(me.GetVipLevel(), nCurDonateCount+1, nCurDonateCount+nCount)
	local nTotalGet = nCount*Kin.Def.nDonate2ContribPerTime

	local fVipInc = Kin:GetVipDonateContributeInc(me.GetVipLevel())
	nTotalGet = math.ceil(nTotalGet*(1+fVipInc))

	local bEnoughGold = me.GetMoney("Gold")>=nTotalCost

	return bEnoughGold, nTotalCost, nTotalGet
end

function tbVaultDonationPanel:UpdateInfo()
	local nCount = self:GetCurCount()

	local _, nTotalCost, nTotalGet = self:GetCostGainInfo(nCount)
	self.pPanel:Label_SetText("Cost", nTotalCost)
	self.pPanel:Label_SetText("Get", nTotalGet)
end

tbVaultDonationPanel.tbOnClick = tbVaultDonationPanel.tbOnClick or {}
function tbVaultDonationPanel.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbVaultDonationPanel.tbOnClick:BtnCancel()
	Ui:CloseWindow(self.UI_NAME)
end

function tbVaultDonationPanel.tbOnClick:BtnSure()
	local nCount = self:GetCurCount()
	if nCount<=0 then
		me.CenterMsg("请选择捐献次数")
		return
	end

	self:SaveCount()

	local nEnough = self:GetCostGainInfo(nCount)
	if not nEnough then
		me.CenterMsg("元宝不足")
		return
	end

	Kin:Donate(nCount)
	Ui:CloseWindow(self.UI_NAME)
end

function tbVaultDonationPanel.tbOnClick:BtnP()
	local count = self:GetCurCount()
	if count<=1 then
		me.CenterMsg("不能再少了")
		return
	end
	self:SetCurCount(count-1)
end

function tbVaultDonationPanel.tbOnClick:BtnA()
	local count = self:GetCurCount()
	if count>=self.nMaxGoldDonateCount then
		me.CenterMsg("不能再多了")
		return
	end
	self:SetCurCount(count+1)
end

function tbVaultDonationPanel.tbOnClick:Number()
	local function fnUpdate(nInput)
        local nResult = self:UpdateNumberInput(nInput)
        return nResult
    end 
    Ui:OpenWindow("NumberKeyboard", fnUpdate)
end