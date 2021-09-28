WeddingInviteView = WeddingInviteView or BaseClass(BaseView)

local InviteIndex = {
	"guild",
	"friend",
	"world",
}

function WeddingInviteView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingInviteView"}
	self.scroller_data = {}
	self.cell_list = {}
	self.select_page = 0
end

function WeddingInviteView:ReleaseCallBack()
	
end

function WeddingInviteView:LoadCallBack()
	self.tab_guild = self:FindObj("TabGuild")
	self.tab_friend = self:FindObj("TabFriend")
	self.tab_world = self:FindObj("TabWorld")

	self.tab_guild.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, InviteIndex[1]))
	self.tab_friend.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, InviteIndex[2]))
	self.tab_world.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, InviteIndex[3]))

	self:InitScroller()
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("OneKeyInviteClick",BindTool.Bind(self.OneKeyInviteClick, self))	
end

function WeddingInviteView:CloseCallBack()
	self.is_invite_list = {}
	if self.friend_callback ~= nil then
		GlobalEventSystem:UnBind(self.friend_callback)
	end
	if self.guild_callback ~= nil then
		GlobalEventSystem:UnBind(self.guild_callback)
	end
end

function WeddingInviteView:OpenCallBack()
	self.is_invite_list = {}

	self.friend_callback = GlobalEventSystem:Bind(OtherEventType.FRIEND_INFO_CHANGE, BindTool.Bind2(self.Flush, self, "friend"))
	self.guild_callback = GlobalEventSystem:Bind(OtherEventType.GUILD_MEMBER_INFO_CHANGE, BindTool.Bind(self.Flush, self, "guild"))
	self.guild_callback = GlobalEventSystem:Bind(OtherEventType.RANDOM_INFO_CHANGE, BindTool.Bind(self.Flush, self, "world"))

	if self.tab_guild.toggle.isOn then
		self.show_index = InviteIndex[1]
		self:Flush("guild")
	elseif self.tab_friend.toggle.isOn then
		self.show_index = InviteIndex[2]
		self:Flush("friend")
	elseif self.tab_world.toggle.isOn then
		self.show_index = InviteIndex[3]
		-- self:Flush("world")
		ScoietyCtrl.Instance:RandomRoleListReq()
	end
end

function WeddingInviteView:OnToggleChange(index, ison)
	if ison then
		if self.show_index == index then
			return
		end
		self.is_invite_list = {}
		self.show_index = index
		if index == InviteIndex[1] then
			self:Flush("guild")
		elseif index == InviteIndex[2] then
			self:Flush("friend")
		elseif index == InviteIndex[3] then
			-- self:Flush("world")
			ScoietyCtrl.Instance:RandomRoleListReq()
		end
	end
end

function WeddingInviteView:OnFlush(param_t)
	local data = nil
	self.scroller_data = {}
	if param_t.friend then
		data = ScoietyData.Instance:GetFriendInfo()
	elseif param_t.guild then
		data = GuildDataConst.GUILD_MEMBER_LIST.list
	else
		data = ScoietyData.Instance:GetRandomRoleList()
	end
	if data ~= nil then
		local guests = MarriageData.Instance:GetAllGuests()
		local is_first = MarriageData.Instance:GetIsFirstDiamond()
		if is_first then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local lover_id = main_role_vo.lover_uid
			table.insert(guests, lover_id)
		end
		if guests ~= nil and next(guests) ~= nil then
			for k,v in pairs(data) do
				local is_in = false
				for k2,v2 in pairs(guests) do
					local id = v.user_id or v.uid
					if id == v2 then
						is_in = true
						break
					end
				end
				if not is_in then
					if v.is_online == 1 or not v.is_online then
						table.insert(self.scroller_data, v)
					end
				end
			end
		else
			self.scroller_data = data
		end
	end
	self.scroller.scroller:ReloadData(0)
end

function WeddingInviteView:FriendToggleChange(isOn)
	if isOn then
		self.select_page = 0
		ScoietyCtrl.Instance:FriendInfoReq()
	else
		self.select_page = 1
		local guild_id = PlayerData.Instance.role_vo.guild_id
		if guild_id == nil or guild_id == "" or guild_id == 0 then
			print("没有工会")
			self:Flush("guild")
		else
			print("有工会")
			GuildCtrl.Instance:SendAllGuildMemberInfoReq(guild_id)
		end
	end
end

function WeddingInviteView:WorldToggleChange()

end

function WeddingInviteView:OneKeyInviteClick()
	print("一键邀请")
	local invite_type = 0
	if self.tab_guild.toggle.isOn then
		invite_type = GameEnum.HUNYAN_INVITE_TYPE_ALL_FRIEND
	elseif self.tab_friend.toggle.isOn then
		invite_type = GameEnum.HUNYAN_INVITE_TYPE_ALL_GUILD_MEMBER
	elseif self.tab_world.toggle.isOn then
		invite_type = GameEnum.HUNYAN_INVITE_TYPE_ALL_GUILD_MEMBER
	end
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_INVITE, invite_type)
end

function WeddingInviteView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self.scroller_data = {}
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = WedingInviteScrollerCell.New(cell.gameObject)
			self.cell_list[cell].mother_view = self
		end
		local data = self.scroller_data[data_index]
		data.data_index = data_index
		self.cell_list[cell]:SetData(data)
	end
end

function WeddingInviteView:ReleaseCallBack()

end

function WeddingInviteView:ClickClose()
	self:Close()
end

function WeddingInviteView:AddInviteName(name)
	self.is_invite_list[name] = true
end

function WeddingInviteView:GetIsInviteList()
	return self.is_invite_list
end

--滚动条格子-------------------------------------
WedingInviteScrollerCell = WedingInviteScrollerCell or BaseClass(BaseCell)
function WedingInviteScrollerCell:__init()
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.power = self:FindVariable("Power")
	self.is_invite = self:FindVariable("IsInvite")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.raw_image_res = self:FindVariable("RawImageRes")

	self:ListenEvent("InviteClick", BindTool.Bind(self.InviteClick, self))
end

function WedingInviteScrollerCell:__delete()

end

function WedingInviteScrollerCell:OnFlush()
	local id = self.data.user_id or self.data.uid

	CommonDataManager.SetAvatar(id, self.raw_image_obj, self.image_obj, self.image_res, self.data.sex, self.data.prof, false)

	self.name:SetValue(self.data.gamename or self.data.role_name)

	local level = self.data.level
	local capability = self.data.capability
	self.level:SetValue(level)
	self.power:SetValue(capability)
	local is_invite_list = self.mother_view:GetIsInviteList()
	if is_invite_list[self.data.gamename or self.data.role_name] then
		self.is_invite:SetValue(true)
	else
		self.is_invite:SetValue(false)
	end
end

function WedingInviteScrollerCell:InviteClick()
	print("点击了邀请")
	self.mother_view:AddInviteName(self.data.gamename or self.data.role_name)
	self.is_invite:SetValue(true)
	local id = self.data.user_id or self.data.uid
	local invite_type = GameEnum.HUNYAN_INVITE_TYPE_ONE_FRIEND
	if self.mother_view.show_index == InviteIndex[2] then
		invite_type = GameEnum.HUNYAN_INVITE_TYPE_ONE_GUILD_MEMBER
	end
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_INVITE,
		invite_type, id)
end
