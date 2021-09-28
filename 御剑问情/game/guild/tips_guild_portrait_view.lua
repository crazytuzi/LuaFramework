TipsGuildPortraitView = TipsGuildPortraitView or BaseClass(BaseView)
TipsGuildPortraitView.HasOpen = false
function TipsGuildPortraitView:__init()
	self.ui_config = {"uis/views/tips/portraittips_prefab", "PortraitTip"}

	self.avatar_path_big = ""
	self.avatar_path_small = ""
	self.uploading_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsGuildPortraitView:LoadCallBack()
	self:ListenEvent("OnClickPhotoAlbum",
		BindTool.Bind(self.OnClickPhotoAlbum, self))
	self:ListenEvent("OnClickCamera",
		BindTool.Bind(self.OnClickCamera, self))
	self:ListenEvent("OnClickDefault",
		BindTool.Bind(self.OnClickDefault, self))
	self:ListenEvent("OnClickSure",
		BindTool.Bind(self.OnClickSure, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))

	self.portrait_asset = self:FindVariable("PortraitAsset")
	self.show_tips = self:FindVariable("ShowTips")
	local title_name = self:FindVariable("TitleName")
	title_name:SetValue(Language.Guild.PortraitTitle)
	local defore_btn_txt = self:FindVariable("DeforeBtnTxt")
	defore_btn_txt:SetValue(Language.Guild.DeforePortraitBtn)

	self.portrait = self:FindObj("Portrait")
	self.portrait_raw = self:FindObj("PortraitRaw")
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		self.portrait_asset:SetAsset(bundle, asset)
	end
end

function TipsGuildPortraitView:ReleaseCallBack()
	self.avatar_path_big = ""
	self.avatar_path_small = ""

	self.portrait_asset = nil
	self.show_tips = nil
	self.portrait = nil
	self.portrait_raw = nil
end

function TipsGuildPortraitView:OpenCallBack()
	self:Flush()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level >= GameEnum.AVTAR_REMINDER_LEVEL then
		TipsGuildPortraitView.HasOpen = true
	end
	RemindManager.Instance:Fire(RemindName.AvatarChange)
	RemindManager.Instance:SetTodayDoFlag(RemindName.GuildHead)
	GlobalEventSystem:Fire(ObjectEventType.GUILD_HEAD_CHANGE)
end

function TipsGuildPortraitView:OnClickPhotoAlbum()
	ImagePicker.PickFromPhoto(256, 32, function(pickPath, scaledPath)
		self:SelectAvatarCallback(pickPath, scaledPath)
	end)
	self.default_ptr_flag = false
end

function TipsGuildPortraitView:OnClickCamera()
	ImagePicker.PickFromCamera(256, 32, function(pickPath, scaledPath)
		self:SelectAvatarCallback(pickPath, scaledPath)
	end)
	self.default_ptr_flag = false
end

function TipsGuildPortraitView:OnClickDefault()
	local vo = GameVoManager.Instance:GetMainRoleVo()
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		self.portrait_asset:SetAsset(bundle, asset)
		self.default_ptr_flag = true
end

function TipsGuildPortraitView:OnClickSure()
	if (self.avatar_path_big == "" or self.avatar_path_small == "") and not self.default_ptr_flag then
		self:Close()
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.default_ptr_flag then
		AvatarManager.Instance:SetAvatarKey(vo.guild_id, 0, 0, true)
		GuildCtrl.Instance:SendSetAvatarTimeStamp(0, 0)
		GlobalEventSystem:Fire(ObjectEventType.GUILD_HEAD_CHANGE)
		self:Close()
		return
	end

	local url_big = AvatarManager.GetGuildFileUrl(vo.role_id, vo.guild_id, true)
	local callback_big = BindTool.Bind(self.UploadCallback, self, self.avatar_path_big, self.avatar_path_small)
	self.uploading_list[url_big] = {url=url_big, path=self.avatar_path_big, callback=callback_big}
	if not HttpClient:Upload(url_big, self.avatar_path_big, callback_big) then
		self:CancelUpload()
		return
	end

	local url_small = AvatarManager.GetGuildFileUrl(vo.role_id, vo.guild_id, false)
	local callback_small = BindTool.Bind(self.UploadCallback, self, self.avatar_path_big, self.avatar_path_small)
	self.uploading_list[url_small] = {url=url_small, path=self.avatar_path_small, callback=callback_small}
	if not HttpClient:Upload(url_small, self.avatar_path_small, callback_small) then
		self:CancelUpload()
		return
	end

	self.uploading_count = 2
	self:Close()
end

function TipsGuildPortraitView:OnClickClose()
	self:Close()
end

-- 上传头像回调
function TipsGuildPortraitView:UploadCallback(avatar_path_big, avatar_path_small, url, path, is_succ, data)
	self.uploading_count = self.uploading_count - 1
	if not is_succ then
		self:CancelUpload()
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadFail)
		return
	end
	if self.uploading_count <= 0 then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		local avatar_key_big = AvatarManager.getFileKey(avatar_path_big)
		local avatar_key_small = AvatarManager.getFileKey(avatar_path_small)
		GuildCtrl.Instance:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
		AvatarManager.Instance:SetAvatarKey(guild_id, avatar_key_big, avatar_key_small, true)
		GlobalEventSystem:Fire(ObjectEventType.GUILD_HEAD_CHANGE)
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadSucc)
	end
end

-- 选择头像回调
function TipsGuildPortraitView:SelectAvatarCallback(pickPath, scaledPath)
	if pickPath == nil or scaledPath == nil or pickPath == "" then
		return
	end
	self.avatar_path_big = pickPath
	self.avatar_path_small = scaledPath
	self.portrait_raw.raw_image:LoadSprite(pickPath, function()
		self.portrait_raw.gameObject:SetActive(true)
		self.portrait.gameObject:SetActive(false)
	end)
end

-- 取消上传
function TipsGuildPortraitView:CancelUpload()
	for k, v in pairs(self.uploading_list) do
		HttpClient:CancelUpload(v.url, v.callback)
	end

	self.uploading_count = 0
	self.uploading_list = {}
end

function TipsGuildPortraitView:OnFlush(param_t)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.portrait.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0)
	self.portrait_raw.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) ~= 0)
	if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		self.portrait_asset:SetAsset(bundle, asset)
	else
		local raw_image = self.portrait_raw.raw_image
		local callback = function (path)
			if nil ~= raw_image and nil ~= raw_image.gameObject and not IsNil(raw_image.gameObject) then
				self.avatar_path_big = path or AvatarManager.GetFilePath(vo.guild_id, true, true)
				raw_image:LoadSprite(self.avatar_path_big, function()
				end)
			end
		end
		AvatarManager.Instance:GetAvatar(vo.guild_id, true, callback, vo.guild_id)

	end
	if vo.is_change_avatar == 0 then
		self.show_tips:SetValue(false)
	else
		self.show_tips:SetValue(false)
	end
end