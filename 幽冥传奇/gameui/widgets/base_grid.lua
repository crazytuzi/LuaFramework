----------------------------------------------------
-- 基础网格,index从0开始
----------------------------------------------------
GRID_TYPE_BAG = "bag"
GRID_TYPE_STORAGE = "storge"
GRID_TYPE_RECYCLE_BAG = "bag_recycle"
GRID_TYPE_RECYCLE = "recycle"

BaseGrid = BaseGrid or BaseClass()
function BaseGrid:__init()
	self.grid = nil									-- 网格根节点
	self.grid_name = ""								-- 格子名称
	self.page_index = 1								-- 当前页（1~n）
	self.page_cell_count = 0						-- 一页的格子数
	self.cur_cell = nil								-- 当前选中的格子
	self.cells = {}									-- 格子列表
	self.cell_data_list = {}						-- 格子数据列表
	self.max_cell_index = 0							-- 最大索引
	self.select_callback = nil						-- 选中某个格子回调
	self.page_change_callback = nil					-- 翻页回调
	self.radio_btn = nil							-- 关联的RadioButton控件

	self.item_render = nil							-- 创建的item类型
	self.ui_config = nil
	self.pos_list = nil								-- 位置列表
	self.is_show_tips = nil							-- 是否显示tips
	self.is_center = false							-- 是否居中
	self.skin_style = nil							-- 风格
	self.create_callback = nil						-- 创建完成回调

	self.is_set_open_count = false					-- 是否设置了开启格子数
	self.max_open_index = 0							-- 已开启的最大格子索引（物品格子专用）
	self.is_change_page = false 					-- 是否正在翻页中

	self.is_multi_select = false 					-- 是否多选
	self.is_can_drag_cell = false 					-- 格子数据是否可拖动

	self.is_use_step_calc = true 					-- 默认使用分步计算
end

function BaseGrid:__delete()
	for i, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	if self.deily_create_timer then
		GlobalTimerQuest:CancelQuest(self.deily_create_timer)
		self.deily_create_timer = nil
	end
end

function BaseGrid:GetView()
	return self.grid
end

function BaseGrid:GetGrid()
	return self.grid
end

function BaseGrid:GetGridName()
	return self.grid_name
end

function BaseGrid:SetGridName(grid_name)
	self.grid_name = grid_name
end

function BaseGrid:GetPageCount()
	return self.grid:getPageCount()
end

function BaseGrid:GetPageCellCount()
	return self.page_cell_count
end

function BaseGrid:GetCurCell()
	return self.cur_cell
end

function BaseGrid:GetMultiSelectCell()
	local select_cells = {}
	for k, v in pairs(self.cells) do
		if v:IsSelect() then
			table.insert(select_cells, v) 
		end
	end
	return select_cells
end

function BaseGrid:GetAllCell()
	return self.cells
end

function BaseGrid:IsChangePage()
	return self.is_change_page
end

--取消当前选择的格子
function BaseGrid:CancleSelectCurCell()
	if self.cur_cell ~= nil then
		self.cur_cell:SetSelect(false)
		self.cur_cell = nil
	end
end

function BaseGrid:GetDataList()
	return self.cell_data_list
end

function BaseGrid:SetDataList(data_list)
	self.cell_data_list = data_list
	for k, v in pairs(self.cells) do
		v:SetData(data_list[k])
	end
end

-- callback(cell)
function BaseGrid:SetSelectCallBack(callback)
	self.select_callback = callback
end

-- callback(self, index)
function BaseGrid:SetPageChangeCallBack(callback)
	self.page_change_callback = callback
end

function BaseGrid:SetRadioBtn(radio_btn)
	self.radio_btn = radio_btn
end

function BaseGrid:GetMaxOpenIndex()
	return self.max_open_index
end

function BaseGrid:GetCurPageIndex()
	return self.page_index
end

function BaseGrid:Create(x, y, w, h, cell_count, col, row, itemRender, direction, ui_config)
	local t = {w = w, h = h, cell_count = cell_count, col = col, row = row, itemRender = itemRender, direction = direction, ui_config = ui_config}
	local grid = self:CreateCells(t)
	grid:setPosition(x, y)
	
	return grid
end

-- 创建网格 {t.w, t.h, t.cell_count, t.col, t.row, t.itemRender, t.direction, t.ui_config}
-- t.itemRender可为nil，默认为GridCell
-- t.direction可为nil，默认为ScrollDir.Horizontal,水平方向
-- return grid实体
function BaseGrid:CreateCells(t)
	if nil == t or t.cell_count <= 0 or t.col <= 0 or t.row <= 0 then
		return nil
	end

	if nil == self:CreatePageView(t) then
		return nil
	end

	self.page_cell_count = t.row * t.col
	self.item_render = t.itemRender or GridCell		-- 默认放物品格子
	self.ui_config = t.ui_config
	self.pos_list = {}
	self.max_cell_index = t.cell_count - 1
	self.is_show_tips = t.is_show_tips
	self.is_center = true
	
	local pos_count = math.min(self.page_cell_count, t.cell_count)
	local avg_w, avg_h = t.w / t.col, t.h / t.row
	for i = 0, pos_count - 1 do
		local row = math.floor(i / t.col)
		local col = math.mod(i, t.col)
		self.pos_list[i] = {avg_w * col + avg_w / 2, t.h - (avg_h * row + avg_h / 2)}
	end
	if self.deily_create_timer then
		GlobalTimerQuest:CancelQuest(self.deily_create_timer)
		self.deily_create_timer = nil
	end
	self:CreateCellsHelper(0)

	return self.grid
end

-- 指定坐标创建网格，坐标由外部提供.
-- t = {t.w, t.h, t.itemRender, t.direction}
-- pos_list = {{10, 5}, {3, 3}}
function BaseGrid:CreateCellsByPos(t, pos_list)
	if nil == t or nil == pos_list or #pos_list <= 0 then
		return nil
	end

	if nil == self:CreatePageView(t) then
		return nil
	end

	self.page_cell_count = #pos_list + 1
	self.item_render = t.itemRender or GridCell		-- 默认放物品格子
	self.ui_config = t.ui_config
	self.pos_list = pos_list
	self.max_cell_index = #pos_list

	if self.deily_create_timer then
		GlobalTimerQuest:CancelQuest(self.deily_create_timer)
		self.deily_create_timer = nil
	end
	self:CreateCellsHelper(0)

	return self.grid
end

-- 创建翻页控件
function BaseGrid:CreatePageView(t)
	if nil == t or nil ~= self.grid or t.w <= 0 or t.h <= 0 then
		return nil
	end

	local direction = t.direction or ScrollDir.Horizontal	-- 默认水平

	self.grid = XPageView:create(direction)
	self.grid:setContentWH(t.w, t.h)
	self.grid:addPageEventListener(BindTool.Bind(self.PageChange, self))

	return self.grid
end

function BaseGrid:CreateCell(layout, index, x, y)
	local cell = self.item_render.New(index)
	cell:SetIndex(index)
	cell:SetName(self.grid_name)
	if nil ~= self.ui_config then
		cell:SetUiConfig(self.ui_config, false)
	end
	cell:SetIsUseStepCalc(self.is_use_step_calc)
	if cell.SetIsCanDrag then
		cell:SetIsCanDrag(self.is_can_drag_cell, self.grid_name)
	end
	cell:SetClickCallBack(BindTool.Bind(self.SelectCellHandler, self))
	self.cells[index] = cell

	cell:GetView():setPosition(x, y)
	layout:addChild(cell:GetView())
	return cell
end

-- 设置创建完成回调函数
function BaseGrid:SetCreateCallback(create_callback)
	self.create_callback = create_callback
end

-- 创建
function BaseGrid:CreateCellsHelper(begin_index)
	local grid_size = self.grid:getContentSize()
	local curr_layout = self.grid:getPage(math.floor(begin_index / self.page_cell_count))
	local data = nil
	self.last_create_index = self.max_cell_index - begin_index > 39 and begin_index + 39 or self.max_cell_index
	for i = begin_index, self.last_create_index do
		data = self.cell_data_list[i]
		if nil == curr_layout or math.mod(i, self.page_cell_count) == 0 then
			curr_layout = XLayout:create()
			curr_layout:setContentSize(grid_size)
			self.grid:pushBackPage(curr_layout)
		end

		local pos_i = math.mod(i, self.page_cell_count)
		local cell = self:CreateCell(curr_layout, i, self.pos_list[pos_i][1], self.pos_list[pos_i][2])
		if self.is_center then
			cell:GetView():setAnchorPoint(0.5, 0.5)
		end
		
		cell:SetData(data)

		if nil ~= self.skin_style then
			cell:SetSkinStyle(self.skin_style[i] or self.skin_style[1])
		end

		if nil ~= self.is_show_tips then
			cell:SetIsShowTips(self.is_show_tips)
		end

		if self.is_set_open_count then
			cell:SetOpen(i <= self.max_open_index)
		end
	end
	if self.last_create_index < self.max_cell_index then
		self.deily_create_timer = GlobalTimerQuest:AddDelayTimer(function() self:CreateCellsHelper(self.last_create_index + 1) end, 0)
	end
end

function BaseGrid:GetMaxCellCount()
	return self.max_cell_index + 1
end

-- 扩展格子，max_count：最大格子数量
function BaseGrid:ExtendGrid(max_count)
	if self.max_cell_index >= max_count - 1 then
		return
	end
	if self.deily_create_timer then
		GlobalTimerQuest:CancelQuest(self.deily_create_timer)
		self.deily_create_timer = nil
	end
	local begin_index = self.last_create_index + 1
	self.max_cell_index = max_count - 1
	self:CreateCellsHelper(begin_index)
end

-- 删除最后一页
function BaseGrid:RemoveLastPage()
	local page_count = self:GetPageCount()
	if nil == self.grid or page_count <= 0 then
		return
	end

	if self.page_index == page_count then
		self:ChangeToPage(1)
	end

	self.grid:removeLastPage()
	local new_max_index = (page_count - 1) * self.page_cell_count - 1

	for i = self.max_cell_index, new_max_index + 1, -1 do
		local cell = self.cells[i]
		if self.cur_cell == cell then
			self.cur_cell = nil
		end

		if nil ~= cell then
			cell:DeleteMe()
			self.cells[i] = nil
		end
		self.cell_data_list[i] = nil
	end

	self.max_cell_index = new_max_index
end

-- 设置格子皮肤样式 ，样式表参照BaseCell中的SetSkinStyle注释
-- 如果只有一个值，则所有格子使用统一样式，否则各取各的
function BaseGrid:SetCellSkinStyle(t)
	if t == nil or #t == 0 then
		return
	end

	self.skin_style = t
	local t_count = #t

	for k, v in pairs(self.cells) do
		if t_count == 1 then
			v:SetSkinStyle(t[1])
		else
			v:SetSkinStyle(t[v:GetIndex()])
		end
	end
end

-- 刷新某个格子里的数据
function BaseGrid:UpdateOneCell(index, data)
	local cell = self.cells[index]
	if nil ~= cell then
		cell:SetData(data)
	end
	self.cell_data_list[index] = data
end

-- 获得指定的格子
function BaseGrid:GetCell(index)
	return self.cells[index]
end

-- 翻页回调
function BaseGrid:PageChange(sender, index)
	self.is_change_page = false
	local page_index = index + 1
	local prve_page_index = self.page_index
	if self.page_index ~= page_index then
		self.page_index = page_index

		if nil ~= self.page_change_callback then
			self.page_change_callback(self, page_index, prve_page_index)
		end

		if nil ~= self.radio_btn then
			self.radio_btn:ChangeToIndex(page_index)
		end
	end
end

-- index 1~n
function BaseGrid:ChangeToPage(index)
	local page_count = self:GetPageCount()
	if self.page_index ~= index and index >= 1 and index <= page_count then
		self.is_change_page = true
		self.grid:scrollToPage(index - 1)
	end
end

-- index 1~n
function BaseGrid:JumpToPage(index)
	local page_count = self:GetPageCount()
	if self.page_index ~= index and index >= 1 and index <= page_count then
		self.is_change_page = true
		self.grid:jumpToPage(index - 1)
	end
end

-- 根据格子索引选择格子
function BaseGrid:SelectCellByIndex(index)
	local select_cell = self:GetCell(index)
	if nil ~= select_cell then
		self:SelectCellHandler(select_cell)
	end
end

--根据格子索引取消选择的格子
function BaseGrid:CancleSelectCellByIndex(index)
	local select_cell = self:GetCell(index)
	if nil ~= select_cell then
		if select_cell:IsSelect() and self.is_multi_select then
			select_cell:SetSelect(false)
			select_cell = nil
		end
	end
end

-- 设置可选择空格子（选择特效）
function BaseGrid:CanSelectNilData(value)
	if self.cells then
		for k,v in pairs(self.cells) do
			v:SetIgnoreDataToSelect(value)
		end
	end
end

-- 选择某个格子回调
function BaseGrid:SelectCellHandler(cell)
	if cell:IsSelect() and self.is_multi_select then  --多选中再点已选中的认为取消
		cell:SetSelect(false)
		self.select_callback(cell)
		return
	end
	if nil ~= self.cur_cell and not self.is_multi_select then
		self.cur_cell:SetSelect(false)
	end

	self.cur_cell = cell
	if nil ~= self.cur_cell then
		self.cur_cell:SetSelect(true)
	end
	if nil ~= self.select_callback then
		if cell:GetName() == GRID_TYPE_BAG or cell:GetName() == GRID_TYPE_STORAGE then
			self.select_callback(cell, self.max_open_index)
		else
			self.select_callback(cell)
		end
	end
end

-- 将网格之间的数据互相移动
-- {fromIndex, toGrid, toIndex, num, isNeedLock, moveType}
function BaseGrid:MoveCellDataToGrid(t)
	if t == nil or t.toGrid == nil then
		return
	end
	local fromCell = self:GetCell(t.fromIndex)
	local toCell = t.toGrid:GetCell(t.toIndex)
	if fromCell == nil or toCell == nil or fromCell:GetData() == nil then
		return
	end

	local formData = fromCell:GetData()
	local toData = toCell:GetData()

	if t.isNeedLock == true then
		fromCell:SetIsLock(true)
	else
		fromCell:SetIsLock(false)
	end
	
	if t.moveType == nil or t.moveType == 0 then			--复制数据
		toData = TableCopy(formData) 
		toData.num = t.num or formData.num
		toCell.data_from_index = t.fromIndex
		t.toGrid:UpdateOneCell(t.toIndex, toData)
	elseif t.moveType == 1	then							--移动数据					
		t.toGrid:UpdateOneCell(t.toIndex, formData)
		toCell.data_from_index = t.fromIndex
		self:ClearCellData(t.fromIndex)
	elseif t.moveType == 2 and toData then					--恢复数据
		toCell:SetIsLock(false)
		toData.num = toData.num + formData.num
		t.toGrid:UpdateOneCell(t.toIndex, toData)
		self:ClearCellData(t.fromIndex)
	elseif t.moveType == 3 then 							--复制数据并从数据源中相应减少
		toData = TableCopy(formData) 
		toData.num = t.num or formData.num
		toCell.data_from_index = t.fromIndex
		t.toGrid:UpdateOneCell(t.toIndex, toData)

		formData.num = formData.num - (t.num or formData.num)
		if formData.num <= 0 then
			formData.num = 0
			fromCell:SetIsLock(true)
		end
		self:UpdateOneCell(t.fromIndex, formData)
	end
end

--设置是否可以拖动
function BaseGrid:SetIsCanDragCell(is_can_drag_cell)
	self.is_can_drag_cell = is_can_drag_cell
end

--设置是否是分步计算
function BaseGrid:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

----------------------------------------------------
-- 以下为物品格子专用
----------------------------------------------------
--根据物品id获得第一个符合的格子
function BaseGrid:GetFirstCellByItemId(item_id)
	for k, v in pairs(self.cells) do
		if v:GetData() and v:GetData().item_id == item_id then
			return v
		end
	end
	return nil
end

--根据物品类型获得第一个符合的格子
function BaseGrid:GetFirstCellByType(item_type, sub_type)
	for k, v in pairs(self.cells) do
		if v:GetData() then
			local item_base_data, big_type = ItemData.Instance:GetItemConfig(v:GetData().item_id)
			if nil ~= item_base_data and big_type == item_type then
				if nil ~= sub_type then
					if item_base_data.sub_type == sub_type then
						return v
					end
				end
				return v
			end
		end
	end
	return nil
end

--获得第一个空格子
function BaseGrid:GetFirstEmptyCell()
	if self.cells[0] and nil == self.cells[0]:GetData() and self.cells[0]:GetIsOpen() then
		return self.cells[0]
	end
	for k,v in ipairs(self.cells) do
		if nil == v:GetData() and v:GetIsOpen() then
			return v
		end
	end
	return nil
end

--清除物品格子数据
function BaseGrid:ClearCellData(index)
	local cell = self.cells[index]
	if nil ~= cell then
		cell:ClearData()
	end
	self.cell_data_list[index] = nil
end

--开启到多少的格子
function BaseGrid:OpenCellToIndex(maxindex)
	self.max_open_index = maxindex
	self.is_set_open_count = true
	for k, v in pairs(self.cells) do
		if v.index <= maxindex then
			v:SetOpen(true)
		else
			v:SetOpen(false)
		end
	end
end

function BaseGrid:SetVisible(boo)
	self.grid:setVisible(boo)
end

function BaseGrid:SetIsShowTips(is_show_tips)
	self.is_show_tips = is_show_tips
	for k, v in pairs(self.cells) do
		v:SetIsShowTips(is_show_tips)
	end
end

function BaseGrid:SetIsMultiSelect(is_multi_select)
	self.is_multi_select = is_multi_select
end

--@为格子设置新品标记,
--@cell_index 格子索引，从0开始  -1表示批量
--@page_index 页， 从0开始 -1 表示所有
function BaseGrid:SetNewFlagIconVisible(cell_index, page_index, is_visible)
	local flag = false
	page_index = page_index or 0

	for k,v in pairs(self.cells) do
		flag = false
		if cell_index == -1 and page_index == -1 then
			flag = true
		elseif cell_index == -1 and page_index >= 0 and math.floor(v:GetIndex() / self.page_cell_count) == page_index then --当前页
			flag = true
		elseif cell_index >= 0 and cell_index == v:GetIndex() then
			flag = true
		end
		if flag then
			v:SetNewFlagIconVisible(is_visible)
		end
	end
end


GridCell = GridCell or BaseClass(BaseCell)

function GridCell:CreateSelectEffect()

end