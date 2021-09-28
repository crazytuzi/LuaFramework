TipsHelpView = TipsHelpView or BaseClass(BaseView)

function TipsHelpView:__init()
	self.ui_config = {"uis/views/tips/helptips_prefab", "HelpTipView"}
	self.des = ""
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.close_callback = nil
end

function TipsHelpView:__delete()
	self.close_callback = nil
end

function TipsHelpView:LoadCallBack()
	self.notice = self:FindVariable("Notice")
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsHelpView:ReleaseCallBack()
	-- 清理变量和对象
	self.notice = nil
end

function TipsHelpView:CloseWindow()
	self:Close()
end

function TipsHelpView:OpenCallBack()
	self:Flush()
end

function TipsHelpView:CloseCallBack()
	if self.close_callback then
		self.close_callback()
	end
end

function TipsHelpView:SetDes(tips_id, close_callback)
	if tonumber(tips_id) ~= nil then
		self.tips_id = tips_id or 1
		self.des = TipsOtherHelpData.Instance:GetTipsTextById(tips_id) or ""
		return
	end
	self.des = tips_id or ""
	self.close_callback = close_callback
end

function TipsHelpView:OnFlush()
	if type(self.des) ~= "string" then
		self.des = ""
	end
	self.notice:SetValue(self.des)
end