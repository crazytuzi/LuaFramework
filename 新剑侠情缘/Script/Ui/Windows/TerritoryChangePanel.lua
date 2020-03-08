local tbUi = Ui:CreateClass("TerritoryChangePanel");

function tbUi:OnOpen()
	local nCampIndex, _ = DomainBattle.tbCross:GetKingCampInfo()
	for nIndex=1,8 do
		self.pPanel:Button_SetState("Btn"..nIndex, (nCampIndex==nIndex and 2) or 0)
	end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

for nIndex=1,8 do
	tbUi.tbOnClick["Btn"..nIndex] = function (self)
		RemoteServer.CrossDomainChangeKingCampReq(nIndex)
		Ui:CloseWindow(self.UI_NAME);
	end
end
