------------------------------------------------------------
-- 寻宝-男女互换
------------------------------------------------------------

local ExploreSwapView = BaseClass(SubView)

local item_type_list = {[2] = true, [10] = true, [120] = true}
local select_count = 0

function ExploreSwapView:__init()
	self.texture_path_list[1] = 'res/xui/explore.png'
	self.config_tab = {
		{"explore_ui_cfg", 10, {0}},
	}
end

function ExploreSwapView:__delete()
end

function ExploreSwapView:ReleaseCallBack()
end

function ExploreSwapView:LoadCallBack(index, loaded_times)
	self:CreateGridAndList()

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	self.cfg_list = ExploreData.Instance:GetEquipExchangeList()
end

--显示索引回调
function ExploreSwapView:ShowIndexCallBack(index)
	self:Flush()
end

function ExploreSwapView:OnFlush()
	self:FlushGrid()
	self:FlushAwardList()
end

----------视图函数----------

function ExploreSwapView:CreateGridAndList()
	self.grid = BaseGrid.New()
	self.grid:SetGridName(GRID_TYPE_BAG)
	local ph = self.ph_list["ph_grid_1"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local grid_node = self.grid:CreateCells({w=ph.w, h=ph.h, cell_count = 25, col=5, row=5, itemRender = self.SwapCell, direction = ScrollDir.Vertical, ui_config = ph_item})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list["layout_swap"].node:addChild(grid_node, 100)
	grid_node:setPosition(ph.x, ph.y)
	self.grid:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self))
	self.grid:SetIsMultiSelect(true)
	self:AddObj("grid")

	local ph = self.ph_list["ph_grid_2"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.node_t_list["layout_swap"].node
	local item_render = BaseCell
	local line_dis = ph_item.w
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 5, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.award_list = grid_scroll
	self:AddObj("award_list")
end

function ExploreSwapView:FlushGrid()
	local list, index = {}, 0
	for item_type, _ in pairs(item_type_list) do
		local item_list = BagData.Instance:GetBagItemDataListByType(item_type) or {}
		for i, item in pairs(item_list) do
			local item_id = item.item_id
			if self.cfg_list[item_id] then
				list[index] = item
				index = index + 1
			end
		end
	end

	self.grid:SetDataList(list)
	local page_count = math.floor((#list + 1) / 25) + 1
	local max_count = page_count* 25
	self.grid:ExtendGrid(max_count)

	local cell_list = self.grid:GetAllCell()
	for k, cell in pairs(cell_list) do
		cell.choice = 0
	end
end

function ExploreSwapView:FlushAwardList()
	local cell_list = self.grid:GetAllCell()
	self.need_score = 0
	self.select_list = {}
	local list = {}
	for k, cell in pairs(cell_list) do
		if cell.choice == 1 then
			local item = cell:GetData() or {}
			local item_id = item.item_id or 0
			local cur_cfg = self.cfg_list[item_id]
			if cur_cfg then
				local award = cur_cfg.award or {}
				self.need_score = self.need_score + cur_cfg.score
				table.insert(list, award)
				table.insert(self.select_list, cur_cfg.id)
			end
		end
	end
	select_count = #list

	if select_count < 25 then
		for i = 1, (25 - select_count) do
			table.insert(list, {})
		end
	end
	self.award_list:SetDataList(list)

	local xun_bao_data = ExploreData.Instance:GetXunBaoData()
	local xunbao_jifen = xun_bao_data.bz_score or 0
	self.can_swap = xunbao_jifen >= self.need_score
	local color = self.can_swap and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_scores"].node:setColor(color)
	self.node_t_list["lbl_scores"].node:setString(self.need_score .. "宝藏积分")
end

----------end----------

function ExploreSwapView:SelectCellCallBack(item)
	if select_count >= 25 then

	else
		self:FlushAwardList()
	end
end

function ExploreSwapView:OnBtn()
	if self.can_swap then
		local select_list = self.select_list
		for i,v in ipairs(select_list) do
			ExploreCtrl.Instance:ExchageItemReq(3, v)
		end
	else
		local str = "宝藏积分不足"
		SystemHint:FloatingTopRightText(str)
	end
end

function ExploreSwapView:OnBagItemChange(event)
	local bool = false
	for k, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local _type = v.data.type
			if item_type_list[_type] then
				bool = true
				break
			end
		end
	end

	if bool then
		self:Flush()
	end
end

--------------------
ExploreSwapView.SwapCell = BaseClass(BaseRender)
local SwapCell = ExploreSwapView.SwapCell
function SwapCell:__init()
	-- self.is_select = true
end

function SwapCell:DeleteMe()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SwapCell:CreateChild()
	BaseRender.CreateChild(self)

	local ph = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.item_cell:GetView(), 100)
	self.item_cell:SetIsShowTips(false)
	self.item_cell:SetName(GRID_TYPE_BAG)
	self.item_cell:SetIsChoiceVisible(false)
	self.item_cell:GetView():setTouchEnabled(false)

	self:AddClickEventListener(self.click_callback)

	self.choice = 0
end

function SwapCell:OnFlush()
	if nil == self.data then
		self.item_cell:SetData(nil)
		self.item_cell:SetIsChoiceVisible(false)
		self.item_cell:MakeGray(false)
		return
	end

	-- 效准默认选择状态
	if self.choice == 0 and self.is_select then
		self.is_select = self.choice == 1
	end

	self.item_cell:SetData(self.data)
	self.item_cell:SetIsChoiceVisible(self.choice == 1)
	self.item_cell:MakeGray(self.choice == 1)
end

function SwapCell:OnSelectChange(is_select)
	if self.choice ~= 1 and is_select and select_count >= 25 then
		self.is_select = false
		local str = "单次兑换最多25件"
		SystemHint:FloatingTopRightText(str)
		return
	elseif self.choice == 1 and not is_select and select_count >= 25 then
		-- 取消选中
		select_count = 0 -- 重置选中次数
	end

	if not self.item_cell:GetData() then return end
	self.choice = is_select and 1 or 0
	self:OnFlush()
end

function SwapCell:CreateSelectEffect()
	
end

return ExploreSwapView