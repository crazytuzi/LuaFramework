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
	self.raw_image_res = self:FindVariable("RawImageRes")
	self.show_image = self:FindVariable("ShowImage")
	self.raw_image_obj = self:FindObj("RawImageObj")
	self.image_obj = self:FindObj("ImageObj")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function ChatTeamMemberCell:__delete()
	self.avatar_key = 0
	self.raw_image_obj = nil
	self.image_obj = nil
	self:RemoveDelayTime()
end

function ChatTeamMemberCell:OnClickItem()
	if self.data.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		self.root_node.toggle.isOn = true
		return
	end

	local function colse_call_back()
		if self:IsNil() then
			return
		end
		self.root_node.toggle.isOn = false
	end

	ScoietyCtrl.Instance:ShowOperateList(nil, self.data.name, nil, colse_call_back)
end

function ChatTeamMemberCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ChatTeamMemberCell:LoadCallBack(uid, path)
	if self:IsNil() then
		return
	end

	if uid ~= self.data.role_id then
		self.show_image:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(uid, false)
	end
	self.show_image:SetValue(false)
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self.raw_image_res:SetValue(path)
	end, 0)
end

function ChatTeamMemberCell:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ChatTeamMemberCell:SetIconImage()
	CommonDataManager.SetAvatar(self.data.role_id, self.raw_image_obj, self.image_obj, self.image_res, self.data.sex, self.data.prof, true)
end

function ChatTeamMemberCell:OnFlush()
	if nil == self.data then return end

	self.data = ScoietyData.Instance:GetMemberInfoByRoleId(self.data)

	self.name:SetValue(self.data.name)
	local post_str = self.index == 1 and Language.Society.LeaderDes or Language.Society.MemberDes
	self.post:SetValue(post_str)
	self:SetIconImage()

	if self.data.is_online ~= 0 then
		self.is_online:SetValue(true)
	else
		self.is_online:SetValue(false)
	end
end