TipsCommonWarmView = TipsCommonWarmView or BaseClass(BaseView)

function TipsCommonWarmView:__init()
	self.ui_config = {"uis/views/tips/commontips", "CommonWarmTips"}
	self.open_view = nil
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.content_des = ""
end

function TipsCommonWarmView:LoadCallBack()
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))

	self.tip_text = self:FindVariable("Content")
end

function TipsCommonWarmView:OpenCallBack()
	self:Flush()
end

function TipsCommonWarmView:ReleaseCallBack()
end

function TipsCommonWarmView:__delete()
end

function TipsCommonWarmView:OnClickClose()
	self:Close()
end

function TipsCommonWarmView:SetDes(des)
	self.content_des = des or ""
end

function TipsCommonWarmView:OnFlush(param_list)
	self.tip_text:SetValue(self.content_des)
end