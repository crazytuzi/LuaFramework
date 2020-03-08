
local tbUi = Ui:CreateClass("Common");

function tbUi:SetVisible(bVisible)
	self.pPanel:SetActive("Main", bVisible);
end