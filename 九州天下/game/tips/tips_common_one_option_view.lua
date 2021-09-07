TipsCommonOneOptionView = TipsCommonOneOptionView or BaseClass(BaseView)

function TipsCommonOneOptionView:__init()
	self.ui_config = {"uis/views/tips/commononeoptiontips", "CommonOneOptionTips"}
	self.view_layer = UiLayer.Pop

	self.default_btton_text = "接受"
	self.play_audio = true
end

function TipsCommonOneOptionView:LoadCallBack()
	self:ListenEvent("CloseView",BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ButtonClick",BindTool.Bind(self.ButtonClick, self))
	self.tips_details = self:FindVariable("TipsDetails")
	self.btton_text = self:FindVariable("ButtonText")
end

function TipsCommonOneOptionView:ShowView(describe, click_func, button_text)
	self.details_value = describe
	self.button_text_value = button_text or self.default_btton_text
	self.click_func = click_func
	self:Open()
end

function TipsCommonOneOptionView:OpenCallBack()
	self.tips_details:SetValue(self.details_value)
	self.btton_text:SetValue(self.button_text_value)
end

function TipsCommonOneOptionView:ButtonClick()
	if self.click_func ~= nil then
		self.click_func()
	end
	self:Close()
end

function TipsCommonOneOptionView:CloseView()
	self:Close()
end
