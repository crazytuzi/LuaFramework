InviteView = InviteView or BaseClass(BaseView)
function InviteView:__init()
	self.ui_config = {"uis/views/scoietyview_prefab", "InviteList"}
	self.cell_list = {}
end

function InviteView:__delete()

end

function InviteView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.title = nil
	self.scroller = nil
end

function InviteView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickInvite", BindTool.Bind(self.ClickInvite, self))

	self.title = self:FindVariable("Title")


	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("ListView")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local invite_cell = self.cell_list[cell]
		if invite_cell == nil then
			invite_cell = ScrollerInviteCell.New(cell.gameObject)
			invite_cell.root_node.toggle.group = self.scroller.toggle_group
			invite_cell.invite_view = self
			self.cell_list[cell] = invite_cell
		end

		invite_cell:SetIndex(data_index)
		invite_cell:SetData(self.scroller_data[data_index])
	end
end

function InviteView:OpenCallBack()
	self:ChangeInviteView()
end

function InviteView:ChangeInviteView()
	self.scroller_data = {}
	local invite_type = ScoietyData.Instance:GetInviteType()
	if invite_type == ScoietyData.InviteType.FriendType then
		local friend_info = ScoietyData.Instance:GetIsOnLineFriendInfo()
		self.scroller_data = friend_info
		self.title:SetValue(Language.Society.FriendInviety)
	elseif invite_type == ScoietyData.InviteType.GuildType then
		self.scroller_data = {}
		self.title:SetValue(Language.Society.BanPaiInviety)
	elseif invite_type == ScoietyData.InviteType.WorldType then
		self.scroller_data = {}
		self.title:SetValue(Language.Society.WorldInviety)
	elseif invite_type == ScoietyData.InviteType.NearType then
		local near_info = Scene.Instance:GetRoleList()
		for k, v in pairs(near_info) do
			table.insert(self.scroller_data, v.vo)
		end
		self.title:SetValue(Language.Society.NearInviety)
	end
	self.select_index = nil
	self.scroller.scroller:ReloadData(0)
end

function InviteView:CloseWindow()
	self:Close()
end

function InviteView:CloseCallBack()
	self.select_index = nil
end

function InviteView:ClickInvite()
	if self.select_index == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	ScoietyCtrl.Instance:InviteUserReq(self.role_id)
	--self:Close()
end

function InviteView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function InviteView:GetSelectIndex()
	return self.select_index or 0
end

function InviteView:SetRoleId(id)
	self.role_id = id
end

----------------------------------------------------------------------------
--ScrollerInviteCell 		邀请列表滚动条格子
----------------------------------------------------------------------------

ScrollerInviteCell = ScrollerInviteCell or BaseClass(BaseCell)

function ScrollerInviteCell:__init()
	-- 获取变量
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.prof = self:FindVariable("Prof")
	self.lev = self:FindVariable("Lev")

	--头像UI
	self.image_res = self:FindVariable("ImageRes")
	self.role_image = self:FindObj("RoleImage")
	self.raw_image = self:FindObj("RawImage")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ScrollerInviteCell:__delete()
	self.invite_view = nil
	self.role_image = nil
	self.raw_image = nil
	self.data = nil
end

function ScrollerInviteCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.role_id = self.data.user_id or self.data.role_id
	CommonDataManager.SetAvatar(self.role_id, self.raw_image, self.role_image, self.image_res, self.data.sex, self.data.prof, true)
	local level_des = PlayerData.GetLevelString(self.data.level)
	self.lev:SetValue(level_des)
	self.name:SetValue(self.data.gamename or self.data.name)
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof))

	-- 刷新选中特效
	local select_index = self.invite_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerInviteCell:ClickItem()
	self.invite_view:SetSelectIndex(self.index)
	self.invite_view:SetRoleId(self.role_id)
end