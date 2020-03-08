
local tbUi = Ui:CreateClass("HomeScreenTip");
--MapId	Title	Info	ShowTime	DealyTime

function tbUi:LoadSetting()
	tbUi.tbSetting = LoadTabFile("Setting/Map/MapEnterTips.tab", "dssdd", "MapId", {"MapId", "Title", "Info", "ShowTime", "DealyTime"});
end
tbUi:LoadSetting();

function tbUi:OnOpen(szTitle, szInfo, nShowTime)
	self.pPanel:Tween_Play("TipBg", 0);
	self.pPanel:SetActive("TipTitle", true);
	self.pPanel:Label_SetText("TipTitle", szTitle);

	self.pPanel:SetActive("TipDescribe", true);
	self.pPanel:Label_SetText("TipDescribe", szInfo);

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	self.nTimerId = Timer:Register(Env.GAME_FPS * (nShowTime or 2), self.OnTimeout, self);
end

function tbUi:OnTimeout()
	if self.nTimerId then
		self.nTimerId = nil;
	end

	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbUi:OnMapLoaded(nMapTemplateId)
	tbUi.nMapTemplateId = nMapTemplateId;
	local tbSetting = tbUi.tbSetting[nMapTemplateId];
	if not tbSetting then
		return;
	end

	local fnShowTips = function (nMapId)
		if nMapId ~= tbUi.nMapTemplateId then
			return;
		end

		Ui:OpenWindow("HomeScreenTip", tbSetting.Title, tbSetting.Info, tbSetting.ShowTime);
	end

	local nDealyTime = math.floor(tbSetting.DealyTime, 1);
	Timer:Register(Env.GAME_FPS * nDealyTime, fnShowTips, nMapTemplateId);
end
