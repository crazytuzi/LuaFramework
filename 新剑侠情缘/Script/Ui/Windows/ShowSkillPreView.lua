local tbUi = Ui:CreateClass("ShowSkillPreView");

function tbUi:OnOpen()
	self.pPanel:NpcViewSetTextureToCamera("ModelTexture")
	self.pPanel:SetActive("ModelTexture", false)
	self.pPanel:SetActive("BtnPlay", true)
	self.pPanel:UIRect_SetAlpha("Main", 0.2)

	Login:HideAllSkillPreview();
end

function tbUi:OnClose()
	Login:HideAllSkillPreview();
end

function tbUi:OnPlay()
	self.pPanel:SetActive("ModelTexture", true)
	self.pPanel:UIRect_SetAlpha("Main", 1)
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnPlay = function (self)
	Login:ShowSkillPreview()
	self.pPanel:SetActive("BtnPlay", false)
	
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end
