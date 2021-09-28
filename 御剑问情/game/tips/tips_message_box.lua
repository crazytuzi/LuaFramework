TipsMessageBox = TipsMessageBox or BaseClass(BaseView)

function TipsMessageBox:__init()
	self.ui_config = {"uis/views/tips/commontips_prefab", "MessageBox"}
	self.play_audio = true
	self.view_layer = UiLayer.SceneLoadingPop

	self.ok_callback = nil
end

function TipsMessageBox:LoadCallBack()
	self:ListenEvent("OnClickOkBtn",BindTool.Bind(self.OnClickOkBtn, self))
end

function TipsMessageBox:SetData(message)
	self.message = message
	self:Flush()
end

function TipsMessageBox:SetOkCallback(ok_callback)
	self.ok_callback = ok_callback
end

function TipsMessageBox:OnFlush(param_list)
	self:FindVariable("message"):SetValue(self.message)
end

function TipsMessageBox:OnClickOkBtn()
	self:Close()
	if nil ~= self.ok_callback then
		self.ok_callback()
	end
end