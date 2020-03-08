local tbUi = Ui:CreateClass("CardPickingResult");

tbUi.bClose = false;


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CARD_PICKING, self.OnDataUpdate },
	};
	return tbRegEvent;
end

function tbUi:OnDataUpdate()
	self.nWaitingCount = 0;
end

function tbUi:OnOpenEnd(szPickingType)
	for i = 0, 10 do
		self["Item" .. i].pPanel:PlayUiAnimation("TurnoverCardReset", false, false, {tostring(self["Item" .. i].pPanel)});
	end

	tbUi.bClose = false;
	self.szPickingType = szPickingType;
	self.nFlopCount = 0;
	self.pPanel:SetActive("CardGroup", false);
	self.pPanel:SetActive("BtnFinish", false);
	self.pPanel:SetActive("framebg", false);
	Ui:GetClass("CompanionShow").tbShowPartnerCard = {}
	self.nWaitingCount = 0;
	self.nWaitingTimer = Timer:Register(Env.GAME_FPS, function ()
		self.nWaitingCount = self.nWaitingCount + 1;
		if self.nWaitingCount > 7 then
			self.pPanel:SetActive("framebg", true);
			self.pPanel:SetActive("BtnFinish", true);
			UiNotify.OnNotify(UiNotify.emNOTIFY_CARD_PICKING);
		end

		local tbResults = CardPicker:GetResultCache();
		if tbResults then
			self.pPanel:SetActive("framebg", true);
			self.nWaitingTimer = nil;
			self:ShowResults(tbResults);
			return false;
		else
			return true;
		end
	end)
end

function tbUi:OnClose()
	if self.nTimer then
        Timer:Close(self.nTimer);
        self.nTimer = nil;
    end

	if self.nWaitingTimer then
		Timer:Close(self.nWaitingTimer);
		self.nWaitingTimer = nil;
	end
end

function tbUi:ShowResults(tbResults)
	self.pPanel:SetActive("CardGroup", true);

	local tbNewCompnions = Lib:CopyTB1(Ui:GetClass("CompanionShow").tbShowCompanion);
	for _, tbItem in ipairs(tbResults) do
		if tbItem.szItemType == "Partner" then
			for nIth, nPartnerId in ipairs(tbNewCompnions) do
				local pPartner = me.GetPartnerObj(nPartnerId);
				if pPartner and pPartner.nTemplateId == tbItem.nItemId then
					tbItem.nPartnerId = nPartnerId;
					table.remove(tbNewCompnions, nIth);
					break;
				end
			end
		end

		local nShowLevel = Partner.tbDes2QualityLevel.A;
		if CardPicker:IsItemFlop(tbItem.szItemType, tbItem.nItemId, nShowLevel) then
			self.nFlopCount = self.nFlopCount + 1;
			if tbItem.szItemType == "PartnerCard" then
				table.insert(Ui:GetClass("CompanionShow").tbShowPartnerCard, tbItem.nItemId)
			end
		end
	end

	for i = 0, 10 do
		self.pPanel:SetActive("Item" .. i, false);
	end

	if #tbResults == 1 then
		self:Show1Result(tbResults);
	else
		self:Show10Result(tbResults);
	end
end

function tbUi:Show1Result(tbResults)
	local tbItem = tbResults[1];
	self.pPanel:SetActive("Item0", true);
	self.Item0.pPanel:PlayUiAnimation("ChouKaChuangKouDongHua", false, false, {tostring(self.Item0.pPanel)});
	self.Item0:Init(tbItem.szItemType, tbItem.nItemId, function ()
		self.nFlopCount = self.nFlopCount - 1;
	end, Partner.tbDes2QualityLevel.A, tbItem.nPartnerId);

	self.pPanel:SetActive("BtnFinish", true);
end

function tbUi:Show10Result(tbResults)
	local fnCallback = function ()
			self.nFlopCount = self.nFlopCount - 1;
		end

	for nIth, tbItem in ipairs(tbResults) do
		Timer:Register(nIth * 5 - 4, function ()
			self.pPanel:SetActive("Item" .. nIth, true);
			self["Item" .. nIth].pPanel:PlayUiAnimation("ChouKaChuangKouDongHua", false, false, {tostring(self["Item" .. nIth].pPanel)});
			local bRet = pcall(self["Item" .. nIth].Init, self["Item" .. nIth], tbItem.szItemType, tbItem.nItemId, fnCallback, Partner.tbDes2QualityLevel.A, tbItem.nPartnerId, tbItem.nCount);
			if (not bRet) then
				print(debug.traceback());
			end
		end)
	end

	Timer:Register(Env.GAME_FPS * 5, function ()
		self.pPanel:SetActive("BtnFinish", true);
	end)
end

function tbUi:FlopAll()
	local tbNewCompnions = {};
	for i = 0, 10 do
		local itemObj = self["Item" .. i];
		if itemObj.IsItemFlop then
			for nKey, nId in pairs(Ui:GetClass("CompanionShow").tbShowCompanion) do
				local pPartner = me.GetPartnerObj(nId);
				if pPartner and pPartner.nTemplateId == itemObj.nPartnerTemplateId then
					table.insert(tbNewCompnions, nId);
					break;
				end
			end
		end
	end
	-- 优先同伴，次而门客
	Ui:GetClass("CompanionShow").tbShowCompanion = tbNewCompnions;
	if next(tbNewCompnions) then
		Ui:OpenWindow("CompanionShow", tbNewCompnions[1], 0);
	elseif next(Ui:GetClass("CompanionShow").tbShowPartnerCard) then
		Ui:OpenWindow("CompanionShow", nil, 4, Ui:GetClass("CompanionShow").tbShowPartnerCard[1]);
	end

	for i = 0, 10 do
		local itemObj = self["Item" .. i];
		itemObj.tbOnClick.CardBack(itemObj, "FlopAll");
	end
end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnFinish()
	tbUi.bClose = true;
	if self.nFlopCount ~= 0 then
		self.pPanel:SetActive("BtnFinish", false);
		self:FlopAll();
		self.nTimer = Timer:Register(Env.GAME_FPS * 3, function ()
			Ui:CloseWindow("CardPickingResult");
			self.nTimer = nil;
		end)
		return;
	end
	Ui:GetClass("CompanionShow").tbShowCompanion = {};
	Ui:GetClass("CompanionShow").tbShowPartnerCard = {};
	Ui:CloseWindow("CardPickingResult");
end
