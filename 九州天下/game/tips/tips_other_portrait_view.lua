TipsOtherPortraitView = TipsOtherPortraitView or BaseClass(BaseView)

function TipsOtherPortraitView:__init()
	self.ui_config = {"uis/views/tips/portraittips", "OtherPortraitTip"}

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
	self.data = nil

	-- 清理变量和对象
	self.portrait_asset = nil
	self.image_obj = nil
	self.raw_image_obj = nil
end

function TipsOtherPortraitView:OpenCallBack()
	self:Flush()
end

function TipsOtherPortraitView:OnClickClose()
	self:Close()
end

function TipsOtherPortraitView:OnFlush(param_t)
	local info = CheckData.Instance:GetRoleInfo()
	AvatarManager.Instance:SetAvatarKey(info.role_id, info.avatar_key_big, info.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(info.role_id)
	if AvatarManager.Instance:isDefaultImg(info.role_id) == 0 or avatar_path_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
		self.image_obj.image:LoadSprite(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(info.role_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(info.role_id, false, callback)
	end
end