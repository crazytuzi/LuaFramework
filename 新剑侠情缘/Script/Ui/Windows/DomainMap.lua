local tbUi = Ui:CreateClass("DomainMap");

function tbUi:OnOpen()
	DomainBattle:UpdateDomainBattleInfo()
	self:RefreshUi()
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_ONSYNC_DOMAIN_BASE,   self.RefreshUi, self },

	};

	return tbRegEvent;
end

function tbUi:RefreshUi()
	self.DomainBattleMain:UpdateCity();
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end