
local tbUi = Ui:CreateClass("FurnitureOptUi");

tbUi.tbPos =
{
	{{0, 48}},
	{{-58, 35}, {58, 35}}
}

function tbUi:OnOpen(nRepId, tbBtnInfo, fnClose, nYOffset)
	local pRep = Ui.Effect.GetObjRepresent(nRepId);
	if not pRep then
		return 0;
	end

	self.tbBtnInfo = tbBtnInfo;

	local tbPosInfo = self.tbPos[#tbBtnInfo];
	for i = 1, #self.tbPos do
		self.pPanel:SetActive("BtnUse" .. i, i <= #tbBtnInfo);
		if i <= #tbBtnInfo then
			self.pPanel:Label_SetText("BtnLabel" .. i, tbBtnInfo[i][1]);
			self.pPanel:ChangePosition("BtnUse" .. i, tbPosInfo[i][1], tbPosInfo[i][2]);
		end
	end

	self.nId = Decoration:GetRepInfoByRepId(nRepId);
	self.pPanel:ObjRep_SetFollow("Main", nRepId);
	pRep:SetUiLogicPos(0, nYOffset or 250, 0);

	self.nRepId = nRepId;
	self.fnClose = fnClose;
end

function tbUi:OnClose()
	self.fnOK = nil;
	if self.fnClose then
		self.fnClose();
		self.fnClose = nil;
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnDeleteDecoration(nId)
	if self.nId and self.nId == nId then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function tbUi:OnDecorationChange(nId)
	if self.nId and self.nId == nId then
		Ui:CloseWindow(self.UI_NAME);
	end
end


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_DELETE_DECORATION, 		self.OnDeleteDecoration };
		{ UiNotify.emNOTIFY_DECORATION_CHANGE, 		self.OnDecorationChange };
	};

	return tbRegEvent;
end


tbUi.tbOnClick = tbUi.tbOnClick or {};

for i = 1, #tbUi.tbPos do
	tbUi.tbOnClick["BtnUse" .. i] = function (self)
		if not self.tbBtnInfo or not self.tbBtnInfo[i] then
			return;
		end

		self.tbBtnInfo[i][2]();
		Ui:CloseWindow(self.UI_NAME);
	end
end
