--------------------------------------------------------------------------
-- ChatTeamMemberCell 	队伍成员
--------------------------------------------------------------------------
ChatTeamMemberCell = ChatTeamMemberCell or BaseClass(BaseCell)

function ChatTeamMemberCell:__init()
	self.avatar_key = 0
	self.name = self:FindVariable("Name")
	self.post = self:FindVariable("Post")
	self.is_online = self:FindVariable("is_online")

	self.image_res = self:FindVariable("ImageRes")
	--self.raw_image_res = self:FindVariable("RawImageRes")
	self.show_image = self:FindVariable("ShowImage")

	self.raw_image_obj = self:FindObj("raw_image_obj")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function ChatTeamMemberCell:__delete()
	self.avatar_key = 0
end

function ChatTeamMemberCell:OnClickItem()
	if self.member_info.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		self.root_node.toggle.isOn = true
		return
	end

	local function colse_call_back()
		if self:IsNil() then
			return
		end
		self.root_node.toggle.isOn = false
	end

	ScoietyCtrl.Instance:ShowOperateList(nil, self.member_info.name, nil, colse_call_back)
end

function ChatTeamMemberCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ChatTeamMemberCell:DataCallBack(uid, path)
	if self:IsNil() then
		return
	end

	if self.member_info and uid ~= self.member_info.role_id then
		self.show_image:SetValue(true)
		return
	end

	if path == nil then
		-- path = AvatarManager.GetFilePath(uid, false)
	end
	-- self.show_image:SetValue(false)
	GlobalTimerQuest:AddDelayTimer(function()
		self.raw_image_obj.raw_image:LoadSprite(path, function ()
			self.show_image:SetValue(false)
		end)
	end, 0)
end

function ChatTeamMemberCell:OnFlush()
	if nil == self.data then return end
	self.member_info = ScoietyData.Instance:GetMemberInfoByRoleId(self.data)
	self.name:SetValue(self.member_info.name)
	local post_str = self.index == 1 and Language.Society.LeaderDes or Language.Society.MemberDes
	self.post:SetValue(post_str)

	local avatar_key = AvatarManager.Instance:GetAvatarKey(self.member_info.role_id)
	if avatar_key == 0 then
		self.avatar_key = 0
		local bundle, asset = AvatarManager.GetDefAvatar(self.member_info.prof, false, self.member_info.sex)
		self.show_image:SetValue(true)
		self.image_res:SetAsset(bundle, asset)
	else
		if avatar_key ~= self.avatar_key then
			self.avatar_key = avatar_key
			AvatarManager.Instance:GetAvatar(self.member_info.role_id, false, BindTool.Bind(self.DataCallBack, self, self.member_info.role_id))
		end
	end
	if self.member_info.is_online ~= 0 then
		self.is_online:SetValue(true)
	else
		self.is_online:SetValue(false)
	end
end