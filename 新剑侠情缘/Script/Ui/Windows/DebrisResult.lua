
local tbUi = Ui:CreateClass("DebrisResult");

function tbUi:OnOpen(nItemId)
	self["itemframe"].fnClick = self["itemframe"].DefaultClick
	self["itemframe"]:SetItemByTemplate(nItemId)
	self.pPanel:SetActive("Title", true)
	self.pPanel:Tween_RunWhithStartPos("Title", 0, 150, 0, 203, 0.8)
	self.pPanel:Tween_AlphaWithStart("Title", 0, 1, 0.8)
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnOK()
	Ui:CloseWindow(self.UI_NAME)
end
