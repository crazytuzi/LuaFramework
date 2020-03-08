local tbUi = Ui:CreateClass("MagicBowlSelectMaterialPanel")
tbUi.nDelayCountTime = 1 
tbUi.nCountAddInterval = 3 

tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		if self.szSelectErr and self.szSelectErr~="" then
			me.CenterMsg(self.szSelectErr)
			return
		end
		if not next(self.tbChoosen or {}) then
			me.CenterMsg("请选择材料")
			return
		end
		local bOk, szErr = Furniture.MagicBowl:CheckMaterials(self.tbChoosen or {}, self.nCachedValue)
		if not bOk then
			me.CenterMsg(szErr)
			return
		end
		if self.bInscription then
			House:MagicBowlInsStartStage(self.tbChoosen)
		else
			House:MagicBowlUpgrade(self.nFurnitureId, self.tbChoosen)
		end
	end,
}

function tbUi:Refresh()
	self.szSelectErr = nil

	local tbData = House:GetMagicBowlData(me.dwID)
	if not tbData then
		return
	end

	self.nCachedValue = tbData.nCachedValue or 0
	if self.bInscription then
		self.nCachedValue = tbData.tbInscription.nCachedValue or 0
	end

	local bOk, szErr = self:InitNeedValue()
	if not bOk then
		me.CenterMsg(szErr or "数据错误")
	end

	self:InitItemData()
	self:RefreshItems()

	local szTxt = "锻造需要投入："
	if not self.bInscription then
		local nCurLvl = tbData.nLevel
		local tbNextLvl = Furniture.MagicBowl:GetLevelSetting(nCurLvl+1)
		if tbNextLvl then
			szTxt = string.format("升至%d级，需要家园舒适度达到%d级，同时投入材料：", nCurLvl+1, tbNextLvl.nComfortLvl)
		else
			szTxt = "已达到最大等级"
			self.szSelectErr = szTxt
		end

		if not self.szSelectErr then
			while true do
				local nComfortValue = House:GetComfortableShowInfo()
				local nComfortLvl = House:CalcuComfortLevel(nComfortValue) or 0
				if nComfortLvl<tbNextLvl.nComfortLvl then
					self.szSelectErr = "舒适度等级不足"
					break
				end

				if tbNextLvl.szOpenFrame~="" and GetTimeFrameState(tbNextLvl.szOpenFrame)~=1 then
					self.szSelectErr = "此等级尚未开启"
					break
				end

				local nStage = tbData.tbInscription.nStage
				if nStage~=0 then
					self.szSelectErr = "正在铸造铭文，无法升级"
					break
				end

				break
			end
		end
	end

	self.pPanel:Label_SetText("InscriptionTxt", szTxt)
	local tbSetting = self.bInscription and Furniture.MagicBowl:GetInscriptionMakeSetting(tbData.nLevel) or Furniture.MagicBowl:GetLevelSetting(tbData.nLevel)
	self.Item:SetItemByTemplate(tbSetting.nItemId, 1)
	self.Item.fnClick = self.Item.DefaultClick

	self:RefreshProgressBar()
end

function tbUi:OnOpen(bInscription, nFurnitureId)
	self.bInscription = bInscription
	self.nFurnitureId = nFurnitureId
	self:Refresh()
end

function tbUi:OnClose( )
	self:CloseCountTimer()
end

function tbUi:CloseCountTimer( )
	if self.nStartCountTimer then
		Timer:Close(self.nStartCountTimer)
		self.nStartCountTimer = nil
	end
	if self.nDelayCountTimer then
		Timer:Close(self.nDelayCountTimer)
		self.nDelayCountTimer = nil;
	end
end

function tbUi:InitNeedValue()
	self.nNeedValue = math.huge
	local tbMagicBowl = House:GetMagicBowlData(me.dwID)
	local nMBLvl = tbMagicBowl.nLevel
	if self.bInscription then
		local nStage = tbMagicBowl.tbInscription.nStage
		local nDeadline = tbMagicBowl.tbInscription.nDeadline
		if nStage<=0 then
			nStage, nDeadline = 1, 0
		end
		local szState = Furniture.MagicBowl:GetInscriptionState(nMBLvl, nStage, nDeadline)
		if szState~="rest" then
			return false, "当前状态无法开启阶段铸造"
		end

		local tbSetting = Furniture.MagicBowl:GetInscriptionMakeSetting(nMBLvl)
		if not tbSetting then
			Log("[x] MagicBowl:InscriptionStartStage, no setting", nPlayerId, nMBLvl)
			return false
		end

		local nRealStage = nStage
		if nDeadline>0 then
			nRealStage = nStage+1
		end
		self.nNeedValue = tbSetting["nValue"..nRealStage]
	else
		local tbNextLvl = Furniture.MagicBowl:GetLevelSetting(nMBLvl+1)
		if not tbNextLvl then
			return false, "已达最大等级"
		end
		self.nNeedValue = tbNextLvl.nCostValue
	end
	return true
end

function tbUi:InitItemData()
	local tbValidItems = {}
	for nItemId in pairs(Furniture.MagicBowl.tbMaterials) do
		local tbItems = me.FindItemInBag(nItemId)
		if tbItems and #tbItems>0 then
			for _,pItem in ipairs(tbItems) do
				table.insert(tbValidItems, {
					nTemplateId = nItemId,
					nItemId = pItem.dwId,
					nCount = pItem.nCount,
					nValue = Furniture.MagicBowl:GetMaterialValue(pItem),
				})
			end
		end
	end
	table.sort(tbValidItems, function(tbA, tbB)
		return tbA.nValue < tbB.nValue or (tbA.nValue == tbB.nValue and tbA.nTemplateId < tbB.nTemplateId) or
			(tbA.nValue == tbB.nValue and tbA.nTemplateId == tbB.nTemplateId and tbA.nItemId < tbB.nItemId)
	end)
	self.tbValidItems = tbValidItems
	self.tbChoosen = {}
end

				
function tbUi:StartCountTimer(itemObj)
	self.nDelayCountTimer = nil
	local nOrgAdd = 1
	self.nStartCountTimer = Timer:Register(self.nCountAddInterval, function () 
		nOrgAdd = nOrgAdd * 1.1 
		local bRet = self:UpdateAddItemCount(itemObj, math.floor(nOrgAdd) )
		if not bRet then
			self.nStartCountTimer = nil
			return false
		end
		return true
	end)
end

function tbUi:TryStartCountTimer(itemObj)
	self.nDelayCountTimer = Timer:Register(Env.GAME_FPS * self.nDelayCountTime, self.StartCountTimer, self, itemObj)
end

function tbUi:UpdateAddItemCount( itemObj, nAddCount)
	local nRealIdx = itemObj.nRealIdx
	local tbInfo = self.tbValidItems[nRealIdx]
	local _, _, nTotalValue = Furniture.MagicBowl:CheckMaterials(self.tbChoosen or {}, self.nCachedValue)
	if nTotalValue>=self.nNeedValue then
		me.CenterMsg("材料已足够")
		return false
	end
	
	local nMaxAdd = 0;
	local nItemId = itemObj.nItemId
	local pItem = KItem.GetItemObj(nItemId)
	if pItem then
		nMaxAdd = math.ceil((self.nNeedValue - nTotalValue) / (Furniture.MagicBowl:GetMaterialValue(pItem))) 
		nAddCount = math.min(math.min(nMaxAdd, nAddCount), pItem.nCount - (self.tbChoosen[nItemId] or 0)) 
	end
	 
	self.tbChoosen[nItemId] = (self.tbChoosen[nItemId] or 0)+ nAddCount
	itemObj.pPanel:Label_SetText("LabelSuffix", string.format("%d/%d", self.tbChoosen[nItemId], tbInfo.nCount))
	itemObj.MinusSign.pPanel:SetActive("Main", true)
	itemObj.pPanel:SetActive("Select", true)
	self:RefreshProgressBar()
	return true
end

function tbUi:RefreshItems()
	local nTotalItems = #self.tbValidItems
	local nRows = math.ceil(nTotalItems/7)
	self:CloseCountTimer()
	self.ScrollView:Update(nRows, function(pGrid, nIdx)
		for i=1,7 do
			local pItem = pGrid["item"..i]
			local nRealIdx = (nIdx-1)*7+i
			pItem.nRealIdx = nRealIdx
			local bValid = nRealIdx<=nTotalItems
			pItem.pPanel:SetActive("Main", bValid)
			if bValid then
				local tbInfo = self.tbValidItems[nRealIdx]
				local nItemId = tbInfo.nItemId
				pItem.pPanel:SetActive("LabelSuffix", true)

				pItem.MinusSign.pPanel.OnTouchEvent = function()
					if not self.tbChoosen[nItemId] then
						return
					end
					self.tbChoosen[nItemId] = self.tbChoosen[nItemId]-1
					if self.tbChoosen[nItemId]<=0 then
						self.tbChoosen[nItemId] = nil
					end
					pItem.pPanel:Label_SetText("LabelSuffix", self.tbChoosen[nItemId] and string.format("%d/%d", self.tbChoosen[nItemId], tbInfo.nCount) or tbInfo.nCount)
					if not self.tbChoosen[nItemId] then
						pItem.MinusSign.pPanel:SetActive("Main", false)
						pItem.pPanel:SetActive("Select", false)
					end
					self:RefreshProgressBar()
				end

				pItem:SetItem(tbInfo.nItemId)

				local bSelected = self.tbChoosen[nItemId]
				pItem.MinusSign.pPanel:SetActive("Main", bSelected)
				pItem.pPanel:SetActive("Select", bSelected)

				pItem.pPanel:Label_SetText("LabelSuffix", self.tbChoosen[nItemId] and string.format("%d/%d", self.tbChoosen[nItemId], tbInfo.nCount) or tbInfo.nCount)
				local fnPress = function ( itemObj, szBtnName, bIsPress )
					self:CloseCountTimer() 
					if not bIsPress or (self.tbChoosen[nItemId] or 0)>=tbInfo.nCount then
						return
					end
					if self.szSelectErr and self.szSelectErr~="" then
						me.CenterMsg(self.szSelectErr)
						return
					end
					self:UpdateAddItemCount( itemObj, 1)
					self:TryStartCountTimer(itemObj)
				end

				pItem.fnPress = fnPress;
			end
		end
	end)
end

function tbUi:RefreshProgressBar()
	local _, _, nTotalValue = Furniture.MagicBowl:CheckMaterials(self.tbChoosen or {}, self.nCachedValue)
	local nPercent = math.min(1, nTotalValue/self.nNeedValue)
	self.pPanel:ProgressBar_SetValue("Bar", nPercent)
	self.pPanel:Label_SetText("BarTxt", string.format("%d%%", math.floor(nPercent*100)))

	local szTip = ""
	if nPercent>=1 then
		szTip = self.bInscription and "此次锻造投入材料有富余，多余材料将保留至下次" or "此次升级投入材料有富余，多余材料将保留至下次"
	end
	self.pPanel:Label_SetText("Tip", szTip)
end