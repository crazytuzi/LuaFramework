TipsCommonTwoOptionView = TipsCommonTwoOptionView or BaseClass(BaseView)

function TipsCommonTwoOptionView:__init()
	self.ui_config = {"uis/views/tips/commontwooptiontips", "CommonTwoOptionTips"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.default_yes = Language.Common.Confirm
	self.default_no = Language.Common.Cancel
	self.play_audio = true
end

function TipsCommonTwoOptionView:LoadCallBack()
	self:ListenEvent("CloseView",BindTool.Bind(self.CloseView, self))
	self:ListenEvent("YesClick",BindTool.Bind(self.YesClick, self))
	self:ListenEvent("NoClick",BindTool.Bind(self.NoClick, self))
	self.tips_details = self:FindVariable("TipsDetails")
	self.yes_btton_text = self:FindVariable("YesText")
	self.no_btton_text = self:FindVariable("NoText")
end

function TipsCommonTwoOptionView:ShowView(describe, yes_func, no_func, yes_button_text, no_button_text)
	self.details_value = describe
	self.yes_value = yes_button_text or self.default_yes
	self.no_value = no_button_text or self.default_no
	self.yes_func = yes_func
	self.no_func = no_func
	self:Open()
end

function TipsCommonTwoOptionView:OpenCallBack()
	self.tips_details:SetValue(self.details_value)
	self.yes_btton_text:SetValue(self.yes_value)
	self.no_btton_text:SetValue(self.no_value)
end

function TipsCommonTwoOptionView:YesClick()
	if self.yes_func ~= nil then
		self.yes_func()
	end
	self:Close()
end

function TipsCommonTwoOptionView:NoClick()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipsCommonTwoOptionView:CloseView()
	self:Close()
end
