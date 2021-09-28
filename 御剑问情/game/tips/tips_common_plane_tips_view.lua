TipsCommonPlaneTipsView = TipsCommonPlaneTipsView or BaseClass(BaseView)

function TipsCommonPlaneTipsView:__init()
	self.ui_config = {"uis/views/tips/commonplanetips_prefab", "CommonPlaneTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsCommonPlaneTipsView:LoadCallBack()
	self:ListenEvent("CloseView",BindTool.Bind(self.CloseView, self))
	self.tips_details = self:FindVariable("TipsDetails")
end

function TipsCommonPlaneTipsView:ShowView(describe)
	self.details_value = describe
	self:Open()
end

function TipsCommonPlaneTipsView:OpenCallBack()
	self.tips_details:SetValue(self.details_value)
end

function TipsCommonPlaneTipsView:CloseView()
	self:Close()
end
