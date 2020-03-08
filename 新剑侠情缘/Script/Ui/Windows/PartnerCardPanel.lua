local tbUi = Ui:CreateClass("PartnerCard");
tbUi.nMaxShowCardPos = 5
tbUi.nMaxShowSuit = 5
tbUi.PANEL_MAIN = 1
tbUi.PANEL_ATTRI = 2
tbUi.tbSetting = 
{
	[tbUi.PANEL_MAIN] = {
		szPanelName = "CardPanel1";
	};
	[tbUi.PANEL_ATTRI] = {
		szPanelName = "CardPanel2";
	};
}

function tbUi:Update(nPartnerPos, bUpdate)
	self.tbOwnCard = self.tbOwnCard or {}
	if bUpdate or not next(self.tbOwnCard) then
		self.tbOwnCard = PartnerCard:GetSortOwnPartnerCard()
	end
	self:UpdateOwnCard()
	PartnerCard:CheckPartnerCardPanelRedPoint()
	self.nPanelType = self.nPanelType or self.PANEL_MAIN
	self:SwitchPanel()
	self.nPartnerCardSuitShowFlag = self.nPartnerCardSuitShowFlag or (Client:GetFlag("PartnerCardSuitShow") or 0)
	self.bPartnerCardSuitShow = self.nPartnerCardSuitShowFlag == 0 and true or false
	self["PartnerCardToggle"].pPanel:SetActive("Sprite", self.bPartnerCardSuitShow)
	self.nPartnerPos = nPartnerPos or self.nPartnerPos or 1
	local nShowPosGuide = Client:GetFlag("PartnerCardPosGuide") or 0
	local nPartnerPos = self.nPartnerPos
	local tbOwnCard = self.tbOwnCard
	local fnSetToggle = function (nIdx)
		for i=0, 300 do
			local pObj = self.PartnerCardScrollView.Grid["Item" ..i]
			if not pObj then
				break
			end
			pObj.pPanel:Toggle_SetChecked("Main",  nIdx == pObj.nIdx);
		end
	end;
	local fnCheckRedPoint = function (itemObj)
		local bNew = PartnerCard:CheckIsNewCard(itemObj.nCardId)
		local bCanUpGrade = PartnerCard:CanCardUpGrade(me, itemObj.nCardId)
		itemObj.pPanel:SetActive("RedPoint", bNew or bCanUpGrade)
	end;
	local fnSetItem = function(itemObj, nIdx)
		local tbCardInfo = tbOwnCard[nIdx]
		itemObj:SetHeadByCardInfo(tbCardInfo.nPartnerTempleteId, tbCardInfo.nLevel, tbCardInfo.szName, nil, tbCardInfo.nFightPower)
		local bLive = PartnerCard:IsCardLiveHouse(me, tbCardInfo.nCardId)
		itemObj.pPanel:SetActive("HouseMark", bLive)
		itemObj["BtnCheck"].pPanel:SetActive("Check", tbCardInfo.nPos > 0)
		itemObj["BtnCheck"].pPanel:SetActive("GuideTips", false)
		itemObj["BtnCheck"].nPos = tbCardInfo.nPos
		itemObj["BtnCheck"].nCardId = tbCardInfo.nCardId
		itemObj["BtnCheck"].nPartnerPos = self.nPartnerPos
		itemObj.nCardId = tbCardInfo.nCardId
		itemObj.nIdx = nIdx
		fnCheckRedPoint(itemObj)
		itemObj["BtnCheck"].nIdx = nIdx
		itemObj["BtnCheck"].pPanel.OnTouchEvent = function (itemObj)
			if itemObj.nPos <= 0 then
				RemoteServer.PartnerCardOnClientCall("UpPos", self.nPartnerPos, tbCardInfo.nCardId)
			else
				RemoteServer.PartnerCardOnClientCall("DownPos", itemObj.nPos, tbCardInfo.nCardId)
			end
			if itemObj.nIdx == 1 and nShowPosGuide ~= 1 then
				Client:SetFlag("PartnerCardPosGuide", 1)
				itemObj.pPanel:SetActive("GuideTips", false)
			end
			fnSetToggle(itemObj.nIdx)
		end
		itemObj["EntourageHead"].nCardId = tbCardInfo.nCardId
		if nIdx == 1 and nShowPosGuide ~= 1 then
			itemObj["BtnCheck"].pPanel:SetActive("GuideTips", true)
		end
		itemObj.pPanel.OnTouchEvent = function (itemObj)
		   PartnerCard:RemoveNewCardFlag(itemObj.nCardId)
		   PartnerCard:CheckPartnerCardPanelRedPoint()
           fnCheckRedPoint(itemObj)
           Ui:OpenWindow("PartnerCardDetailTip", itemObj.nCardId, true)
		end;
	end
	self.PartnerCardScrollView:Update(tbOwnCard, fnSetItem);
	local tbPosInfo = me.GetPartnerPosInfo()
	for i = 1 , 4 do
		local nPartnerId = tbPosInfo[i];
		local tbPartner = me.GetPartnerInfo(nPartnerId);
		local szHeadName = "PartnerHead" ..i
		local szTabName = "TabCompanion" ..i
		if tbPartner then
			self[szTabName][szHeadName]:SetPartnerById(tbPartner.nTemplateId, nil, tbPartner.nFightPower);
			--self[szTabName][szHeadName]:SetPartnerInfo(tbPartner);
			self[szTabName][szHeadName].pPanel:SetActive("Main", true);
		else
			self[szTabName][szHeadName]:Clear();
			self[szTabName][szHeadName].pPanel:SetActive("Main", false);
		end
		self[szTabName].pPanel:SetActive("PartnerHeadChoose", i == self.nPartnerPos)
		self[szTabName].nPartnerPos = i
		self[szTabName].pPanel.OnTouchEvent = function (itemObj)
			self.nPartnerPos = itemObj.nPartnerPos
			self:UpdateCardPos(itemObj.nPartnerPos)
			for i = 1, 4 do
				self["TabCompanion" ..i].pPanel:SetActive("PartnerHeadChoose", i == itemObj.nPartnerPos)
			end
			if PartnerCard:CheckNewOpenRedPoint(itemObj.nPartnerPos) then
				me.tbPartnerCardPosRP = me.tbPartnerCardPosRP or {}
				me.tbPartnerCardPosRP[itemObj.nPartnerPos] = true
				PartnerCard:CheckRedPoint()
				PartnerCard:CheckPartnerCardPanelRedPoint()
			end
	    end
	    local tbSkillId = (tbPartner and PartnerCard:GetActiveSkillId(me, tbPartner.nTemplateId, i)) or {}
	    local bActiveSkill = next(tbSkillId) and true or false
	    self[szTabName][szHeadName]["BtnNurse"].pPanel:SetActive("Effect", bActiveSkill)
	    self[szTabName][szHeadName]["BtnNurse"].nPartnerPos = i
	    self[szTabName][szHeadName]["BtnNurse"].tbPartner = tbPartner
	    self[szTabName][szHeadName]["BtnNurse"].pPanel.OnTouchEvent = function (itemObj)
	    	if not itemObj.tbPartner then
	    		return
	    	end
            local tbSkillId = PartnerCard:GetActiveSkillId(me, itemObj.tbPartner.nTemplateId, itemObj.nPartnerPos)
           
        	local _, nStarLevel = Partner:GetStarValue(itemObj.tbPartner.nFightPower);
			local nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
			local nMaxFightPower = Partner:GetMaxFightPower(itemObj.tbPartner);
			local _, nMaxStar = Partner:GetStarValue(nMaxFightPower);
			local nMaxLevel = math.max(Partner.tbFightPowerToSkillLevel[nMaxStar] or 1, nSkillLevel);
			local tbDefaultSkill = GetPartnerDefaultSkill(itemObj.tbPartner.nTemplateId);
			local nProtectSkillId = tbDefaultSkill[2];
			local nExtLevel = me.GetSkillFlagLevel(nProtectSkillId) or 0;
			nSkillLevel = nSkillLevel + nExtLevel;
			nMaxLevel = nMaxLevel + nExtLevel;
			if nProtectSkillId then
				 if tbSkillId then
				 	Partner:ShowSkillTips(nProtectSkillId, nSkillLevel, nMaxLevel, false, tbSkillId);
				 else
				 	Partner:ShowSkillTips(nProtectSkillId, nSkillLevel, nMaxLevel, false, nil, "门客护主效果：未激活，需要本同伴的随从中包含同名门客方可激活");
				 end
			end
	    end;
	end
	self:UpdateCardPos(nPartnerPos)
	self:UpdateAttrib()
	self["CardPanel2"]["BtnBackCard"].pPanel.OnTouchEvent = function (itemObj)
		self:SwitchPanel(self.PANEL_MAIN)
	end
	PartnerCard:CheckRedPoint()
end

-- 不改变排序更新门客数据
function tbUi:UpdateOwnCard()
	local tbOwnCard = PartnerCard:GetSortOwnPartnerCard()
	for _, v in ipairs(tbOwnCard) do
		for nIdx, j in ipairs(self.tbOwnCard) do
			if j.nCardId == v.nCardId then
				self.tbOwnCard[nIdx] = v
			end
		end
	end
end

function tbUi:UpdateCardPos(nPartnerPos)
	local fnOnClickHead = function (itemObj)
		if not itemObj.nCardId then
			return
		end
		Ui:OpenWindow("PartnerCardDetailTip", itemObj.nCardId, true)
	end;
	local fnGet = function (itemObj)
		Ui:OpenWindow("PartnerCardGetGuidePanel")
	end;
	local fnUnlock = function (itemObj)
		local bRet, szMsg, tbCost, szItemName, nItemCount, nCount = PartnerCard:CanUnlockCardPos(me, itemObj.nCardPos)
		if not bRet then
			if szItemName then
				me.MsgBox(string.format("开启该门客位需%s[FF0000]*%d[-]，是否前往商城购买\n(已拥有[FFFE0D]%d[-]个)", szItemName or "", nItemCount or 0, nCount or 0), {{"确定", function ()
					Ui:OpenWindow("CommonShop", "Dress", "tabDressRareShop")
				end}, {"取消"}})
			else
				me.CenterMsg(szMsg, true);
			end
			return
		end
		RemoteServer.PartnerCardOnClientCall("UnlockCardPos", itemObj.nCardPos)
	end;
	local tbOwnCard = self.tbOwnCard
	local tbCardPos2CardInfo = PartnerCard:GetCardPosRefCardInfo(tbOwnCard)
	local tbCardPos, tbLockOpenCardPos, _, _, tbOnPosCard = PartnerCard:GetShowCardPos(me)
	local tbUnlock = tbCardPos[nPartnerPos] or {}
	local tbCardSuitRef, tbActiveSuitRef = {}, {}
	tbUnlock, tbCardSuitRef, tbActiveSuitRef = PartnerCard:SortUnLockPos(tbUnlock, nPartnerPos)
	local tbLock = tbLockOpenCardPos[nPartnerPos] or {}
	local nUnlock = #tbUnlock
	-- 未解锁的最多显示PartnerCard.nShowLockCardPos个
	local nLock = math.min(PartnerCard.nShowLockCardPos, #tbLock)
	local nShowLock = next(tbOwnCard) and nUnlock + nLock or 0
	for i = 1, self.nMaxShowCardPos do
		self["EntourageItem" ..i].pPanel:SetActive("Main", false)
		local nCurPosSuit, nNextPosSuit = 0, 0
		local nCurPos = tbUnlock[i] or 0
		local nNextPos = tbUnlock[i+1] or 0
		local tbCurCard = PartnerCard:IsPosHaveCard(me, nCurPos)
		local tbNextCard = PartnerCard:IsPosHaveCard(me, nNextPos)
		local bActive = false
		if tbCurCard and tbNextCard then
			nCurPosSuit = tbCardSuitRef[tbCurCard.nCardId] or 0
			nNextPosSuit = tbCardSuitRef[tbNextCard.nCardId] or 0
			-- 套装属性激活了才显示
			if nCurPosSuit ~= 0 and nCurPosSuit == nNextPosSuit and tbActiveSuitRef[nCurPosSuit] then
				bActive = true
			end
		end
		self.pPanel:SetActive("Line" ..i, bActive)
	end
	local tbPosInfo = me.GetPartnerPosInfo()
	local fnGetOnePos = function()
		local nCardPos = tbUnlock[1]
		table.remove(tbUnlock, 1)
		return nCardPos
	end
	for nIdx = 1, nShowLock do
		local itemObj = self["EntourageItem" ..nIdx]
		if itemObj then
			itemObj.pPanel:SetActive("Main", true)
			local bLock = nIdx > nUnlock
			local nLockIdx = nIdx - nUnlock
			local nCardPos = bLock and tbLock[nLockIdx] or fnGetOnePos()
			local tbCardInfo = tbCardPos2CardInfo[nCardPos]
			if tbCardInfo and not bLock then
				itemObj.nCardId = tbCardInfo.nCardId
				itemObj.pPanel.OnTouchEvent = fnOnClickHead;
				itemObj:SetHeadByCardInfo(tbCardInfo.nPartnerTempleteId, tbCardInfo.nLevel)
			else
				itemObj:Clear()
			end
			itemObj.pPanel:SetActive("Unseal", false)
			itemObj.pPanel:SetActive("Lock", false)
			itemObj.pPanel:SetActive("Get", false)
			itemObj["Unseal"].nCardPos = nCardPos
			itemObj["Unseal"].pPanel.OnTouchEvent = fnUnlock;
			local tbCardPosInfo = PartnerCard:GetCardPosInfo(nCardPos)
			if tbCardPosInfo then
				if bLock then
					itemObj.pPanel:SetActive("Lock", true)
					itemObj["Lock"].pPanel.OnTouchEvent = fnClickLock;
					if tbCardPosInfo then
						itemObj["Lock"].pPanel:Label_SetText("LockTxt", tbCardPosInfo.szLockTip)
					end
				else
					if not PartnerCard:IsCardPosUnlock(me, nCardPos) then
						itemObj["Unseal"].pPanel:SetActive("Main", true)
						itemObj["Unseal"].pPanel:Label_SetText("UnsealTxt", tbCardPosInfo.szConsumeTip)
					else
						local bPosHaveCard = PartnerCard:IsPosHaveCard(me, nCardPos)
						itemObj["Get"].pPanel:SetActive("Main", not bPosHaveCard and true or false)
						itemObj["Get"].nPartnerPos = nPartnerPos
						itemObj["Get"].pPanel.OnTouchEvent = fnGet;
					end
				end
			end
			itemObj.pPanel:SetActive("EntourageNurse", false)
			local nPartnerId = tbPosInfo[self.nPartnerPos];
			local tbPartner = me.GetPartnerInfo(nPartnerId);
			if tbPartner then
				local nPartnerTemplateId = tbCardInfo and tbCardInfo.nPartnerTempleteId
				if nPartnerTemplateId and nPartnerTemplateId == tbPartner.nTemplateId then
					itemObj.pPanel:SetActive("EntourageNurse", true)
					itemObj["EntourageNurse"].pPanel:SetActive("Effect", true)
					itemObj["EntourageNurse"].pPanel.OnTouchEvent = function (itemObj)
                       me.CenterMsg("护主属性已激活", true)
					end;
				end
			end
		end
	end

	self:UpdateSuitUi(nPartnerPos)
end

function tbUi:UpdateSuitUi(nPartnerPos) 
	local tbSuitIndx = {}
	local tbAllSuitIdx = {}
	for i=1, self.nMaxShowSuit do
		local nCardId = self["EntourageItem" ..i].nCardId or 0
		local tbCardInfo = PartnerCard:GetCardInfo(nCardId) or {}
		local nSuitIdx = tbCardInfo.nSuitIdx or 0
		-- 去除重复的
		if tbAllSuitIdx[nSuitIdx] then
			nSuitIdx = 0
		else
			tbAllSuitIdx[nSuitIdx] = i
		end
		tbSuitIndx[i] = nSuitIdx
		self.pPanel:SetActive("Team" ..i, false)
	end
	local nPartnerPos = nPartnerPos or self.nPartnerPos
	local tbAttrib = PartnerCard:GetPartnerPosAttrib(me, nPartnerPos)
	local tbSuitDesInfo, nSuitAttribLine = PartnerCard:GetSuitAttribDesInfo(tbAttrib.tbSuitAttrib, 2, nil, nPartnerPos)
	local fnGetSuitDes = function (nSuitIdx)
		for _, v in ipairs(tbSuitDesInfo) do
			if v.nSuitIdx == nSuitIdx then
				return v
			end
		end
	end
	for i=1, self.nMaxShowSuit do
		local nSuitIdx = tbSuitIndx[i] or 0
		local tbSuitDes = fnGetSuitDes(nSuitIdx) or {}
		self.pPanel:SetActive("Team" ..i, (next(tbSuitDes) and self.bPartnerCardSuitShow) and true or false)
		local szSuitName = tbSuitDes.szSuitName or ""
		local szCardName = tbSuitDes.szCardName or ""
		self.pPanel:Label_SetText("TeamTitle" ..i, szSuitName)
		self.pPanel:Label_SetText("TeamName" ..i, szCardName)
	end
end

function tbUi:OnClose()
	local nShowSuitFlag = self.bPartnerCardSuitShow and 0 or 1
	Client:SetFlag("PartnerCardSuitShow", nShowSuitFlag)
	self.tbOwnCard = {}
end

function tbUi:UpdateAttrib()
	local tbAttrib = PartnerCard:GetAllActiveAttrib(me)
	self["CardPanel2"]:RefreshData(tbAttrib)
end

function tbUi:SwitchPanel(nPanelType)
	self.nPanelType = nPanelType or self.nPanelType
	local tbInfo = self.tbSetting[self.nPanelType]
	if not tbInfo then
		return
	end
	for nType, v in pairs(self.tbSetting) do
		self.pPanel:SetActive(v.szPanelName, nType == self.nPanelType)
	end
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:GuestGet()
	Ui:OpenWindow("PartnerCardGetGuidePanel")
end

function tbUi.tbOnClick:BtnSummary()
	self:SwitchPanel(self.PANEL_ATTRI)
end

function tbUi.tbOnClick:PartnerCardToggle()
	self.bPartnerCardSuitShow = not self.bPartnerCardSuitShow
	local nShowSuitFlag = self.bPartnerCardSuitShow and 0 or 1
	self.nPartnerCardSuitShowFlag = nShowSuitFlag
	self:UpdateSuitUi()
	self["PartnerCardToggle"].pPanel:SetActive("Sprite", self.bPartnerCardSuitShow)
end