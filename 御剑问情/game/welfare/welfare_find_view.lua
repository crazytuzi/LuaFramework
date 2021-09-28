FindView = FindView or BaseClass(BaseRender)

function FindView:__init()
	self.cell_list = {}
	self.scroller_data = {}
	self.selet_cell_index = 1
	self.all_cost = self:FindVariable("AllCost")
	self.str = self:FindVariable("Str")
	self:InitScroller()
	self:ListenEvent("AllFreeFindClick", BindTool.Bind(self.AllFindClick, self, 0))
	self:ListenEvent("AllUseGoldFindClick", BindTool.Bind(self.AllFindClick, self, 1))

	self.have_reward = self:FindVariable("HaveReward")
	self.select_big_type = -1
	self.select_type = -1
	self.str:SetValue(Language.Welfare.FindStr)
	self:Flush()
end

function FindView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
end

function FindView:Flush()
	if self.scroller_data == nil or next(self.scroller_data) == nil then
		self.have_reward:SetValue(false)
		self.all_cost:SetValue(0)
		return
	end
	self.have_reward:SetValue(#self.scroller_data > 0)
	local cost_count = 0
	for k,v in pairs(self.scroller_data) do
		cost_count = cost_count + v.gold_need
	end
	self.all_cost:SetValue(cost_count)
end
--刷新滚动条
function FindView:FlushScroller()
	self.selet_cell_index = 1
	self.scroller_data = WelfareData.Instance:GetFindData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end
--初始化滚动条
function FindView:InitScroller()
	self.scroller_data = WelfareData.Instance:GetFindData()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/welfare_prefab", "FindItem"), function (prefab)
		if nil == prefab then
			return
		end
		PrefabPool.Instance:Free(prefab)

		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end
--滚动条数量
function FindView:GetNumberOfCells()
	if self.scroller_data == nil or next(self.scroller_data) == nil then
		return 0
	end
	return #self.scroller_data
end
--滚动条大小
function FindView:GetCellSize()
	return 154
end
--滚动条刷新
function FindView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1

	local lua_cell = self.cell_list[cell_view]
	if nil == lua_cell then
		self.cell_list[cell_view] = FindScrollerCell.New(cell_view.gameObject)
		lua_cell = self.cell_list[cell_view]
		lua_cell.mother_view = self
	end
	local cell_data = self.scroller_data[data_index]
	if cell_data == nil then
		return
	end
	cell_data.data_index = data_index
	lua_cell:SetData(cell_data)

	return cell_view
end
--单个找回
-- function FindView:SingleFindClick(find_type)
-- 	if self.select_type < 0 then
-- 		TipsCtrl.Instance:ShowSystemMsg("没有选择任何奖励")
-- 		return
-- 	end
-- 	if self.select_big_type == 0 then
-- 		WelfareCtrl.Instance:SendGetFindReward(self.select_type, find_type)
-- 	else
-- 		if find_type == 0 then
-- 			find_type = 1
-- 		else
-- 			find_type = 0
-- 		end
-- 		WelfareCtrl.Instance:SendGetActivityFindReward(self.select_type, find_type)
-- 	end
-- 	self.select_type = -1
-- end

function FindView:AllFind(find_type)
	if next(self.scroller_data) == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Welfare.NoFind)
	end

	local acitvity_find_type = 0
	if find_type == 0 then
		acitvity_find_type = 1
	end

	for k,v in pairs(self.scroller_data) do
		if v.total_type == 0 then
			WelfareCtrl.Instance:SendGetFindReward(v.find_type, find_type)
		else
			WelfareCtrl.Instance:SendGetActivityFindReward(v.vo.find_type, acitvity_find_type)
		end
	end
	self.select_type = -1
end

function FindView:AllFindClick(find_type)
	local function ok_callback()
		self:AllFind(find_type)
	end
	local des = ""
	if find_type == 1 then
		local cost_count = 0
		for k,v in pairs(self.scroller_data) do
			cost_count = cost_count + v.gold_need
		end
		des = string.format(Language.Welfare.FindGold, cost_count)
	else
		des = Language.Welfare.FindFree
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
end

-- function FindView:OnScrollerCellClick(data_index, data)
-- 	self.selet_cell_index = data_index
-- 	self.select_type = data.find_type
-- 	self.select_big_type = data.total_type
-- 	-- self.single_cost:SetValue(data.gold_need)
-- end

---------------------------------------------------------------
--滚动条格子
FindScrollerCell = FindScrollerCell or BaseClass(BaseCell)

local CurrencyName = {
		[1] = "bind_coin",
		[2] = "xianhun",
		[3] = "gongxian",
		[4] = "exp",
		[5] = "yuanli",
		[6] = "honor",
		[7] = "nvwashi",
		[8] = "guild_gongxian",
	}

function FindScrollerCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.item_name = self:FindVariable("Name")
	self:ListenEvent("FindFree", BindTool.Bind(self.ClickFind, self, 0))
	self:ListenEvent("FindCost", BindTool.Bind(self.ClickFind, self, 1))
	self.cost = self:FindVariable("Cost")
	self.cost:SetValue(0)
	self.item_cell_list = {}
	local obj_group = self:FindObj("ItemManager")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.item_cell_list[count] = ItemCell.New()
			self.item_cell_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end
end

function FindScrollerCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
end

function FindScrollerCell:OnFlush()
	self.count = 1
	local base_vo = self.data.vo or {}
	if self.data.total_type == 0 then
		--日常找回
		local daily_find_list = WelfareData.Instance:GetWelfareCfg().daily_find_list
		for k,v in pairs(daily_find_list) do
			if v.type == self.data.find_type then
				self.data.cfg = v
				break
			end
		end
		if self.data.cfg then
			self.item_name:SetValue(self.data.cfg.name)
		else
			print_error("No Config", self.data.find_type)
		end
	else
		--活动找回
		self.item_name:SetValue(base_vo.name or "")
	end
	--虚拟币奖励
	for k,v in pairs(CurrencyName) do
		if self.data[v] ~= nil and self.data[v] ~= 0 then
			local data = {}
			data.num = self.data[v]
			data.item_id = ResPath.GetCurrencyID(v)
			data.is_bind = true
			self.item_cell_list[self.count]:SetActive(true)
			self.item_cell_list[self.count]:SetData(data)
			self.count = self.count + 1
		end
	end
	--道具奖励
	for k,v in pairs(self.data.item_list) do
		if v ~= nil then
			if self.count > #self.item_cell_list then
				break
			end
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
			local reward_list = {}
			-- 如果是礼包则显示礼包内的物品
			-- if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			-- 	if item_cfg.rand_num ~= 1 then
			-- 		reward_list = ItemData.Instance:GetGiftItemListByProf(v.item_id)
			-- 	end
			-- end

			local rat_num = 1

			local function func(item_data)
				if self.count > #self.item_cell_list then
					return
				end
				local new_data = {}
				new_data.item_id = item_data.item_id
				new_data.num = item_data.num * rat_num
				new_data.is_bind = item_data.is_bind
				self.item_cell_list[self.count]:SetActive(true)
				self.item_cell_list[self.count]:SetData(new_data)
				self.count = self.count + 1
			end
			if next(reward_list) then
				for k2, v2 in ipairs(reward_list) do
					rat_num = v.num or 1
					func(v2)
				end
			else
				func(v)
			end
		end
	end
	--写死3个
	if self.count > 3 then
		self.count = 3
	end
	--隐藏没有数据的格子
	if self.count <= #self.item_cell_list then
		for i=self.count,#self.item_cell_list do
			self.item_cell_list[i]:SetActive(false)
		end
	end
	self.cost:SetValue(self.data.gold_need)
end

function FindScrollerCell:ClickFind(find_type)
	local func = function ()
		local acitvity_find_type = 0
		if find_type == 0 then
			acitvity_find_type = 1
		end
		if self.data.total_type == 0 then
			WelfareCtrl.Instance:SendGetFindReward(self.data.find_type, find_type)
		else
			WelfareCtrl.Instance:SendGetActivityFindReward(self.data.vo.find_type, acitvity_find_type)
		end
	end

	if find_type == 1 or WelfareData.Instance:GetIsHideTip() then
		func()
	else
		WelfareCtrl.Instance:ShowWelfareTip(func, nil, Language.Welfare.FreeFindTips, nil, nil, true)
	end
end