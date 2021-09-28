ScreenShotView = ScreenShotView or BaseClass(BaseView)

function ScreenShotView:__init()
	self.ui_config = {"uis/views/screenshotview_prefab","ScreenShotView"}
	self.full_screen = true
	self.play_audio = true
	self.view_layer = UiLayer.PopTop
	self.vew_cache_time = 0
end

function ScreenShotView:__delete()

end

function ScreenShotView:LoadCallBack()
	self.raw_image = self:FindVariable("RawImage")
	self:ListenEvent("OnClickOK",
		BindTool.Bind(self.OnClickOK, self))
	self:ListenEvent("OnClickCancel",
		BindTool.Bind(self.OnClickCancel, self))
	if self.load_callback then
		self.load_callback()
	end
end

function ScreenShotView:ReleaseCallBack()
	self.raw_image = nil
	self.load_callback = nil
end

function ScreenShotView:OpenCallBack()

end

function ScreenShotView:CloseCallBack()

end

function ScreenShotView:OnClickOK()
	self:Close()
end

function ScreenShotView:OnClickCancel()
	if self.path then
		UtilU3d.DeleteFile(self.path)
	end
	self:Close()
end

function ScreenShotView:OnFlush(param)
	for k,v in pairs(param) do
		if k == "all" then
			self.path = v[1]
			self.raw_image:SetValue(self.path)
		end
	end
end

function ScreenShotView:SetLoadCallBack(load_callback)
	self.load_callback = load_callback
end