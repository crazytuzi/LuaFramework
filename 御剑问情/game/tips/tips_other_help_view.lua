TipsOtherHelpView = TipsOtherHelpView or BaseClass(BaseView)

function TipsOtherHelpView:__init()
	self.ui_config = {"uis/views/tips/helptips_prefab", "OtherHelpTipView"}

	self.des = ""
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsOtherHelpView:__delete()

end

function TipsOtherHelpView:LoadCallBack()
	self.str = self:FindVariable("Str")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsOtherHelpView:ReleaseCallBack()
	-- 清理变量和对象
	self.str = nil
end

function TipsOtherHelpView:CloseWindow()
	self:Close()
end

function TipsOtherHelpView:OpenCallBack()
	self:Flush()
end

function TipsOtherHelpView:SetDes(id)
	self.id = id or 1
	self.des = TipsOtherHelpData.Instance:GetTipsTextById(id)
end

function TipsOtherHelpView:OnFlush()
	if type(self.des) ~= "string" then
		self.des = ""
	end
	print("self.des====", self.des)
	self.str:SetValue(self.des)
end