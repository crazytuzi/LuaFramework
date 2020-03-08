
local tbUi = Ui:CreateClass("BgBlackAll");

function tbUi:OnOpen(alpha, nLayer, nEffectId)
	if alpha then
		self.pPanel:UIRect_SetAlpha("Main", alpha)
	end
	if nLayer then
		Ui.UiManager.ChangeUiLayer(self.UI_NAME, nLayer)
	end
	if nEffectId then
		self.pPanel:ShowEffect("texture", nEffectId,0)
	end
	self.nEffectId = nEffectId
end

function tbUi:OnClose()
	self.pPanel:UIRect_SetAlpha("Main",  1)
	Ui.UiManager.ChangeUiLayer(self.UI_NAME, Ui.LAYER_HOME)
	if self.nEffectId then
		self.pPanel:HideEffect("texture")
		self.nEffectId = nil;
	end
end