--------------------------------------------------------------------------
-- MemberCell 	成员格子
--------------------------------------------------------------------------
MemberCell = MemberCell or BaseClass(BaseCell)

function MemberCell:__init(instance)
	self.avatar_key = 0
	self:IconInit()
end

function MemberCell:__delete()
	self.avatar_key = 0
	self.show_image = nil
end

function MemberCell:IconInit()
	self.name = self:FindVariable("Name")
	self.post = self:FindVariable("Post")
	self.is_online = self:FindVariable("is_online")

	self.image_res = self:FindVariable("ImageRes")
	self.show_image = self:FindVariable("ShowImage")
	self.raw_img_obj = self:FindObj("RawImageObj")
	self.head_frame_res = self:FindVariable("head_frame_res")
	self.show_default_frame = self:FindVariable("show_default_frame")
	self:ListenEvent("ClickItem",BindTool.Bind(self.OnClickItem, self))
end

-- 选择成员
function MemberCell:OnSelectMember()
    if GuildDataConst.GUILD_MEMBER_LIST.list[self.index].uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
        local info = GuildData.Instance:GetGuildMemberInfo()
        if info then
            local detail_type = ScoietyData.DetailType.Default
            if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
                detail_type = ScoietyData.DetailType.GuildTuanZhang
            elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
                detail_type = ScoietyData.DetailType.Guild
            end

			local function canel_callback()
				self.root_node.toggle.isOn = false
			end
            ScoietyCtrl.Instance:ShowOperateList(detail_type, GuildDataConst.GUILD_MEMBER_LIST.list[self.index].role_name, nil, canel_callback)
        end
    end
end

function MemberCell:OnClickItem()
	self:OnSelectMember()
end

function MemberCell:OnFlush()
	if not next(self.data) then return end

	self.name:SetValue(self.data.role_name)
	-- local post_str = GuildData.Instance:GetGuildPostNameByPostId(self.data.post)
	-- 以前是职位，现在用来显示称号

	-- 公会聊天显示称号
	local signin_title_cfg = GuildData.Instance:GetSigninTitleOneCfg(self.data.guild_signin_count or 0)
	local post_str = signin_title_cfg.name or ""
	self.post:SetValue(post_str)
	self:SetIconImage()

	if self.data.is_online ~= 0 then
		self.is_online:SetValue(true)
	else
		self.is_online:SetValue(false)
	end
end

function MemberCell:SetIconImage()
	local role_id = self.data.uid
	local function download_callback(path)
		if nil == self.raw_img_obj or IsNil(self.raw_img_obj.gameObject) then
			return
		end
		if self.data.uid ~= role_id then
			return
		end
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.raw_img_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.uid ~= role_id then
				return
			end
		 	if self.show_image then
				self.show_image:SetValue(false)
			end
		end)
	end
	CommonDataManager.NewSetAvatar(role_id, self.show_image, self.image_res, self.raw_img_obj, self.data.sex, self.data.prof, true, download_callback)
	CommonDataManager.SetAvatarFrame(role_id, self.head_frame_res, self.show_default_frame)
end