local tbUi = Ui:CreateClass("PartnerCardDetailTip");
tbUi.tbOperationUi = {"BtnHome", "BtnAdvanced", "BtnGive"}
function tbUi:OnOpen(nCardId, bOperation, tbCard, tbAttribDesc)
	self.nCardId = nCardId or self.nCardId
	self.bOperation = bOperation 
	self.tbCard = tbCard
	self.nCardIdx = self:GetCardIdx(nCardId, tbCard)
	self.tbAttribDesc = tbAttribDesc or {}
	self:Update()
end

function tbUi:GetCardIdx(nCardId, tbCard)
	local nCardIdx = 1
	for nIdx, v in ipairs(tbCard or {}) do
		if v.nCardId == nCardId then
			nCardIdx = nIdx
			break
		end
	end
	return nCardIdx
end

function tbUi:Update(nCardId, bOperation, bGradeUp)
	local nCardId = nCardId or self.nCardId
	local bOperation = bOperation or self.bOperation

	for _, szUiName in ipairs(self.tbOperationUi) do
		self.pPanel:SetActive(szUiName, bOperation and true or false)
	end

	--self.pPanel:SetActive("BlackShelter", not bOperation)

	local tbCardInfo = PartnerCard:GetCardInfo(nCardId)
	if not tbCardInfo then
		return 
	end
	PartnerCard:RemoveNewCardFlag(nCardId)
	local nPartnerTempleteId = tbCardInfo.nPartnerTempleteId
	local szName = tbCardInfo.szName
	local nLevel = self.tbAttribDesc.nLevel or PartnerCard:GetCardSaveInfo(me, nCardId, PartnerCard.nLevelIdxStep)
	local nSetLevel = bGradeUp and nLevel - 1 or nLevel
	local _, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTempleteId);
	self["EntourageItem"]:SetHeadByCardInfo(nPartnerTempleteId, nSetLevel, szName)
	local nCurExp = self.tbAttribDesc.nCurExp or PartnerCard:GetCardSaveInfo(me, nCardId, PartnerCard.nExpIdxStep)
	local tbLevelExp = PartnerCard.tbCardUpGrade[nQualityLevel] or {}
	local tbNextLevelInfo =  tbLevelExp[nLevel] or {}
	local nNextLevelExp = tbNextLevelInfo.nUpGradeExp or 0
	local szExp = string.format("%d/%d", nCurExp, nNextLevelExp)
	local nPercent = nCurExp / nNextLevelExp
	self.pPanel:Label_SetText("IntimacyPercent", szExp)
	self.pPanel:Sprite_SetFillPercent("Intimacy", nPercent)

	local nLine = 0 			-- 每种属性显示都有一行表头和一行换行，一共3种（护主属性，基础属性，组合属性）nSkillAttribLine，nPlayerAttribLine，nSuitAttribLine是各自属性描述的行数
	local tbAttrib = PartnerCard:GetShowCardAttrib(me, nCardId)
	local szSkillAttrib, nSkillAttribLine = PartnerCard:GetSkillAttribDesc(tbAttrib.tbPartnerSkill, nil, true)
	nSkillAttribLine = nSkillAttribLine + 2
	local szPlayerAttrib, nPlayerAttribLine = PartnerCard:GetAttribDesc(PartnerCard:GetAttribInfo(tbAttrib.tbPlayerAttrib))
	nPlayerAttribLine = nPlayerAttribLine + 2
	local tbSuitDesInfo, nSuitAttribLine = PartnerCard:GetSuitAttribDesInfo(tbAttrib.tbSuitAttrib, nil, nil, nil, true)
	nSuitAttribLine = nSuitAttribLine + 2
	local szSuitDes = ""
	for _, v in ipairs(tbSuitDesInfo) do
		szSuitDes = szSuitDes ..string.format("[11ADF6][%s][-]", v.szSuitName) .."\n"
		szSuitDes = szSuitDes .. v.szCardName .."\n"
		szSuitDes = szSuitDes .. v.szAttribDes .."\n"
		nSuitAttribLine = nSuitAttribLine + 3 					-- 加上组合名字1行，组合门客名字1行和一行换行
	end
	nLine = nLine + nPlayerAttribLine + nSuitAttribLine
	szSuitDes = Lib:IsEmptyStr(szSuitDes) and "[B4B4B4]无[-]" or szSuitDes
	self.pPanel:Label_SetText("GuestTextDesc", string.format("[73CBD5FF]护主属性：[-]\n%s", self.tbAttribDesc.szSkillAttrib or szSkillAttrib))
	self.pPanel:Label_SetText("GuestTextDesc2", string.format("[73CBD5FF]基础属性：[-]\n%s", self.tbAttribDesc.szPlayerAttrib or szPlayerAttrib))
	self.pPanel:Label_SetText("GuestTextDesc3", string.format("[73CBD5FF]组合属性：[-]\n%s", self.tbAttribDesc.szSuitDes or szSuitDes))
	nLine = math.max(nLine, 11)
	local nSizeX = -(self.tbAttribDesc.nLine or nLine) * 15
	local nSizeY = 145   -- 11行145是最佳效果
	self.pPanel:ResizeScrollViewBound("GuestDescScrollView", nSizeX, nSizeY);
	local nHeight = math.max(375, nLine * 50)
	
	self.pPanel:ChangeBoxColliderSize("Guestdatagroup", 220, nHeight)
	self.pPanel:DragScrollViewGoTop("GuestDescScrollView");

	self["EntourageItem"]["EntourageHead"].pPanel:SetActive("ShengJi", false)
	for i=1,5 do
		self["EntourageItem"]["SprStar" ..i].pPanel:SetActive("xingji", false)
	end
	if bGradeUp then
		self:PlayGradeUpEffect(nPartnerTempleteId, nLevel, szName)
	end
	local bLiveHouse = PartnerCard:IsCardLiveHouse(me, nCardId)
	local szHouseTxt = bLiveHouse and "离开家园" or "入住家园"
	self.pPanel:Label_SetText("HomeTxt", szHouseTxt)

	local nFightPower = PartnerCard:GetCardFightPower(me, nCardId, self.tbAttribDesc.nLevel)
	self.pPanel:Label_SetText("FightPower", string.format("战力：%s", nFightPower))

	local bCanUpGrade = PartnerCard:CanCardUpGrade(me, nCardId)
	self.pPanel:SetActive("RedPoint", bCanUpGrade)

	local nBtnLiveGuide = Client:GetFlag("PartnerCardBtnLive") or 0
	--local nBtnUpPosGuide = Client:GetFlag("PartnerCardBtnUpPos") or 0
	self.pPanel:SetActive("GuideTips", nBtnLiveGuide == 1)
	--self.pPanel:SetActive("GuideTips2", nBtnUpPosGuide == 1)
end

function tbUi:PlayGradeUpEffect(nPartnerTempleteId, nLevel, szName)
	self["EntourageItem"]["EntourageHead"].pPanel:SetActive("ShengJi", true)
	self.nStarTimer = Timer:Register(8, function (self, nPartnerTempleteId, nLevel, szName) 
		local nStartIdx = math.ceil(nLevel/2)
		self["EntourageItem"]:SetHeadByCardInfo(nPartnerTempleteId, nLevel, szName)
		self["EntourageItem"]["SprStar" ..nStartIdx].pPanel:SetActive("xingji", true)
		self.nStarTimer = nil
	 end, self, nPartnerTempleteId, nLevel, szName)
	
end

function tbUi:CloseStarTimer()
	if self.nStarTimer then
		Timer:Close(self.nStarTimer)
		self.nStarTimer = nil
	end
end

function tbUi:OnClose()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DATA_CHANGE)
end

tbUi.tbOnClick = {};

-- tbUi.tbOnClick.BtnClose = function (self)
-- 	Ui:CloseWindow(self.UI_NAME)
-- end

tbUi.tbOnClick.BtnGive = function (self)
	Ui:CloseWindow(self.UI_NAME)
	Ui:OpenWindow("GiftSystem", self.nCardId, nil ,"PartnerCard")
end

tbUi.tbOnClick.BtnAdvanced = function (self)

	local bRet, szMsg = PartnerCard:CanCardUpGrade(me, self.nCardId)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	RemoteServer.PartnerCardOnClientCall("CardUpGrade", self.nCardId)
end

tbUi.tbOnClick.BtnHome = function (self)
	local bRet, szMsg
	local bLiveHouse = PartnerCard:IsCardLiveHouse(me, self.nCardId)
	if bLiveHouse then
		bRet, szMsg = PartnerCard:CheckLeaveHouse(me, self.nCardId)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end
		RemoteServer.PartnerCardOnClientCall("LeaveHouse", self.nCardId)
	else
		bRet, szMsg = PartnerCard:CheckLiveHouse(me, self.nCardId)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end
		RemoteServer.PartnerCardOnClientCall("LiveHouse", self.nCardId)
	end
	Client:SetFlag("PartnerCardBtnLive", 0)
	self.pPanel:SetActive("GuideTips", false)
end

function tbUi:OnCardDismiss(nCardId)
	local tbOwnCard = PartnerCard:GetSortOwnPartnerCard()
	if not next(tbOwnCard) then
		Ui:CloseWindow(self.UI_NAME)
	else
		self.tbCard = tbOwnCard
		self.nCardIdx = tbOwnCard[self.nCardIdx] and self.nCardIdx or 1
		self.nCardId =  tbOwnCard[self.nCardIdx] and tbOwnCard[self.nCardIdx].nCardId
		self:Update()
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE, self.Update, self},
		--{ UiNotify.emNOTIFY_PARTNER_CARD_DISMISS_CARD, self.OnCardDismiss, self},
	};

	return tbRegEvent;
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end
