local tbUi = Ui:CreateClass("CopyTipPanel");

function tbUi:OnOpenEnd(fnOnTouch)
	self.Bg.pPanel.OnTouchEvent = function ()
		Ui:CloseWindow(self.UI_NAME);
		if fnOnTouch then
			fnOnTouch();
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end