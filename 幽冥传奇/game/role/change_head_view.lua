ChangeHeadView = ChangeHeadView or BaseClass(XuiBaseView)

function ChangeHeadView:__init()
	self.is_modal = true
	self.texture_path_list[1] = 'res/xui/role.png'
	self.config_tab = {
		{"role_ui_cfg", 10, {0}},
	}

	self.avatar_path_big = ""
	self.avatar_path_small = ""
	self.uploading_count = 0
	self.uploading_list = {}
	self.default_ptr_flag = false
end

function ChangeHeadView:__delete()
	
end

function ChangeHeadView:LoadCallBack()
	self.node_t_list.img_head.node:setScale(0.92)

	self.node_t_list.btn_album.node:addClickEventListener(BindTool.Bind1(self.OnAlbumGetHanlder, self))
	self.node_t_list.btn_photo.node:addClickEventListener(BindTool.Bind1(self.OnPhotoGetHanlder, self))
	self.node_t_list.btn_enter.node:addClickEventListener(BindTool.Bind1(self.OnAnterUploadingHandler, self))
	self.node_t_list.btn_close_window.node:addClickEventListener(BindTool.Bind1(self.Close, self))
	self.node_t_list.btn_default_avatar.node:addClickEventListener(BindTool.Bind1(self.OnDefaultAvatarHandler, self))
end

function ChangeHeadView:OpenCallBack()
	
end

function ChangeHeadView:ShowIndexCallBack(index)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:UpdateAvatarImg(self.node_t_list.img_head.node, vo.role_id, vo.prof, true)
	XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, false)
	self:Flush()
end

function ChangeHeadView:CloseCallBack()
	self:CancelUpload()
end

function ChangeHeadView:ReleaseCallBack()
	if nil ~= self.node_t_list.img_head then
		AvatarManager.Instance:CancelUpdateAvatar(self.node_t_list.img_head.node)
	end
end

function ChangeHeadView:OnFlush()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.avatar_key_big ~= 0 and vo.avatar_key_small ~= 0 then
		XUI.SetButtonEnabled(self.node_t_list.btn_default_avatar.node, true)
	else
		XUI.SetButtonEnabled(self.node_t_list.btn_default_avatar.node, false)
	end
end

-- 从相册中选择图片
function ChangeHeadView:OnAlbumGetHanlder()
	if self.uploading_count > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploading)
		return
	end
	PlatformAdapter.OpenPhoto(BindTool.Bind1(self.SelectAvatarCallback, self))
end

-- 拍照获取图片
function ChangeHeadView:OnPhotoGetHanlder()
	if self.uploading_count > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploading)
		return
	end
	PlatformAdapter.OpenCamera(BindTool.Bind1(self.SelectAvatarCallback, self))
end

-- 选择头像回调
function ChangeHeadView:SelectAvatarCallback(path)
	self.avatar_path_big = path .. "avatar_big.jpg"
	self.avatar_path_small = path .. "avatar_small.jpg"

	cc.Director:getInstance():getTextureCache():reloadTexture(self.avatar_path_big)
	self.node_t_list.img_head.node:loadTexture(self.avatar_path_big)

	XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, true)

	self.default_ptr_flag = false
end

--点击设回默认头像
function ChangeHeadView:OnDefaultAvatarHandler()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_t_list.img_head.node:loadTexture(ResPath.GetBigPainting("head_" .. vo.prof))

	if vo.avatar_key_big == 0 and vo.avatar_key_small == 0 then
		return
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, true)
	self.default_ptr_flag = true
end

--确认设置回默认头像
function ChangeHeadView:ResetToDefaultAvatar()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:SetAvatarKey(vo.role_id, 0, 0)
	AvatarManager.Instance:UpdateAvatarImg(self.node_t_list.img_head.node, vo.role_id, vo.prof, true)
	RoleCtrl.SendSetAvatarTimeStamp(0, 0)
	RoleData.Instance:SetMainRoleVoValue("avatar_key_big", 0)
	RoleData.Instance:SetMainRoleVoValue("avatar_key_small", 0)
	XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, false)
	self:Flush()
end

-- 确定上传图片
function ChangeHeadView:OnAnterUploadingHandler()
	if self.default_ptr_flag then
		self:ResetToDefaultAvatar()
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()

	local url_big = AvatarManager.GetFileUrl(vo.role_id, true)
	local callback_big = BindTool.Bind1(self.UploadCallback, self)
	self.uploading_list[url_big] = {url=url_big, path=self.avatar_path_big, callback=callback_big}
	if not HttpClient:Upload(url_big, self.avatar_path_big, callback_big) then
		self:CancelUpload()
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadFail)
		return
	end

	local url_small = AvatarManager.GetFileUrl(vo.role_id, false)
	local callback_small = BindTool.Bind1(self.UploadCallback, self)
	self.uploading_list[url_small] = {url=url_small, path=self.avatar_path_small, callback=callback_small}
	if not HttpClient:Upload(url_small, self.avatar_path_small, callback_small) then
		self:CancelUpload()
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadFail)
		return
	end

	self.uploading_count = 2
	XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, false)
end

-- 上传回调
function ChangeHeadView:UploadCallback(url, path, size)
	self.uploading_count = self.uploading_count - 1
	self.uploading_list[url] = nil

	if size < 0 then
		self:CancelUpload()
		XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, true)
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadFail)
		return
	end

	if self.uploading_count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.AvatarUploadSucc)

		local avatar_key_big = AvatarManager.getFileKey(self.avatar_path_big)
		local avatar_key_small = AvatarManager.getFileKey(self.avatar_path_small)
		RoleCtrl.SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)

		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local mv_big_ret = PlatformAdapter.MoveFile(self.avatar_path_big, AvatarManager.GetFilePath(role_id, true))
		local mv_small_ret = PlatformAdapter.MoveFile(self.avatar_path_small, AvatarManager.GetFilePath(role_id, false))
		if not mv_big_ret or not mv_small_ret then
			ErrorLog("Move file fail:big, small ", mv_big_ret, mv_small_ret)
			return
		end

		AvatarManager.Instance:SetAvatarKey(role_id, avatar_key_big, avatar_key_small)
		RoleData.Instance:SetMainRoleVoValue("avatar_key_big", avatar_key_big)
		RoleData.Instance:SetMainRoleVoValue("avatar_key_small", avatar_key_small)
	end
	self:Flush()
end

-- 取消上传
function ChangeHeadView:CancelUpload()
	for k, v in pairs(self.uploading_list) do
		HttpClient:CancelUpload(v.url, v.callback)
	end

	self.uploading_count = 0
	self.uploading_list = {}
end
