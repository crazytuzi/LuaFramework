
local tbUi = Ui:CreateClass("BgBlack");

function tbUi:OnOpen()
	self.pPanel:Wnd_Scale("texture", 1, 1)
end

function tbUi:Scale(fX, fY, fTime)
	self.pPanel:Wnd_Scale("texture", fX, fY, fTime)
end
