TipsReminding = TipsReminding or BaseClass(BaseView)

function TipsReminding:__init()
	self.ui_config = {"uis/views/tips/remindingtips_prefab", "RemindingTips"}
	self.view_layer = UiLayer.Pop

	self.notice = ""
	self.play_audio = true
end

function TipsReminding:__delete()

end

function TipsReminding:ReleaseCallBack()
	self.str = nil
end

function TipsReminding:LoadCallBack()
	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self.str = self:FindVariable("Str")
end

function TipsReminding:CloseCallBack()
	if self.callback then
		self.callback()
	end
end

function TipsReminding:ClickClose()
	self:Close()
end

function TipsReminding:SetNotice(notice, callback)
	self.notice = notice or ""
	self.callback = callback
	self:Flush()
end

function TipsReminding:OnFlush()
	self.str:SetValue(self.notice)
end