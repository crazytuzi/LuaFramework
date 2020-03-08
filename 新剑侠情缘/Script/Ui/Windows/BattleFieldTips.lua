
local tbUi = Ui:CreateClass("BattleFieldTips");

local DURA_TIME = 3; --提示信息固定3s

function tbUi:OnOpen(szMsg)
	self.pPanel:Label_SetText("NegativeInformation", szMsg)

	if self.nTimer then
		Timer:Close(self.nTimer)
	end
	self.nTimer = Timer:Register(Env.GAME_FPS * DURA_TIME, function ()
		Ui:CloseWindow(self.UI_NAME)
		self.nTimer = nil;
	end)
end
