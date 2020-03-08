local tbUi = Ui:CreateClass("TeacherGiftPanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnGive = function(self)
		self:DoGive()
	end,
}

function tbUi:OnOpen(nStudentId)
	self.nStudentId = nStudentId
	if not TeacherStudent:IsMyStudent(nStudentId) then
		return
	end

	local tbStudent = TeacherStudent:GetOtherMainInfo(nStudentId)
	if not tbStudent then
		return
	end
	self.nStudentFaction = tbStudent.nFaction
	self.szStudentName = tbStudent.szName
	self:Refresh()
	self:RefreshTips()
end

function tbUi:Refresh()
	self:InitItemData()
	self:RefreshItems()
end

function tbUi:RefreshItems()
	local nTotalItems = #self.tbValidItems
	local nRows = math.ceil(nTotalItems/7)
	self.ScrollViewItem:Update(nRows, function(pGrid, nIdx)
		for i=1,7 do
			local pItem = pGrid["item"..i]
			local nRealIdx = (nIdx-1)*7+i
			local bValid = nRealIdx<=nTotalItems
			pItem.pPanel:SetActive("Main", bValid)
			if bValid then
				local tbInfo = self.tbValidItems[nRealIdx]
				local nItemId = tbInfo.nItemId
				pItem.pPanel:SetActive("LabelSuffix", true)

				pItem.MinusSign.pPanel.OnTouchEvent = function()
					if self.nCurrentChoose~=nItemId then
						return
					end
					self.nCurrentChoose = nil
					pItem.pPanel:Label_SetText("LabelSuffix", tbInfo.nCount)
					pItem.MinusSign.pPanel:SetActive("Main", false)
					pItem.pPanel:SetActive("Select", false)
					self:RefreshTips()
				end

				pItem:SetItemByTemplate(nItemId, tbInfo.nCount, self.nStudentFaction)

				local bSelected = self.nCurrentChoose==nItemId
				pItem.MinusSign.pPanel:SetActive("Main", bSelected)
				pItem.pPanel:SetActive("Select", bSelected)

				pItem.pPanel:Label_SetText("LabelSuffix", self.nCurrentChoose==nItemId and string.format("1/%d", tbInfo.nCount) or tbInfo.nCount)
				pItem.fnPress = function(itemObj, szBtnName, bIsPress)
					if not bIsPress then
						return
					end
					Item:ShowItemDetail(pItem, {x=370, y=-1})
					if self.nCurrentChoose and self.nCurrentChoose>0 then
						me.CenterMsg("不能赠送更多")
						return
					end
					self.nCurrentChoose = nItemId
					pItem.pPanel:Label_SetText("LabelSuffix", string.format("1/%d", tbInfo.nCount))
					pItem.MinusSign.pPanel:SetActive("Main", true)
					pItem.pPanel:SetActive("Select", true)
					self:RefreshTips()
				end
			end
		end
	end)
	self.pPanel:SetActive("NoGift", nTotalItems<=0)
end

function tbUi:InitItemData()
	local tbValidItems = {}
	for nItemId in pairs(TeacherStudent.tbGraduateGiftItemIds) do
		local tbItems = me.FindItemInBag(nItemId)
		if tbItems and #tbItems>0 then
			local nCount = 0
			for _,pItem in ipairs(tbItems) do
				nCount = nCount+pItem.nCount
			end
			table.insert(tbValidItems, {
				nItemId = nItemId,
				nCount = nCount,
			})
		end
	end
	self.tbValidItems = tbValidItems
	self.nCurrentChoose = nil
end

function tbUi:DoGive()
	if not self.nCurrentChoose or self.nCurrentChoose<=0 then
		me.CenterMsg("请选择要赠送的物品")
		return
	end

	local szMsg = self.pPanel:Input_GetText("TxtTitle")
	if Lib:Utf8Len(szMsg)>TeacherStudent.Def.nGiftMsgMax then
		me.CenterMsg("超过最大字数限制")
		return
	end

	TeacherStudent:GiveReward(self.nStudentId, self.nCurrentChoose, szMsg)
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RefreshTips()
	self.pPanel:Label_SetText("ChooseGifts", string.format("[92D2FF]选择要赠送给徒弟[FFFE0D]%s[-]的礼物：[-]%d/1", self.szStudentName, self.nCurrentChoose and 1 or 0))
end