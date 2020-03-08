
local tbUi = Ui:CreateClass("NpcStrip");

function tbUi:OnOpenEnd(szTips, nTime)
	self:Update(szTips, nTime);
end

function tbUi:Update(szTips, nTime)
	if szTips then
		self.pPanel:Label_SetText("Tips", szTips);
	end

	self.pPanel:Tween_ProgressBarWhithCallback("Slider", 0, 1.0, nTime / Env.GAME_FPS, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi:OnClose()
end
