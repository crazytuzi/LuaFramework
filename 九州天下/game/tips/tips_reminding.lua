TipsReminding = TipsReminding or BaseClass(BaseView)

function TipsReminding:__init()
	self.ui_config = {"uis/views/tips/remindingtips", "RemindingTips"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

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

function TipsReminding:ClickClose()
	self:Close()
end

function TipsReminding:SetNotice(notice)
	self.notice = notice or ""
	self:Flush()
end

function TipsReminding:OnFlush()
	self.str:SetValue(self.notice)
end