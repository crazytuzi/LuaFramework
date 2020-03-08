local tbUi      = Ui:CreateClass("ShowAward")
tbUi.ITEM_NUM   = 4
tbUi.POS_TIME   = 0.05
tbUi.SCALE_TIME = Env.GAME_FPS * 0.2
tbUi.ITEM_DELAY = Env.GAME_FPS * 0.6

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SWEEP_OVER, self.OnOpenEnd, self },
	};

	return tbRegEvent
end

function tbUi:OnOpenEnd(tbAllAward)
	self:OnGetAward(tbAllAward)
	if not self.tbAllAward or not next(self.tbAllAward) then
		self.pPanel:SetActive("ScrollView", false)
		self.pPanel:SetActive("Container", false)
		return
	end

	self.nGridPosY    = self.nGridPosY or self.pPanel:GetPosition("PosTransform").y
	self.nItemHeight  = self.nItemHeight or self.GainttipsItem.pPanel:Sprite_GetSize("Main").y
	self.nStartPosY   = self.nStartPosY or self.GainttipsItem.pPanel:GetPosition("Main").y
	self.nSVStartPosY = self.nSVStartPosY or self.pPanel:GetPosition("ScrollView").y

	self:InitScrollView()
	self:AdjustScrollView()
	self:UpdateDesc()
	self.bOver = false
end

function tbUi:InitScrollView()
	self.pPanel:SetActive("ScrollView", true)
	self.pPanel:ChangePosition("PosTransform", 0, self.nGridPosY)
	self.pPanel:ChangePanelOffset("ScrollView", 0, 0)
	self.pPanel:ChangePosition("ScrollView", 0, self.nSVStartPosY)

	local nAwardNum = #self.tbAllAward
	for nIdx = 1, nAwardNum do
		local tbItem = self["GainttipsItem" .. nIdx];
		if not tbItem then
			self.pPanel:CreateWnd("GainttipsItem", "GainttipsItem" .. nIdx);
			tbItem = self["GainttipsItem" .. nIdx];
		end

		local tbAward = self.tbAllAward[nIdx]
		for i = 1, 6 do
			local tbInfo = tbAward[i]
			if tbInfo then
				tbItem["item" .. i]:SetGenericItem(tbInfo)
				tbItem["item" .. i].fnClick = tbItem["item" .. i].DefaultClick
			end
			tbItem.pPanel:SetActive("item" .. i, false)
		end
		tbItem.pPanel:Label_SetText("Times", string.format("第 %d 次", nIdx))
		tbItem.pPanel:SetActive("Main", false)

		local nPos = self.nStartPosY - self.nItemHeight*(nIdx-1)
		tbItem.pPanel:ChangePosition("Main", 0, nPos)
		tbItem.pPanel:SetBoxColliderEnable("Drag", false)
	end

	for nIdx = nAwardNum + 1, 100 do
		if self["GainttipsItem" .. nIdx] then
			self["GainttipsItem" .. nIdx].pPanel:SetActive("Main", false)
		else
			break
		end
	end

	self:BeginNextItemAni()
end

function tbUi:BeginNextItemAni(nSVItemIdx)
	nSVItemIdx = nSVItemIdx or 1
	local nAwardNum = #self.tbAllAward
	if nSVItemIdx > nAwardNum then
		for nIdx = 1, nAwardNum do
			self["GainttipsItem" .. nIdx].pPanel:SetBoxColliderEnable("Drag", true)
		end
		self:AdjustScrollView()
		self.bOver = true
		return
	end

	local tbItem  = self["GainttipsItem" .. nSVItemIdx]
	tbItem.pPanel:SetActive("Main", true)
	if nSVItemIdx > self.ITEM_NUM then
		self:BeginScrollViewAni(nSVItemIdx)
	end
	self:BeginItemAni(nSVItemIdx)
end

function tbUi:BeginScrollViewAni(nIdx)
	local vecTSPos = self.pPanel:GetPosition("PosTransform")
	self.pPanel:Tween_Run("PosTransform", vecTSPos.x, self.nGridPosY + self.nItemHeight*(nIdx-self.ITEM_NUM), self.POS_TIME)
end

function tbUi:BeginItemAni(nSVItemIdx, nItemIdx)
	nItemIdx = nItemIdx or 1
	self.nItemTimer = nil

	local tbAward = self.tbAllAward[nSVItemIdx]
	local tbInfo  = tbAward[nItemIdx]
	if not tbInfo then
		Timer:Register(self.ITEM_DELAY, self.BeginNextItemAni, self, nSVItemIdx + 1)
		return
	end

	local tbItem = self["GainttipsItem" .. nSVItemIdx]
	tbItem.pPanel:SetActive("item" .. nItemIdx, true)
	tbItem.pPanel:Tween_Play("item" .. nItemIdx)

	self.nItemTimer = Timer:Register(self.SCALE_TIME, self.BeginItemAni, self, nSVItemIdx, nItemIdx + 1)
end

function tbUi:AdjustScrollView()
	local vecTSPos  = self.pPanel:GetPosition("PosTransform");
	local nBoundMin = self.nStartPosY + (self.nItemHeight / 2) + vecTSPos.y;
	local nBoundMax = nBoundMin - (self.nItemHeight * #self.tbAllAward);
	self.pPanel:ResizeScrollViewBound("ScrollView", nBoundMin, nBoundMax);
end

function tbUi:OnClose()
	if self.nItemTimer then
		Timer:Close(self.nItemTimer)
		self.nItemTimer = nil
	end
end

function tbUi:GetGainDesc()
	local nTemplateId, nNeedNum = Compose:GetCurItem()
	if not nTemplateId then
		return false
	end

	local szDesc     = "本次共获得[FFFE0D]「%s * %d」[-]，当前进度：[FFFE0D]%d/%d[-]"
	local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
	local nHaveNum   = me.GetItemCountInAllPos(nTemplateId) or 0
	szDesc = string.format(szDesc, tbBaseInfo.szName, self.nGetNum or 0, nHaveNum, nNeedNum)
	return true, szDesc
end

function tbUi:UpdateDesc(nCount)
	nCount = math.min(nCount or 1, 4)
	local bShow, szDesc = self:GetGainDesc()
	self.pPanel:SetActive("Container", bShow)
	self.pPanel:Label_SetText("Gain_Label", szDesc or "")
end

function tbUi:OnGetAward(tbAllAward)
	self.nGetNum = 0
	self.tbAllAward = {}
	local nCurTemplateId = Compose:GetCurItem()
	for _, tbAward in ipairs(tbAllAward or {}) do
		local tbResult = {};

		local tbBeforeSort = {}
		for _, tbInfo in pairs(tbAward) do
			local nInsertIdx = 5
			local szKey      = tbInfo[1]
			if szKey == "Exp" or szKey == "BasicExp" then
				nInsertIdx = 1
			elseif szKey == "Item" or szKey == "item" then
				local nTemplateId = tbInfo[2]
				local tbBaseInfo  = KItem.GetItemBaseProp(nTemplateId)
				if Compose:IsForPartnerEquip(tbBaseInfo.szClass) then
					nInsertIdx = 2
					self.nGetNum = (nCurTemplateId == nTemplateId) and (self.nGetNum + 1) or self.nGetNum
				elseif nTemplateId == 601 or nTemplateId == 1016 or nTemplateId == 1342 then --经验药水
					nInsertIdx = 4
				end
			elseif szKey == "Coin" or szKey == "Gold" then
				nInsertIdx = 3
			end

			tbBeforeSort[nInsertIdx] = tbBeforeSort[nInsertIdx] or {}
			table.insert(tbBeforeSort[nInsertIdx], tbInfo)
		end

		for i = 1, 5 do
			for _, tbInfoAward in pairs(tbBeforeSort[i] or {}) do
				table.insert(tbResult, tbInfoAward)
			end
		end
		table.insert(self.tbAllAward, tbResult);
	end
end

function tbUi:OnScreenClick()
	if self.bOver then
		Ui:CloseWindow(self.UI_NAME)
	end
	self.bOver = false
end