local tbUi = Ui:CreateClass("LingJueFengLayerPanel");

tbUi.tbShowInfo = {
	["Info"] = {"NumberLayer", "texiao"},
	["Win"] = {"chuangguanchenggong"},
	["Fail"] = {"chaungguanshibai"},
}

function tbUi:OnOpenEnd(szEffect, nDealyTime, nTime, szInfo)
	nTime = nTime or 2;
	nDealyTime = nDealyTime or 0;

	self.szInfo = szInfo;

	if self.nOpenTimerId then
		Timer:Close(self.nOpenTimerId);
		self.nOpenTimerId = nil;
	end

	self.pPanel:SetActive("Main", false);
	Timer:Register(Env.GAME_FPS * nDealyTime + 1, function (self)
		self.pPanel:SetActive("Main", true);
	end, self);

	self.nOpenTimerId = Timer:Register(Env.GAME_FPS * nDealyTime + 2, function (self)
		for _, szChild in pairs(self.tbShowInfo[szEffect]) do
			self.pPanel:SetActive(szChild, true);
		end
		self.nOpenTimerId = nil;

		if self.szInfo then
			self.pPanel:Label_SetText("NumberLayer", self.szInfo);
		end
	end, self)

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	self.nTimerId = Timer:Register(Env.GAME_FPS * (nTime + nDealyTime), function (self)
		Ui:CloseWindow(self.UI_NAME);
		self.nTimerId = nil;
	end, self);
end

function tbUi:OnClose()
	if self.nOpenTimerId then
		Timer:Close(self.nOpenTimerId);
		self.nOpenTimerId = nil;
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	for _, tbInfo in pairs(self.tbShowInfo) do
		for _, szChild in pairs(tbInfo) do
			self.pPanel:SetActive(szChild, false);
		end
	end
	self.szEffect = nil;
end