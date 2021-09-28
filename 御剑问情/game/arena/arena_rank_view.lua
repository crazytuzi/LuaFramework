ArenaRankView = ArenaRankView or BaseClass(BaseView)

function ArenaRankView:__init()
	self.ui_config = {"uis/views/arena_prefab","ArenaRankView"}
	self.cell_list = {}
	self.cell_list2 = {}
	self.cur_page = 1
	self.max_page = 0
	self.cur_player_info = nil
	self.call_back = BindTool.Bind(self.SetModel, self)
end

function ArenaRankView:LoadCallBack()
	self:ListenEvent("close_click", BindTool.Bind(self.Close, self))
	self:ListenEvent("open_tips", BindTool.Bind(self.OpenArenaRankTips, self))
	self:ListenEvent("fetch_reward", BindTool.Bind(self.FetchArenaRankReward, self))
	self:ListenEvent("next_page", BindTool.Bind2(self.SwitchRankListPage, self, "next"))
	self:ListenEvent("last_page", BindTool.Bind2(self.SwitchRankListPage, self, "last"))
	self:ListenEvent("open_preview", BindTool.Bind2(self.OpenPreview, self, "last"))

	self.page_index = self:FindVariable("page_index")
	self.rank_desc = self:FindVariable("rank_desc")
	self.zhanli_text = self:FindVariable("all_power_text")
	self.name = self:FindVariable("name")
	self.can_get = self:FindVariable("can_get")

	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.list_view.scroller:ReloadData(0)

	self.list_view2 = self:FindObj("list_view2")
	local list_delegate2 = self.list_view2.list_simple_delegate
	list_delegate2.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells2, self)
	list_delegate2.CellRefreshDel = BindTool.Bind(self.RefreshCell2, self)

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("arena_rank_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	-- for i=1,2 do
	-- 	self.item_list[i] = ItemCell.New()
	-- 	self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	-- end
end

function ArenaRankView:__delete()

end

function ArenaRankView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.cell_list2) do
		v:DeleteMe()
	end

	self.cell_list2 = {}

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	-- for i=1,2 do
	-- 	if self.item_list[i] ~= nil then
	-- 		self.item_list[i]:DeleteMe()
	-- 		self.item_list[i] = nil
	-- 	end
	-- end

	self.name = nil
	self.zhanli_text = nil
	self.rank_desc = nil
	self.list_view = nil
	self.list_view2 = nil
	self.display = nil
	self.page_index = nil
	self.cur_page = 1
	self.max_page = 0
	self.cur_player_info = nil
	self.can_get = nil
	if self.role_info then
		self.role_info = nil
	end
end

function ArenaRankView:OpenCallBack()
	ArenaCtrl.Instance:ReqFieldGetRankInfo()
	self:Flush()
end

function ArenaRankView:CloseCallBack()

end

function ArenaRankView:OpenArenaRankTips()
	--TipsCtrl.Instance:ShowOtherHelpTipView(184)
	TipsCtrl.Instance:ShowHelpTipView(184)
end

function ArenaRankView:OpenPreview()
	ArenaCtrl.Instance:OpenRewardPreview()
end

function ArenaRankView:FetchArenaRankReward()
	ArenaCtrl.Instance:ResetGetGuangHuiReward()
end

function ArenaRankView:SwitchRankListPage(key)
	if "next" == key then
		self.cur_page = self.cur_page + 1
	elseif "last" == key then
		self.cur_page = self.cur_page - 1
	end

	self.max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	if self.cur_page < 1 then
		self.cur_page = 1
	elseif self.cur_page > self.max_page then
		self.cur_page = self.max_page
	end
	self:Flush()
	self.list_view.scroller:ReloadData(0)
end

function ArenaRankView:GetNumberOfCells()
	return ArenaData.Instance:GetCurRankItemNumByIndex(self.cur_page)
end

function ArenaRankView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = ArenaRankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
		--the_cell:AddListen(BindTool.Bind(self.OnClickCell, self))
	end
	cell_index = (self.cur_page - 1) * 5 + cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

function ArenaRankView:GetNumberOfCells2()
	local user_info = ArenaData.Instance:GetUserInfo()
	local reward_list = user_info.item_list
	if #reward_list > 0 then
		return #reward_list
	else
		return 3
	end
end

function ArenaRankView:RefreshCell2(cell, cell_index)
	local the_cell = self.cell_list2[cell]
	if the_cell == nil then
		the_cell = ArenaTotalRewardItem.New(cell.gameObject, self)
		self.cell_list2[cell] = the_cell
		--the_cell:AddListen(BindTool.Bind(self.OnClickCell, self))
	end
	cell_index = cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

-- function ArenaRankView:OnClickCell(cell)
-- 	if cell.rank_info == nil then return end
-- 	self.zhanli_text:SetValue(cell.rank_info.capability)
-- end

function ArenaRankView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function ArenaRankView:OnFlush()
	local guanghui_data = ArenaData.Instance:GetRoleGuangHuiData()
	local user_info = ArenaData.Instance:GetUserInfo()
	local max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	self.page_index:SetValue(self.cur_page .. "/" .. max_page)
	self.list_view.scroller:ReloadData(0)
	
	self.can_get:SetValue(ArenaData.Instance:GetIsCanFetchRankReward())
end

function ArenaRankView:SetModel(info)
	if self.model then
		self.model:SetModelResInfo(info)
	end
end

function ArenaRankView:SetListViewCallBack(data)
	self.name:SetValue(data.target_name)
	self.zhanli_text:SetValue(data.capability)
	self:SetModel(data)
end

----------------------------------------------------
ArenaRankCell = ArenaRankCell or BaseClass(BaseCell)

function ArenaRankCell:__init(instance, parent)
	self.parent = parent
	self.rank = 0
	self.is_click = false
	self.show_img_1 = self:FindVariable("show_img_1")
	self.rank_img = self:FindVariable("rank_img")
	self.name_text = self:FindVariable("name_text")
	self.rank_text = self:FindVariable("rank_text")
	self.level_text = self:FindVariable("level_text")
	self.rank_value_text = self:FindVariable("rank_value_text")
	self:ListenEvent("Click", BindTool.Bind(self.ToggleClick, self))
end

function ArenaRankCell:__delete()
	self.parent = nil
end

function ArenaRankCell:SetRank(rank)
	self.rank = rank
end

function ArenaRankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	local rank_data = ArenaData.Instance:GetArenaRankInfo() or {}

	self.rank_info = rank_data[self.rank]
	if self.rank_info == nil then
		self.root_node.gameObject:SetActive(false)
		return
	end

	if self.rank <= 3 then
		self.show_img_1:SetValue(true)
		local bundle, asset = ResPath.GetRankIcon(self.rank)
		self.rank_img:SetAsset(bundle, asset)
	else
		self.rank_text:SetValue(self.rank)
		self.show_img_1:SetValue(false)
	end

	if self.rank_info then
		self.level_text:PlayerData.GetLevelString(self.rank_info.role_level)
		self.name_text:SetValue(self.rank_info.target_name)
		self.rank_value_text:SetValue(self.rank_info.capability)
		self.rank_text:SetValue(self.rank)
		if not self.is_click then
			self.parent:SetListViewCallBack(rank_data[1])
		end
	end
end

function ArenaRankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ArenaRankCell:ToggleClick(is_click)
	self.is_click = true
	if is_click then
		if self.rank_info == nil  then return end
		self.parent:SetListViewCallBack(self.rank_info)
		-- if self.handler then
		-- 	self.handler(self)
		-- end
	end
end

ArenaTotalRewardItem = ArenaTotalRewardItem or BaseClass(BaseCell)

function ArenaTotalRewardItem:__init()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	self.default_reward = {cfg.reward_item1, cfg.reward_item2, cfg.reward_item3}
	self.rank = 0
	self.item_cell_list = ItemCell.New()
	self.item_cell_list:SetInstanceParent(self:FindObj("ItemCell"))
end

function ArenaTotalRewardItem:__delete()
	if self.item_cell_list then
		self.item_cell_list:DeleteMe()
		self.item_cell_list = nil
	end
	self.default_reward = {}
end

function ArenaTotalRewardItem:SetRank(rank)
	self.rank = rank
end

function ArenaTotalRewardItem:OnFlush()
	local user_info = ArenaData.Instance:GetUserInfo()
	local reward_list = user_info.item_list
	local has_item = ArenaData.Instance:GetUserInfoHasItem()
	if has_item then
		if reward_list then
			self.item_cell_list:SetParentActive(false)
			local data = reward_list[self.rank]
			if data and 0 ~= data.item_id then
				self.item_cell_list:SetData(data)
				self.item_cell_list:SetParentActive(true)
			end
		end
	else
		self.item_cell_list:SetParentActive(true)
		self.item_cell_list:SetData(self.default_reward[self.rank])
	end
end