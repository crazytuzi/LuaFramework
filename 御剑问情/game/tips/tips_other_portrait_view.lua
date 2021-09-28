TipsOtherPortraitView = TipsOtherPortraitView or BaseClass(BaseView)

function TipsOtherPortraitView:__init()
	self.ui_config = {"uis/views/tips/portraittips_prefab", "OtherPortraitTip"}

	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsOtherPortraitView:LoadCallBack()
	self.portrait_asset = self:FindVariable("PortraitAsset")

	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")

	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
end

function TipsOtherPortraitView:ReleaseCallBack()
	-- 清理变量和对象
	self.portrait_asset = nil
	self.image_obj = nil
	self.raw_image_obj = nil
end

function TipsOtherPortraitView:SetData(data)
	self.data = data
end

function TipsOtherPortraitView:OpenCallBack()
	self:Flush()
end

function TipsOtherPortraitView:OnClickClose()
	self:Close()
end

function TipsOtherPortraitView:OnFlush()
	if self.data == nil then
		return
	end
	CommonDataManager.SetAvatar(self.data.role_id, self.raw_image_obj, self.image_obj, self.portrait_asset, self.data.sex, self.data.prof, true)
end