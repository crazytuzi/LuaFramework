ArenaRewardView = ArenaRewardView or BaseClass(BaseRender)
local RANK = {
	ONE = 1,
	TWO = 2,
	THREE = 3,
	TEN = 10,
}
local MAX_CELL = 5
function ArenaRewardView:__init()
	self.cell_list = {}
	self.cell_list2 = {}
	self.cur_page = 1
	self.max_page = 3
	self.call_back = BindTool.Bind(self.SetModel, self)
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
	self.show_rank = self:FindVariable("show_rank")
	self.show_title = self:FindVariable("show_title")
	self.show_wing = self:FindVariable("show_wing")
	self.show_item = self:FindVariable("show_item")
	self.zhanli = self:FindVariable("zhan_li")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("item"))
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
	local other_cfg = ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local item_id = other_cfg.first_wing_id
	local res_id = 0
	for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
		if v.item_id == item_id then
			res_id = v.res_id
			break
		end
	end
	self.model:SetMainAsset(ResPath.GetWingModel(res_id))
	self.model:SetTrigger("action")
	self.title_root = self:FindObj("title_root")

	self:SetModel(ArenaData.Instance:GetArenaRankInfo()[RANK.ONE])

	-- for i=1,2 do
	-- 	self.item_list[i] = ItemCell.New()
	-- 	self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	-- end
end

function ArenaRewardView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.cell_list2) do
		v:DeleteMe()
	end

	self.cell_list2 = {}

	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function ArenaRewardView:OpenCallBack()
	ArenaCtrl.Instance:ReqFieldGetRankInfo()
	self:Flush()
end

function ArenaRewardView:OpenArenaRankTips()
	--TipsCtrl.Instance:ShowOtherHelpTipView(184)
	TipsCtrl.Instance:ShowHelpTipView(184)
end

function ArenaRewardView:OpenPreview()
	ArenaCtrl.Instance:OpenRewardPreview()
end

function ArenaRewardView:FetchArenaRankReward()
	ArenaCtrl.Instance:ResetGetGuangHuiReward()
end

function ArenaRewardView:SwitchRankListPage(key)
	if "next" == key then
		self.cur_page = self.cur_page + 1
	elseif "last" == key then
		self.cur_page = self.cur_page - 1
	end

	-- self.max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	self.max_page = 3
	if self.cur_page < 1 then
		self.cur_page = 1
	elseif self.cur_page > self.max_page then
		self.cur_page = self.max_page
	end
	self:Flush()
	-- self.list_view.scroller:ReloadData(0)
end

function ArenaRewardView:GetNumberOfCells()
	if self.cur_page * MAX_CELL > 10 then							--只显示前10名
		return 5
	end
	return ArenaData.Instance:GetCurRankItemNumByIndex(self.cur_page)
end

function ArenaRewardView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = ArenaRankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
		--the_cell:AddListen(BindTool.Bind(self.OnClickCell, self))
	end
	cell_index = (self.cur_page - 1) * MAX_CELL + cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

function ArenaRewardView:GetNumberOfCells2()
	-- local user_info = ArenaData.Instance:GetUserInfo()
	-- local reward_list = user_info.item_list
	-- if #reward_list > 0 then
	-- 	return #reward_list + 1
	-- else
		return 1
	-- end
end

function ArenaRewardView:RefreshCell2(cell, cell_index)
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

-- function ArenaRewardView:OnClickCell(cell)
-- 	if cell.rank_info == nil then return end
-- 	self.zhanli_text:SetValue(cell.rank_info.capability)
-- end

function ArenaRewardView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function ArenaRewardView:OnFlush()
	local guanghui_data = ArenaData.Instance:GetRoleGuangHuiData()
	local user_info = ArenaData.Instance:GetUserInfo()
	-- local max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	if user_info then
		self.page_index:SetValue(self.cur_page .. "/" .. self.max_page)
		self.rank_desc:SetValue(user_info.rank)
		self.can_get:SetValue(ArenaData.Instance:GetIsCanFetchRankReward() or user_info.reward_guanghui > 0)
	end
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function ArenaRewardView:SetModel(info)
	-- print_error(info)
	-- local bundle, asset = ResPath.GetWingModel(info)
	local other_cfg = ArenaData.Instance:GetOtherConfig()
	local title = TitleData.Instance:GetArenaCfg()
	local cfg = ArenaData.Instance:GetRankRewardData()
	local zhanli = 0
	self.show_title:SetValue(false)
	self.show_wing:SetValue(false)
	self.show_item:SetValue(false)
	self.show_rank:SetValue(string.format(Language.Field1v1.RankMing, info.rank))
	if info.rank <= RANK.THREE then
		self.show_title:SetValue(true)
		if info.rank == RANK.ONE then
			if not self.show_wing:GetBoolean() then
				self.show_wing:SetValue(true)
			end
			if self.model then
				zhanli = ItemData.GetFightPower(other_cfg.first_wing_id)
			end
		end
		if not self.is_load_tittle and title[info.rank] then
			if not IsNil(self.title_obj) then
				GameObject.Destroy(self.title_obj)
			end
			cfg = TitleData.Instance:GetTitleCfg(title[info.rank].title_id)
			zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(cfg)
			local bundle, asset = ResPath.GetTitleModel(title[info.rank].title_id)
			self.is_load_tittle = true

			PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
				if prefab then
					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					obj.transform.localScale = Vector3(1.5, 1.5, 1.5)
					local transform = obj.transform
					transform:SetParent(self.title_root.transform, false)
					self.title_obj = obj.gameObject
					self.is_load_tittle = false
				end
			end)
		end
		self.zhanli:SetValue(zhanli)
	else
		self.show_item:SetValue(true)
		if self.item then
			self.item:SetData({is_bind = 1, item_id = 90015})
			self.item:SetParentActive(true)
		end
		if info.rank > RANK.TEN then
			self.show_rank:SetValue(Language.Field1v1.PreviewDesc2[info.rank - 10])
		end
	end
end

function ArenaRewardView:SetListViewCallBack(data)
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
	self.reward_text = self:FindVariable("reward_text")
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
	local cfg = ArenaData.Instance:GetRankRewardData()
	local flag = self.rank

	self.rank_info = rank_data[self.rank]
	if self.rank_info == nil then
		self.root_node.gameObject:SetActive(false)
		return
	end

	if self.rank <= RANK.THREE then
		self.show_img_1:SetValue(true)
		local bundle, asset = ResPath.GetArenaRankIcon(self.rank)
		self.rank_img:SetAsset(bundle, asset)
	elseif self.rank <= RANK.TEN then
		flag = RANK.THREE + 1
		self.rank_text:SetValue(self.rank)
		self.show_img_1:SetValue(false)
	else
		flag = RANK.THREE + 1 + flag - RANK.TEN
	end

	local data = cfg[flag]
	if data == nil then
		data = {reward_guanghui = 0}
	end

	if self.rank_info then
		if self.rank <= RANK.TEN then
			self.reward_text:SetValue(tostring(data.reward_guanghui))
			self.name_text:SetValue(self.rank_info.target_name)
			self.rank_value_text:SetValue(self.rank_info.capability)
			self.rank_text:SetValue(self.rank)
		else
			self.name_text:SetValue(Language.Field1v1.PreviewDesc2[self.rank - 10])
			self.rank_value_text:SetValue("")
			self.rank_text:SetValue("")
			self.reward_text:SetValue(tostring(data.reward_guanghui))

		end
		if self.is_click then
			self.parent:SetListViewCallBack(self.rank_info)
		end
	end
end

function ArenaRankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ArenaRankCell:ToggleClick(is_click)
	self.is_click = is_click
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
	-- local reward_list = user_info.item_list
	-- if reward_list and next(reward_list) then
	-- 	self.item_cell_list:SetParentActive(false)
	-- 	local data = reward_list[self.rank]
	-- 	if data and 0 ~= data.item_id then
	-- 		self.item_cell_list:SetData(data)
	-- 		self.item_cell_list:SetParentActive(true)
	-- 	end
	-- else
	local cfg = ArenaData.Instance:GetRankRewardData()
	local reward_show = cfg[self.rank].reward_show
	local xing_yao = ArenaData.Instance:GetRankRewardByRank(user_info.rank)
	self.item_cell_list:SetParentActive(true)
	self.item_cell_list:SetData({is_bind = reward_show[0].is_bind, item_id = reward_show[0].item_id, num = xing_yao})
end