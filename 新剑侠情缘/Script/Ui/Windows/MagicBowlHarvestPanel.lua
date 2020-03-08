local tbUi = Ui:CreateClass("MagicBowlHarvestPanel")

function tbUi:OnOpen(nRepId)
	local pRep = Ui.Effect.GetObjRepresent(nRepId);
	if not pRep then
		return 0;
	end

	self.pPanel:ObjRep_SetFollow("Main", nRepId);
	pRep:SetUiLogicPos(0, 50, 0);

	House:UpdateMagicBowlData(House.dwOwnerId)
	self:Refresh()
end

function tbUi:Refresh()	
	local tbData = House:GetMagicBowlData(House.dwOwnerId)
	if not tbData then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	self.pPanel:SetActive("Tip", false);
	local szState = Furniture.MagicBowl:GetInscriptionState(tbData.nLevel, tbData.tbInscription.nStage, tbData.tbInscription.nDeadline)
	if szState=="finished" then
		self.pPanel:SetActive("Tip", true);
	end
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_MAGICBOWL,	function () self:Refresh() end },
		{ UiNotify.emNOTIFY_MAP_LEAVE,	function () self:OnLeaveMap()  end },
	};
	return tbRegEvent;
end
