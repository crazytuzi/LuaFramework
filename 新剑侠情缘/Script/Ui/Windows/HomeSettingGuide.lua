
local tbUi = Ui:CreateClass("HomeSettingGuide");

tbUi.tbStep = {
	"Step1",
	"Step2",
}
function tbUi:OnOpen()
	self.nStep = 0;
	self:DoNextStep();
end

function tbUi:DoNextStep()
	self.nStep = self.nStep or 0;
	self.nStep = self.nStep + 1;

	local bClose = true;
	for i, szUi in pairs(self.tbStep) do
		self.pPanel:SetActive(szUi, self.nStep == i and true or false);
		if self.nStep == i then
			bClose = false;
		end
	end

	if bClose then
		Ui:CloseWindow(self.UI_NAME);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnBackGround = function (self)
	self:DoNextStep();
end
