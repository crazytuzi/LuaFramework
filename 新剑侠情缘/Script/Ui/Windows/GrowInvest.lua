local tbUi = Ui:CreateClass("GrowInvest");
local tbGrid = Ui:CreateClass("GrowInvestGrid")

tbGrid.tbOnClick = {}
tbGrid.tbOnClick.BtnTake = function (self)
	if self.tbData.bCanTake then
		RemoteServer.TakeGrowInvestAward(self.tbData.nIndex, self.parent.nGroupIndex)
	end
end

tbUi.tbGroupIdx = tbUi.tbGroupIdx or {}
function tbUi:OnOpen(nGroupIndex)
	local tbGroupIdx = {}
	local tbRPActive = {}
	if nGroupIndex and not Recharge:_IsShowGrowInvest(nGroupIndex) then
		nGroupIndex = nil
	end
	local tbSpecial = {
		[4] = "IsShowGrowInvestAct",
		[7] = "IsShowGrowInvestBack",
	}
	for nIdx, szFunc in pairs(tbSpecial) do
		local bShow = Recharge[szFunc](Recharge)
		if bShow then
			table.insert(tbGroupIdx, nIdx)
			self.nGroupIndex = (nGroupIndex == nIdx) and nGroupIndex or self.nGroupIndex
			if Recharge:_IsRedPointInvestActive(nIdx) then
				table.insert(tbRPActive, nIdx)
			end
		end
	end
	local _, nIdx = Recharge:IsRedPointInvestActive()
	if nIdx and not tbSpecial[nIdx] then
		table.insert(tbGroupIdx, 1, nIdx)
		self.nGroupIndex = self.nGroupIndex or nIdx
	else
		local nNormalGroupIndex = Recharge:GetAutoShowGrowInvest() --不包括活动的4,7
		table.insert(tbGroupIdx, 1, nNormalGroupIndex)
		self.nGroupIndex = (nNormalGroupIndex == nGroupIndex) and nNormalGroupIndex or self.nGroupIndex
	end
	if not self.nGroupIndex then
		--优先显示亮红点的，没有则显示最后一个
		local tbTmp = #tbRPActive > 0 and tbRPActive or tbGroupIdx
		self.nGroupIndex = tbTmp[#tbTmp]
	end

	local nShowTabCount = #tbGroupIdx
	local tbBtnTxt = {[4] = Recharge.tbGrowInvestActSetting.szNameInPanel, [7] = "回归专属"}
	if nShowTabCount > 1 then
		self.pPanel:SetActive("Tab", true)
		for i = 1, 3 do
		 	self.pPanel:SetActive("Btn" .. i, tbGroupIdx[i] or false)
		 	if tbGroupIdx[i] then
		 		local szBtnTxt = tbBtnTxt[tbGroupIdx[i]] or "一本万利"
		 		self.pPanel:Label_SetText("LabelLight" .. i, szBtnTxt)
				self.pPanel:Label_SetText("LabelDark" .. i, szBtnTxt)
				if tbGroupIdx[i] == self.nGroupIndex then
					self.pPanel:Toggle_SetChecked("Btn" .. i, true)
				end
		 	end
		end
	else
		self.pPanel:SetActive("Tab", false)
	end
	
	self:Update()
	self.tbGroupIdx = tbGroupIdx
end

function tbUi:OnClose()
	self.nGroupIndex = nil;
end

function tbUi:Update()
	local nGroupIndex = self.nGroupIndex
	if nGroupIndex >= 2 then
		Client:SetFlag("hasViewRechargeInvest" .. nGroupIndex, true)
		Recharge:CheckRedPoint();	
	end
	if nGroupIndex == 4 then
		self.pPanel:Texture_SetTexture("Container", Recharge.tbGrowInvestActSetting.szTextureInPanel)
		--活动结束后还是可能能领取的, 结束后不能获取到活动的时间所以这里写死日期
		self.pPanel:Label_SetText("Tip",  Recharge.tbGrowInvestActSetting.szBuyTimeLimit )
		self.pPanel:SetActive("Tip", true)
		self.pPanel:Label_SetText("GrowInvestTxt", "＊无领取期限，4点以后登录即可领元宝");
		self.pPanel:SetActive("GrowInvestTxt", true)
	else
		self.pPanel:Texture_SetTexture("Container", "UI/Textures/GrowInvest.png")
		self.pPanel:SetActive("Tip", false)
		self.pPanel:SetActive("GrowInvestTxt", false)
	end

	local tbBuyInfo = Recharge.tbSettingGroup.GrowInvest[nGroupIndex]

	local nBuyed = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex])
	local bBuyed = nBuyed ~= 0
	self.pPanel:SetActive("BtnBuy", not bBuyed)
	self.pPanel:SetActive("HasBuyed", bBuyed)

	local nCanGet = 0
	for i,v in ipairs(Recharge.tbGrowInvestGroup[nGroupIndex]) do
		nCanGet = nCanGet + v.nAwardGold
	end
	self.pPanel:Label_SetText("Txt1", string.format("购买%s", tbBuyInfo.szNoromalDesc))
	local nOrgGetGold = Recharge:GetRechareMoneyToGold(tbBuyInfo.nMoney, tbBuyInfo.szMoneyType, true)
	local nBei = math.ceil(nCanGet / nOrgGetGold - 0.5)
	self.pPanel:Label_SetText("Txt2", string.format("超值%d倍返还%d元宝", nBei, nCanGet))

	local tbAllSetting = {}

	if not bBuyed then
		tbAllSetting = Recharge.tbGrowInvestGroup[nGroupIndex]
	else
		local tbTakedList = {}
		local nTaked = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowTaked[nGroupIndex])
		local nToday = Recharge:GetRefreshDay()
		local nNowCanTakeIndex = Recharge:GetActGrowInvestTakeDay(me, nGroupIndex)
		for i,v in ipairs(Recharge.tbGrowInvestGroup[nGroupIndex]) do
			v = Lib:CopyTB1(v)
			v.nIndex = i;

			if KLib.GetBit(nTaked, i) == 1 then
				v.bTaked = true
				table.insert(tbTakedList, v)
			else
				if me.nLevel >= v.nLevel then
					if v.nDay then
						if i == nNowCanTakeIndex then
							v.bCanTake = true		
						end
					else
						v.bCanTake = true	
					end
					
				end
				table.insert(tbAllSetting, v)
			end
		end

		for i,v in ipairs(tbTakedList) do
			table.insert(tbAllSetting, v)
		end
	end

	local szGold, szGoldAtals = Shop:GetMoneyIcon("Gold")
	local fnSetItem = function (tbItem, index)
		local tbData = tbAllSetting[index]
		tbItem.tbData = tbData
		tbItem.parent = self;
		local szDesc
		if tbData.nDay then
			szDesc = tbData.nLevel == Recharge.tbGrowInvestGroup[nGroupIndex][1].nLevel  and "立即获得" or string.format("第 [FFFE0D]%d[-] 天", tbData.nDay)
		else
			szDesc = tbData.nLevel == Recharge.tbGrowInvestGroup[nGroupIndex][1].nLevel  and "立即获得" or string.format("等级达到%d级", tbData.nLevel)
		end
		 
		tbItem.pPanel:Label_SetText("lbDesc", szDesc)
		tbItem.pPanel:Label_SetText("lbGoldNum", tbData.nAwardGold)
		tbItem.pPanel:Sprite_SetSprite("SpGold", szGold, szGoldAtals)

		if tbData.bTaked then
			tbItem.pPanel:SetActive("BtnTake", false)
			tbItem.pPanel:SetActive("HasTaked", true)
		else
			tbItem.pPanel:SetActive("BtnTake", true)
			if not tbData.bCanTake and tbData.nLevel == 0 then
				tbItem.pPanel:SetActive("BtnTake", false)
			end
			tbItem.pPanel:SetActive("HasTaked", false)
			tbItem.pPanel:Button_SetEnabled("BtnTake", tbData.bCanTake or false)
		end
	end

	self.ScrollView:Update(tbAllSetting, fnSetItem)
end

function tbUi:UpdateGroupIdx(nBtnIdx)
	local nIdx = self.tbGroupIdx[nBtnIdx]
	if not nIdx then
		return
	end
	self.nGroupIndex = nIdx
	self:Update()
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnBuy = function (self)
	Recharge:RequestBuyGrowInvest(self.nGroupIndex)
end

for i = 1, 3 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self:UpdateGroupIdx(i)
	end
end