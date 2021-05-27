------------------------------------------------------------
-- 装扮-分解 配置 ItemSynthesisConfig[11]
------------------------------------------------------------

local FashionResolveView = BaseClass(SubView)

local select_count = 0

function FashionResolveView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self.config_tab = {
		{"fashion_ui_cfg", 2, {0}},
	}

	self.select_list = {} -- 已勾选的物品

	self.item_type = 0
	if self.view_def == ViewDef.Fashion.FashionChild.FashionResolve then
		self.item_type = ItemData.ItemType.itFashion
	elseif self.view_def == ViewDef.Fashion.WuHuan.WuHuanResolve then
		self.item_type = ItemData.ItemType.itWuHuan
	elseif self.view_def == ViewDef.Fashion.ZhenQi.ZhenQiResolve then
		self.item_type = ItemData.ItemType.itGenuineQi
	end

	self:InitCfgList()
end


function FashionResolveView:__delete()
end

function FashionResolveView:ReleaseCallBack()
	self.select_list = {}
end

function FashionResolveView:LoadCallBack(index, loaded_times)
	self:CreateGridAndList()

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function FashionResolveView:OpenCallBack()
	--播放声音
end

function FashionResolveView:CloseCallBack(is_all)

	self.select_list = {}
end

--显示索引回调
function FashionResolveView:ShowIndexCallBack(index)
	self:Flush()
end

function FashionResolveView:OnFlush()
	self:FlushGrid()
	self:FlushAwardList()
end

----------视图函数----------

function FashionResolveView:InitCfgList()
	self.cfg_list = {}
	self.cfg_list = FashionData.Instance:GetResolveCfg()
end

function FashionResolveView:CreateGridAndList()
	self.grid = BaseGrid.New()
	self.grid:SetGridName(GRID_TYPE_BAG)
	local ph = self.ph_list["ph_equip_grid"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local grid_node = self.grid:CreateCells({w=ph.w, h=ph.h, cell_count = 20, col=5, row=4, itemRender = self.SwapCell, direction = ScrollDir.Vertical, ui_config = ph_item})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list["layout_fashion_resolve"].node:addChild(grid_node, 100)
	grid_node:setPosition(ph.x, ph.y)
	self.grid:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self))
	self.grid:SetIsMultiSelect(true)
	self:AddObj("grid")

	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
	local parent = self.node_t_list["layout_fashion_resolve"].node
	local item_render = BaseCell
	local line_dis = ph_item.h + 20
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.award_list = grid_scroll
	self:AddObj("award_list")
end


function FashionResolveView:FlushGrid()
	local list, index = {}, 0

	local item_list = BagData.Instance:GetBagItemDataListByType(self.item_type) or {}
	for i, item in pairs(item_list) do
		local item_id = item.item_id
		if self.cfg_list[item_id] then
			list[index] = item
			index = index + 1
		end
	end

	self.grid:SetDataList(list)
	local page_count = math.floor((#list + 1) / 20) + 1
	local max_count = page_count* 20
	self.grid:ExtendGrid(max_count)

	local cell_list = self.grid:GetAllCell()
	for k, cell in pairs(cell_list) do
		cell.hook = false
	end

	select_count = 0
end

function FashionResolveView:FlushAwardList()
	local cell_list = self.grid:GetAllCell()
	self.select_list = {}
	local award_list = {}
	local virtual_award_list = {}
	for k, cell in pairs(cell_list) do
		if cell.hook then
			local item = cell:GetData() or {}
			local item_id = item.item_id or 0
			local cur_cfg = self.cfg_list[item_id]
			if cur_cfg then
				local award = cur_cfg.award or {}
				BagData.ContinueRecordConsumesCount(award, award_list, virtual_award_list)
			end

			self.select_list[cur_cfg.index] = (self.select_list[cur_cfg.index] or 0) + 1
		end
	end

	local list = {}
	for item_id, count in pairs(award_list) do
		table.insert(list, {item_id = item_id, num = count, is_bind = 0})
	end

	for _type, count in pairs(virtual_award_list) do
		local virtual_item_id = ItemData.GetVirtualItemId(_type)
		table.insert(list, {item_id = virtual_item_id, num = count, is_bind = 0})
	end
	
	for i = 1, (12 - #list) do
		table.insert(list, {})
	end

	self.award_list:SetDataList(list)
end

----------end----------

function FashionResolveView:OnBtn()
	local list = {}
	for compose_index, compose_num in pairs(self.select_list) do
		local is_onekey_compose = compose_num > 1 and 1 or 0
		BagCtrl.SendComposeItem(11, 1, compose_index, is_onekey_compose, compose_num)
	end

end

function FashionResolveView:SelectCellCallBack(cell)
	self:FlushAwardList()
end

function FashionResolveView:OnBagItemChange(event)
	if self:IsOpen() then
		local bool = false
		for k, v in pairs(event.GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST then
				bool = true
				break
			else
				local item_id = v.data.item_id
				if self.cfg_list[item_id] then
					bool = true
					break
				end
			end
		end

		if bool then
			self:Flush()
		end
	end
end

--------------------

FashionResolveView.SwapCell = BaseClass(BaseRender)
local SwapCell = FashionResolveView.SwapCell
function SwapCell:__init()
	self.hook = false
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
end

function SwapCell:OnFlush()
	if nil == self.data then
		self.item_cell:SetData(nil)
		self.item_cell:SetIsChoiceVisible(false)
		self.item_cell:MakeGray(false)
		return
	end

	-- 效准默认选择状态
	if self.hook == false and self.is_select then
		self.is_select = self.hook
	end

	self.item_cell:SetData(self.data)
	self.item_cell:SetIsChoiceVisible(self.hook)
	self.item_cell:MakeGray(self.hook)
end

function SwapCell:OnClick()
	if nil == self.data or nil == next(self.data) then return end

	if self.hook == false then
		-- 勾选时, 判断数量不得大于等于20
		if select_count >= 20 then
			local str = "最多选中20个"
			SysMsgCtrl.Instance:FloatingTopRightText(str)
			return
		else
			select_count = select_count + 1
		end
	else
		select_count = select_count - 1
	end

	self.hook = not self.hook
	self.item_cell:SetIsChoiceVisible(self.hook)
	self.item_cell:MakeGray(self.hook)

	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function SwapCell:CreateSelectEffect()
	
end


return FashionResolveView