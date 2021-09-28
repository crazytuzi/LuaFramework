FriendListView = FriendListView or BaseClass(BaseView)

function FriendListView:__init()
	self.ui_config = {"uis/views/scoietyview_prefab", "FriendListView"}
	self.cell_list = {}
end

function FriendListView:__delete()

end

function FriendListView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.scroller = nil
end

function FriendListView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("SureBtn",BindTool.Bind(self.SureOnClick, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("FriendList")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local friend_cell = self.cell_list[cell]
		if friend_cell == nil then
			friend_cell = FriendListCell.New(cell.gameObject)
			friend_cell.root_node.toggle.group = self.scroller.toggle_group
			friend_cell.friend_list_view = self
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])
	end
end

function FriendListView:OpenCallBack()
	self:Flush()
end

function FriendListView:CloseWindow()
	self:Close()
end

function FriendListView:CloseCallBack()
	self.select_index = nil
end

function FriendListView:SetCallBack(callback)
	self.callback = callback
end

function FriendListView:SetSex(sex)
	self.sex = sex
end

function FriendListView:SureOnClick()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.SelectAddFriendItemTips)
		return
	end
	self.callback(self.select_friend_info)
	self:Close()
end

function FriendListView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function FriendListView:GetSelectIndex()
	return self.select_index or 0
end

function FriendListView:SetSelectFriend(info)
	self.select_friend_info = info
end

function FriendListView:OnFlush()
	self.scroller_data = {}
	if self.sex then
		self.scroller_data = ScoietyData.Instance:GetFriendInfoBySex(self.sex)
	else
		self.scroller_data = ScoietyData.Instance:GetFriendInfo()
	end
	self.scroller.scroller:ReloadData(0)
end

----------------------------------------------------------------------------
--FriendListCell 		好友滚动条格子
----------------------------------------------------------------------------

FriendListCell = FriendListCell or BaseClass(BaseCell)

function FriendListCell:__init()
	self.avatar_key = 0

	self.friend_list_view = nil

	-- 获取变量
	self.name = self:FindVariable("Name")
	self.prof = self:FindVariable("Prof")
	self.lev = self:FindVariable("Lev")
	self.gray = self:FindVariable("Gray")
	self.imy_lev = self:FindVariable("ImyLev")
	self.intimacy = self:FindVariable("Intimacy")

	--头像UI
	self.image_res = self:FindVariable("ImageRes")
	self.raw_image = self:FindObj("RawImage")
	self.image = self:FindObj("Image")
	-- 监听事件
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function FriendListCell:__delete()
	self.friend_list_view = nil
	self.avatar_key = 0
	self.raw_image = nil
	self.image = nil
end

function FriendListCell:OnFlush()
	if not self.data or not next(self.data) then return end
	CommonDataManager.SetAvatar(self.data.user_id, self.raw_image, self.image, self.image_res, self.data.sex, self.data.prof, true)
	local level_des = PlayerData.GetLevelString(self.data.level)
	self.lev:SetValue(level_des)
	self.name:SetValue(self.data.gamename)
	--self.prof:SetValue(self.data.prof)
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1))

	local intimacy_list = ScoietyData.Instance:GetIntimacyCfg()
	local intimacy_lev = 0
	for k, v in ipairs(intimacy_list) do
		if self.data.intimacy >= v.need_intimacy then
			intimacy_lev = v.level
		end
	end
	self.imy_lev:SetValue(intimacy_lev)
	self.intimacy:SetValue(self.data.intimacy)

	if self.data.is_online ~= 1 then
		self.gray:SetValue(true)
	else
		self.gray:SetValue(false)
	end

	-- 刷新选中特效
	local select_index = self.friend_list_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function FriendListCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.friend_list_view:SetSelectIndex(self.index)
	self.friend_list_view:SetSelectFriend(self.data)
end