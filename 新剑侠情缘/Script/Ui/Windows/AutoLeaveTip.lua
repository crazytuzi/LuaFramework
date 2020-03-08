
local tbUi = Ui:CreateClass("AutoLeaveTip");

function tbUi:OnOpen(nSecend)
	if nSecend <= 0 then
			return 0 
		end
	self.pPanel:Label_SetText("LabelNum", nSecend)
	self.nTimer = Timer:Register(Env.GAME_FPS * 1, function ()
		nSecend = nSecend - 1
		 self.pPanel:Label_SetText("LabelNum", nSecend)
		 if nSecend > 0 then
			 return true
		else
			self.nTimer = nil;
			Ui:CloseWindow(self.UI_NAME)
			return false
	 	end
	end)
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end