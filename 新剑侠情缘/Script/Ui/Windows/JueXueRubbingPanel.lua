local tbUi = Ui:CreateClass("JueXueRubbingPanel")
tbUi.tbTitle = {
	DuanPian = "断篇",
	MiBen    = "秘本",
}

function tbUi:RegisterEvent()
	return {
		{ UiNotify.emNOTIFY_SYNC_ITEM, self.OnSyncItem, self},
	}
end

function tbUi:OnOpen(nItemId)
	if not nItemId then
		return 0
	end
	self.nItemId  = nItemId
	local pItem   = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return 0
	end
	self.szPaperClass = string.gsub(pItem.szClass, "Stone", "Paper")
end

function tbUi:OnOpenEnd(nItemId)
	self.pPanel:SetActive("AnimationBG2", false)
	self.pPanel:SetActive("effect_tuoyin", false)
	self.pPanel:SetActive("Reward", false)
	self.nChoosePaper  = nil
	self.nRubbingTimer = nil
	for szKey, szTitle in pairs(self.tbTitle) do
		if string.find(self.szPaperClass, szKey) then
			self.szStoneKey = szKey
			self.pPanel:Label_SetText("TitleRubbing", szTitle .. "拓印")
			break
		end
	end
	self:UpdatePaper()
end

function tbUi:OnClose()
	if self.nRubbingTimer then
		Timer:Close(self.nRubbingTimer)
		self.nRubbingTimer = nil
	end
	self.nItemId         = nil
	self.nChoosePaper    = nil
	self.nChoosePaperTID = nil
	self.nFinishTID      = nil
	self.nRubItemId      = nil
end

function tbUi:UpdatePaper()
	local tbItem = me.FindItemInBag(self.szPaperClass)
	local fnChoose = function (itemObj, nIdx)
		itemObj.pPanel:SetActive("SelSprite", self.nChoosePaper == tbItem[nIdx].dwId)
		itemObj.itemframe:SetItem(tbItem[nIdx].dwId)
		itemObj.pPanel.OnTouchEvent = function ()
			if self.nRubbingTimer then
				return
			end
			self.pPanel:SetActive("Reward", false)
			self.pPanel:SetActive("AnimationBG2", true)
			self.nChoosePaper = tbItem[nIdx].dwId
			self:UpdatePaper()
		end
	end
	self.ScrollView:Update(#tbItem, fnChoose)
	local szPaperName = "请选择拓纸"
	if self.nChoosePaper then
		local pItem = KItem.GetItemObj(self.nChoosePaper)
		szPaperName = pItem and pItem.szName or ""
		szPaperName = "已选择:" .. szPaperName
	end
	self.pPanel:Label_SetText("Description", szPaperName)
	local szNumber = ""
	local nCount = 0
	local pItem = KItem.GetItemObj(self.nItemId)
	if pItem then
		nCount = pItem.nCount
	end
	szNumber = string.format("剩余%s拓石:%d", self.tbTitle[self.szStoneKey], nCount)
	self.pPanel:Label_SetText("TxtNumber", szNumber)
end

function tbUi:Rubbing()
	if self.nRubbingTimer then
		return
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		for szKey, szTitle in pairs(self.tbTitle) do
			if string.find(self.szPaperClass, szKey) then
				me.CenterMsg(string.format("大侠背包中已经没有%s拓石了", szTitle))
				return
			end
		end
		return
	end
	local tbItem = me.FindItemInBag(self.szPaperClass)
	if not tbItem or #tbItem <= 0 then
		Ui:OpenWindow("MessageBox", "背包中已没有拓纸，是否前去购买",
					{ {function ()
			Ui:OpenWindow("CommonShop", "Dress", "tabDressRareShop")
			end}, {function ()
			Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop")
			end}  }, {"稀有拓纸", "普通拓纸"}, nil, nil, nil, nil, true)
		return
	end
	if not self.nChoosePaper then
		me.CenterMsg("请选择拓纸")
		return
	end
	pItem = KItem.GetItemObj(self.nChoosePaper)
	if not pItem then
		return
	end
	self.pPanel:SetActive("effect_tuoyin", true)
	self.nChoosePaperTID = pItem.dwTemplateId
	self.nRubItemId      = nil
	self.nFinishTID      = Item:GetClass("RubbingPaper"):GetFinishItemTID(pItem.dwTemplateId)
	RemoteServer.RubbingClientCall("TryRubbing", self.nItemId, self.nChoosePaper)
	self.nRubbingTimer = Timer:Register(Env.GAME_FPS * 4, function ()
		self:OnRunbbingEnd()
	end)
end

function tbUi:OnRunbbingEnd()
	self.pPanel:SetActive("Reward", true)
	local nShowItemTID = self.nFinishTID
	if self.nRubItemId then
		local pItem = KItem.GetItemObj(self.nRubItemId)
		if pItem then
			nShowItemTID = pItem.dwTemplateId
		end
	end
	self.itemReward:SetItemByTemplate(nShowItemTID, 1)
	self.itemReward.fnClick = self.itemReward.DefaultClick
	if not KItem.GetItemObj(self.nChoosePaper) then
		self.nChoosePaper = nil
	end
	self.nRubbingTimer   = nil
	self.nChoosePaperTID = nil
	self.nFinishTID      = nil
	self.nRubItemId      = nil
	self.pPanel:SetActive("AnimationBG2", self.nChoosePaper or false)
	self.pPanel:SetActive("effect_tuoyin", false)
	self:UpdatePaper()
end

function tbUi:UpdatePaperCount(nItemId, bNew, nCount)
	if self.nRubbingTimer then
		return
	end
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem then
		return
	end
	if pItem.szClass ~= self.szPaperClass then
		return
	end
	self:UpdatePaper()
end

function tbUi:OnSyncItem(nItemId, bNew, nCount)
	self:UpdatePaperCount(nItemId, bNew, nCount)
	if nCount ~= 1 then
		return
	end
	if self.nRubItemId then
		return
	end
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem then
		return
	end
	if string.find(pItem.szClass, "Unidentify") then
		self.nRubItemId = nItemId
	end
end

tbUi.tbOnClick = {
	BtnRubbing = function (self)
		self:Rubbing()
	end,
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}