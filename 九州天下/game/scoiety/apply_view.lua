ApplyView = ApplyView or BaseClass(BaseView)

function ApplyView:__init()
	self.ui_config = {"uis/views/scoietyview", "ApplyList"}
	self:SetMaskBg(true)
	self.cell_list = {}
	self.open_type = 0
end

function ApplyView:__delete()

end

function ApplyView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	--清除变量
	self.title = nil
	self.name = nil
	self.show_btn_team = nil
	self.show_btn_pet = nil
	self.tab_text = nil
	self.scroller = nil
end

function ApplyView:LoadCallBack()
	self.select_index = 1

	self.title = self:FindVariable("Title")
	self.name = self:FindVariable("Name")
	self.show_btn_team = self:FindVariable("show_btn_team")
	self.show_btn_pet = self:FindVariable("show_btn_pet")
	self.tab_text = self:FindVariable("tab_text")

	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickRefuse",BindTool.Bind(self.ClickOpera, self, 1))
	self:ListenEvent("ClickAgree",BindTool.Bind(self.ClickOpera, self, 0))
	self:ListenEvent("GoPetClick",BindTool.Bind(self.GoPetClick, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("ApplyList")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local apply_cell = self.cell_list[cell]
		if apply_cell == nil then
			apply_cell = ApplyCell.New(cell.gameObject)
			apply_cell.root_node.toggle.group = self.scroller.toggle_group
			apply_cell.apply_view = self
			self.cell_list[cell] = apply_cell
		end

		apply_cell:SetIndex(data_index)
		apply_cell:SetData(self.scroller_data[data_index])
	end
end

function ApplyView:CloseCallBack()
	self.open_type = 0
end

function ApplyView:SetOpenType(open_type)
	self.open_type = open_type
end

function ApplyView:CloseWindow()
	self:Close()
end

function ApplyView:ClickOpera(value)
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	local role_info = {}

	if self.open_type == APPLY_OPEN_TYPE.JOIN then
		role_info = ScoietyData.Instance:GetJoinRoleInfoByIndex(self.select_index)
	elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
		role_info = ScoietyData.Instance:GetFriendApplyInfoByIndex(self.select_index)
	elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
		role_info = ScoietyData.Instance:GetInviteInfoByIndex(self.select_index)
	end

	if next(role_info) then
		self.select_index = 1

		if self.open_type == APPLY_OPEN_TYPE.JOIN then
			ScoietyCtrl.Instance:ReqJoinTeamRet(role_info.req_role_id, value)
			ScoietyData.Instance:RemoveJoinTeamInfoByRoleId(role_info.req_role_id)
			local join_team_info = ScoietyData.Instance:GetReqJoinTeamInfo()
			if next(join_team_info) then
				self:Flush()
			else
				MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.JOIN_REQ, {false})
				self:Close()
			end

		elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
			local param_t = {}
			param_t.req_user_id = role_info.req_user_id
			param_t.req_gamename = role_info.req_gamename
			param_t.is_accept = value == 1 and 0 or 1
			param_t.req_sex = role_info.req_sex
			param_t.req_prof = role_info.req_prof
			ScoietyCtrl.Instance:AddFriendRet(param_t)

			ScoietyData.Instance:RemoveFriendApplyInfoByRoleId(role_info.req_user_id)

			local friend_apply_list = ScoietyData.Instance:GetFriendApplyList()
			if next(friend_apply_list) then
				self:Flush()
			else
				MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Scoiety), MainUIViewChat.IconList.FRIEND_REC, false)
				-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.FRIEND_REC, {false})
				self:Close()
			end

		elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
			ScoietyCtrl.Instance:InviteUserTransmitRet(role_info.inviter, value)

			if value == 1 then
				ScoietyData.Instance:RemoveInviteInfoById(role_info.inviter)
				local friend_apply_list = ScoietyData.Instance:GetFriendApplyList()
				if next(friend_apply_list) then
					self:Flush()
				else
					MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Scoiety), MainUIViewChat.IconList.TEAM_REQ, false)
					-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.TEAM_REQ, {false})
					self:Close()
				end
			else
				ScoietyData.Instance:ClearInviteInfo()
				MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Scoiety), MainUIViewChat.IconList.TEAM_REQ, false)
				-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.TEAM_REQ, {false})
				self:Close()
			end
		end
	end
end

function ApplyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ApplyView:GoPetClick()

	if 0 == #self.scroller_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Pet.NotPetFriend)
		self:Close()
		return
	end
	
	if self.open_type == APPLY_OPEN_TYPE.PET and 0 ~= #self.scroller_data then
		PetData.Instance:SetFriendId(self.scroller_data[self.select_index].user_id)
		PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_FRIEND_PET_LIST, self.scroller_data[self.select_index].user_id, 0, 0)
	end
	self:Close()
end

function ApplyView:GetSelectIndex()
	return self.select_index or 1
end

function ApplyView:OnFlush()
	local data = {}
	local title_name = ""
	local name_str = ""
	self.show_btn_team:SetValue(true)
	self.show_btn_pet:SetValue(false)
	if self.open_type == APPLY_OPEN_TYPE.JOIN then
		title_name = Language.Society.JoinApply
		name_str = Language.Society.NameDes
		self.tab_text:SetValue(Language.Society.PowerDes)
		data = ScoietyData.Instance:GetReqJoinTeamInfo()
	elseif self.open_type == APPLY_OPEN_TYPE.FRIEND then
		title_name = Language.Society.FriendApply
		name_str = Language.Society.NameDes
		self.tab_text:SetValue(Language.Society.PowerDes)
		data = ScoietyData.Instance:GetFriendApplyList()
	elseif self.open_type == APPLY_OPEN_TYPE.TEAM then
		title_name = Language.Society.TeamApply
		name_str = Language.Society.LeaderNameDes
		self.tab_text:SetValue(Language.Society.TeamNumDes)
		data = ScoietyData.Instance:GetInviteInfo()
	elseif self.open_type == APPLY_OPEN_TYPE.PET then
		title_name = Language.Society.SelectPetFriend
		name_str = Language.Society.NameDes
		data = PetData.Instance:GetShowFriendData()
		self.show_btn_team:SetValue(false)
		self.show_btn_pet:SetValue(true)
		self.tab_text:SetValue(Language.Society.PetNumDes)
	end

	self.title:SetValue(title_name)
	self.name:SetValue(name_str)

	self.scroller_data = data
	self.scroller.scroller:ReloadData(0)
end

----------------------------------------------------------------------------
--ApplyCell 		队伍申请滚动条格子
----------------------------------------------------------------------------

ApplyCell = ApplyCell or BaseClass(BaseCell)

function ApplyCell:__init()
	self.apply_view = nil
	
	-- 获取变量
	self.name = self:FindVariable("Name")
	self.lev = self:FindVariable("Lev")
	self.capability = self:FindVariable("Capability")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	-- 监听事件
	self:ListenEvent("ClickItem",BindTool.Bind(self.ClickItem, self))
end

function ApplyCell:__delete()
	self.apply_view = nil
	self.data = nil
end

function ApplyCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.user_id = self.data.req_role_id or self.data.req_user_id or self.data.user_id or self.data.inviter
	-- AvatarManager.Instance:SetAvatarKey(self.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local prof = self.data.req_role_prof or self.data.req_prof or self.data.prof or self.data.inviter_prof
		local sex = self.data.req_role_sex or self.data.req_sex or self.data.sex or self.data.inviter_sex
		local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
		-- self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				if self.data.avatar_key_small == 0 then
					self.image_obj.gameObject:SetActive(true)
					self.raw_image_obj.gameObject:SetActive(false)
					return
				end
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.user_id, false, callback)
	end

	local level = self.data.req_role_level or self.data.req_level or self.data.level or self.data.inviter_level or 0
	local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.lev:SetValue(level_des)
	local camp = Language.RankTogle.StrCamp[self.data.req_role_camp] or Language.RankTogle.StrCamp[self.data.req_camp] or Language.RankTogle.StrCamp[self.data.camp] or Language.RankTogle.StrCamp[self.data.inviter_camp] or ""
	local name = self.data.req_role_name or self.data.req_gamename or self.data.gamename or self.data.inviter_name or ""
	local camp_and_name = camp .. name
	self.name:SetValue(camp_and_name)

	local cap_value = ""
	if self.apply_view.open_type == APPLY_OPEN_TYPE.TEAM then
		cap_value = string.format("%s/%d", self.data.member_num, GameEnum.TEAM_MAX_COUNT)
	else
		cap_value = PetData.Instance:GetPetCountByUserId(self.user_id) or self.data.req_role_capability or self.data.capability or ""
		cap_value = CommonDataManager.ConverMoney(cap_value)
	end
	self.capability:SetValue(cap_value)

	-- 刷新选中特效
	local select_index = self.apply_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ApplyCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.apply_view:SetSelectIndex(self.index)
end