local tbUI = Ui:CreateClass("RedBagPanel")

tbUI.tbOnClick =
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUI:RegisterEvent()
	local tbRegEvent = {
		{ UiNotify.emNOTIFY_REDBAG_DATA_REFRESH, self.Refresh, self },
	}

	return tbRegEvent
end

function tbUI:OnOpen()
	self:Refresh()
	Kin:RefreshRedBagAll()
end

function tbUI:OnClose()
	Kin:RedBagUpdateRedPoint(false)
end

function tbUI:Refresh()
	self:RefreshRedBags()
end

local tbRedBagStates = {
	canGrab = 1,	-- 未领完(可领)
	canSend = 2,	-- 可发送
	cantGrab = 3,	-- 未领完(不可领)
	notSend = 4,	-- 未发送
	empty = 5,		-- 已领完
	last = 6,
}

local function _GetState(tbRedBag)
	local bMine = tbRedBag.tbOwner.nId==me.dwID
	local bSend = tbRedBag.nSendTime>0
	local bEmpty = tbRedBag.bEmpty
	if bSend and not bEmpty then
		if tbRedBag.bCanGrab then
			return tbRedBagStates.canGrab
		else
			return tbRedBagStates.cantGrab
		end
	end
	if bMine and not bSend then
		return tbRedBagStates.canSend
	end
	if not bSend then
		return tbRedBagStates.notSend
	end
	if bEmpty then
		return tbRedBagStates.empty
	end
	return tbRedBagStates.last
end

function tbUI:GetRedBags(bMine)
	local tbRet = {}
	for _,tb in ipairs(Kin.tbRedBags or {}) do
		if bMine then
			if tb.tbOwner.nId==me.dwID then
				table.insert(tbRet, tb)
			end
		else
			if tb.tbOwner.nId~=me.dwID then
				table.insert(tbRet, tb)
			end
		end
	end
	return tbRet
end

function tbUI:ShowItemBg(pGrid, szNotEmpty, szEmpty, szVoice, bEmpty, bGlobal, bVoice)
	pGrid.pPanel:SetActive(szNotEmpty, false)
	pGrid.pPanel:SetActive(szEmpty, false)
	pGrid.pPanel:SetActive(szVoice, false)

	if not bEmpty then
		if bVoice then
			pGrid.pPanel:Texture_SetTexture(szVoice, bGlobal and "UI/Textures/RedPaper6.png" or "UI/Textures/RedPaper2.png")
			pGrid.pPanel:SetActive(szVoice, true)
		else
			pGrid.pPanel:Texture_SetTexture(szNotEmpty, bGlobal and "UI/Textures/RedPaper6.png" or "UI/Textures/RedPaper2.png")
			pGrid.pPanel:SetActive(szNotEmpty, true)
		end
	else
		pGrid.pPanel:Texture_SetTexture(szEmpty, bGlobal and "UI/Textures/RedPaper7.png" or "UI/Textures/RedPaper3.png")
		pGrid.pPanel:SetActive(szEmpty, true)
	end
end

function tbUI:SortRedBags(tbRedBags)
	table.sort(tbRedBags, function(tbA, tbB)
		local nStateA = _GetState(tbA)
		local nStateB = _GetState(tbB)
		if nStateA==nStateB then
			local bGlobalA = Kin:RedBagIsIdGlobal(tbA.szId)
			local bGlobalB = Kin:RedBagIsIdGlobal(tbB.szId)
			if bGlobalA==bGlobalB then
				return tbA.nSendTime>tbB.nSendTime
			else
				return bGlobalA
			end
		end
		return nStateA<nStateB
	end)
	return tbRedBags
end

function tbUI:RefreshMine()
	local nRows = 0
	local nTotalCount = 0
	local tbRedBags = self:GetRedBags(true)
	if tbRedBags then
		nTotalCount = #tbRedBags
		nRows = math.ceil(nTotalCount/3)
		tbRedBags = self:SortRedBags(tbRedBags)
	end
	self.RecordScrollView:Update(nRows, function(pGrid, nIdx)
		for i=1,3 do
			local nRealIdx = (nIdx-1)*3+i
			local tbRedBag = tbRedBags[nRealIdx]
			pGrid.pPanel:SetActive("Normal"..i, not not tbRedBag)
			pGrid.pPanel:SetActive("Empty"..i, not tbRedBag)
			local pEffect = pGrid["effect"..i]
			pEffect.pPanel:SetActive("Main", false)
			pGrid.pPanel:SetActive("WorldRedPaper"..i, false)

			if tbRedBag then
				local bGlobal = Kin:RedBagIsIdGlobal(tbRedBag.szId)
				pGrid.pPanel:SetActive("WorldRedPaper"..i, bGlobal)

				local nState = _GetState(tbRedBag)
				local szContent = Kin:RedBagGetContent(tbRedBag)
				pGrid.pPanel:Label_SetText("Content"..i, szContent)
				pGrid.pPanel:Label_SetText("Number"..i, tbRedBag.nGold)

				local szNotEmpty = string.format("Paper%d_1", i)
				local szEmpty = string.format("Paper%d_2", i)
				self:ShowItemBg(pGrid, szNotEmpty, szEmpty, szNotEmpty, nState==tbRedBagStates.empty, bGlobal,
					tbRedBag.nKind == Kin.Def.tbRedBagKind.VOICE or tbRedBag.nKind == Kin.Def.tbRedBagKind.FIXED_VOICE)

				local szMarkIcon,_,nMulti = Kin:RedBagGetMultiInfo(tbRedBag.nEventId, tbRedBag.nGold)
				pGrid.pPanel:SetActive("Mark"..i, not not szMarkIcon)
				if szMarkIcon then
					pGrid.pPanel:Sprite_SetSprite("Mark"..i, szMarkIcon)
				end

				if nMulti then
					self:ShowMultiEffect(pEffect, nMulti)
					pEffect.pPanel:SetActive("Main", true)
				end

				pGrid["BtnOpen"..i].pPanel:SetActive("Main", false)
				pGrid["BtnCheck"..i].pPanel:SetActive("Main", false)
				if nState==tbRedBagStates.canSend then
					pGrid["BtnOpen"..i].pPanel:SetActive("Main", true)
					pGrid["BtnOpen"..i].pPanel:Label_SetText("Label", "发红包")
					pGrid["BtnOpen"..i].pPanel.OnTouchEvent = function()
						Ui:OpenWindow("RedBagDetailPanel", "send", tbRedBag.szId)
					end
				elseif nState==tbRedBagStates.canGrab then
					pGrid["BtnOpen"..i].pPanel:SetActive("Main", true)
					pGrid["BtnOpen"..i].pPanel:Label_SetText("Label", "开红包")
					pGrid["BtnOpen"..i].pPanel.OnTouchEvent = function()
						Ui:OpenWindow("RedBagDetailPanel", "viewgrab", tbRedBag.szId)
					end
				else
					pGrid["BtnCheck"..i].pPanel:SetActive("Main", true)
					pGrid["BtnCheck"..i].pPanel.OnTouchEvent = function()
						Ui:OpenWindow("RedBagDetailPanel", "viewgrab", tbRedBag.szId)
					end
				end
			end
		end
	end)

	self.pPanel:SetActive("NoAuction", nTotalCount<=0)
end

local tbMultis = {2, 3, 6}
function tbUI:ShowMultiEffect(pGrid, nMulti)
	for i=1,3 do
		pGrid.pPanel:SetActive("texiao"..i, tbMultis[i]==nMulti)
	end
end

function tbUI:RefreshOthers()
	local nCount = 0
	local tbRedBags = self:GetRedBags(false)
	if tbRedBags then
		nCount = #tbRedBags
		tbRedBags = self:SortRedBags(tbRedBags)
	end

	self.RedPaperScrollView:Update(nCount, function(pGrid, nIdx)
		local tbRedBag = tbRedBags[nIdx]
		local bGlobal = Kin:RedBagIsIdGlobal(tbRedBag.szId)

		local tbOwner = tbRedBag.tbOwner
		pGrid.pPanel:Label_SetText("Name", string.format("%s", tbOwner.szName))

		local szContent = Kin:RedBagGetContent(tbRedBag)
		pGrid.pPanel:Label_SetText("Content", string.format("%s\n价值[FFFE0D]%s[-]#999", szContent, tbRedBag.nGold))

		pGrid.BtnGrant.pPanel:SetActive("Main", false)
		pGrid.BtnCheck.pPanel:SetActive("Main", false)

		pGrid.pPanel:SetActive("Bg1", not tbRedBag.bCanGrab and not bGlobal)
		pGrid.pPanel:SetActive("Bg3", not tbRedBag.bCanGrab and bGlobal)
		pGrid.pPanel:SetActive("Bg2", tbRedBag.bCanGrab)
		pGrid.pPanel:SetActive("WorldRedPaperTxt", bGlobal)
		self:ShowItemBg(pGrid, "RedPaper1", "RedPaper2", "RedPaper3", tbRedBag.bEmpty, bGlobal,
			tbRedBag.nKind == Kin.Def.tbRedBagKind.VOICE or tbRedBag.nKind == Kin.Def.tbRedBagKind.FIXED_VOICE)
		if tbRedBag.bCanGrab then
			pGrid.BtnGrant.pPanel:SetActive("Main", true)
			pGrid.BtnGrant.pPanel.OnTouchEvent = function()
				Ui:OpenWindow("RedBagDetailPanel", "viewgrab", tbRedBag.szId, true)
			end
		else
			pGrid.BtnCheck.pPanel:SetActive("Main", true)
			pGrid.BtnCheck.pPanel:Label_SetText("Main", tbRedBag.nSendTime>0 and "查看" or "未发放")
			pGrid.BtnCheck.pPanel.OnTouchEvent = function()
				if tbRedBag.nSendTime>0 then
					Ui:OpenWindow("RedBagDetailPanel", "viewgrab", tbRedBag.szId)
				end
			end
		end

		local szMarkIcon,_,nMulti = Kin:RedBagGetMultiInfo(tbRedBag.nEventId, tbRedBag.nGold)
		pGrid.pPanel:SetActive("Mark", not not szMarkIcon)
		if szMarkIcon then
			pGrid.pPanel:Sprite_SetSprite("Mark", szMarkIcon)
		end

		if nMulti then
			self:ShowMultiEffect(pGrid.effect, nMulti)
		end
		pGrid.pPanel:SetActive("effect", not not nMulti)
	end)

	self.pPanel:SetActive("NoRedPaper", nCount<=0)
end

function tbUI:RefreshRedBags()
	self:RefreshMine()
	self:RefreshOthers()
end

