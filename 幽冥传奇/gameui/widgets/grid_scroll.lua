
GridScroll = GridScroll or BaseClass()
function GridScroll:__init()
	self.view = nil
	self.items = {}
	self.data_list = {}

	self.cur_select_item = nil
	self.select_callback = nil

	self.width = 0
	self.height = 0
	self.line_count = 0
	self.line_dis = 0
	self.item_render = nil
	self.direction = 0
	self.ui_config = nil

	self.refresh_is_asc = true						-- 是否升序刷新
	self.is_use_step_calc = true 					-- 默认使用分步计算
end

function GridScroll:__delete()
	for i, v in ipairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function GridScroll:GetView()
	return self.view
end

function GridScroll:GetItems()
	return self.items
end

function GridScroll:GetDataList()
	return self.data_list
end

function GridScroll:SetDataList(data_list)
	self.data_list = data_list
	self:RefreshItems()
end

function GridScroll:GetSelectItem()
	return self.cur_select_item
end

-- 设置选中回调函数
function GridScroll:SetSelectCallBack(callback)
	self.select_callback = callback
end

function GridScroll:CancleSelect()
	if self.cur_select_item ~= nil then
		self.cur_select_item:SetSelect(false)
		self.cur_select_item = nil
	end
end

function GridScroll:Create(x, y, w, h, line_count, line_dis, item_render, direction, is_bounce, ui_config)
	self.width = w
	self.height = h
	self.line_count = line_count
	self.line_dis = line_dis
	self.item_render = item_render
	self.direction = direction or ScrollDir.Vertical
	self.ui_config = ui_config
	self.view = XUI.CreateScrollView(x, y, w, h, self.direction)
	self.view:setBounceEnabled(is_bounce or false)
	return self.view
end

-- 刷新items列表
function GridScroll:RefreshItems()
	if self.data_list == nil or self.item_render == nil or self.view == nil then
		return
	end
	
	local item_count = #self.items
	local data_count = #self.data_list
	if item_count > data_count then					-- item太多 删掉
		for i = item_count, data_count + 1, -1 do
			self:RemoveAt(i)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		for i = item_count + 1, data_count do
			item = self.item_render.New(self.width, self.height)
			item:SetAnchorPoint(0.5, 0.5)
			item:SetIsUseStepCalc(self.is_use_step_calc)
			if nil ~= self.ui_config then
				item:SetUiConfig(self.ui_config, false)
			end
			table.insert(self.items, item)
			self.view:addChild(item:GetView())

			item:AddClickEventListener(BindTool.Bind(self.OnItemClickCallback, self, item))
		end
	end

	if self.refresh_is_asc then						-- 升序刷新
		for i, v in ipairs(self.items) do
			v:SetIndex(i)
			v:SetData(self.data_list[i])
		end
	else
		for i = data_count, 1, -1 do
			self.items[i]:SetIndex(i)
			self.items[i]:SetData(self.data_list[i])
		end
	end

	self:RefreshPosition()
end

--设置是否是分步计算
function GridScroll:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

function GridScroll:RemoveAt(index)
	local item = self.items[index]
	if nil == item then
		return
	end

	if self.cur_select_item == item then
		self.cur_select_item = nil
	end

	item:GetView():removeFromParent()
	item:DeleteMe()

	table.remove(self.items, index)
end

-- 排位置
function GridScroll:RefreshPosition()
	if self.line_count <= 0 then
		return
	end

	local size = self.view:getContentSize()
	local inner_size = cc.size(size.width, size.height)

	if self.direction == ScrollDir.Vertical then
		local line = math.ceil(#self.items / self.line_count)
		inner_size.height = line * self.line_dis
		if inner_size.height < size.height then
			inner_size.height = size.height
		end
		local item_w = size.width / self.line_count

		for i, v in ipairs(self.items) do
			local x = ((i - 1) % self.line_count) * item_w + item_w / 2
			local y = inner_size.height - (math.floor((i - 1) / self.line_count) * self.line_dis + self.line_dis / 2)
			v:SetPosition(x, y)
		end

		--更新内容节点坐标 之前只更新了内部item坐标
		if self.old_line and self.old_line >= 5 and self.old_line > line then
			self.view:getInnerContainer():setPositionY(self.view:getInnerContainer():getPositionY() + self.line_dis * (self.old_line - line)) 
		end
		self.old_line = line
	else
		local line = math.ceil(#self.items / self.line_count)
		inner_size.width = line * self.line_dis
		if inner_size.width < size.width then
			inner_size.width = size.width
		end
		local item_h = size.height / self.line_count

		for i, v in ipairs(self.items) do
			local x = math.floor((i - 1) / self.line_count) * self.line_dis + self.line_dis / 2
			local y = size.height - (((i - 1) % self.line_count) * item_h + item_h / 2)
			v:SetPosition(x, y)
		end
	end

	self.view:setInnerContainerSize(inner_size)
end

function GridScroll:OnItemClickCallback(item)
	if item == nil then
		return
	end
	if self.cur_select_item ~= item and nil ~= self.cur_select_item then
		self.cur_select_item:SetSelect(false)
	end

	self.cur_select_item = item
	item:SetSelect(true)

	if nil ~= self.select_callback then
		self.select_callback(item)
	end
end

function GridScroll:SelectItemByIndex(index)
	local item = self.items[index]
	self:OnItemClickCallback(item)
end

function GridScroll:JumpToTop()
	self.view:jumpToTop()
end

-- 居中处理
function GridScroll:SetCenter(ignore_size)
	local view = self.view
	local size = view:getContentSize()
	local inner_size = cc.size(size.width, size.height)

	-- 纵向滑动时,居中纵向位置
	if self.direction == ScrollDir.Vertical then
		local line = math.ceil(#self.items / self.line_count)
		inner_size.height = line * self.line_dis
		size.height = math.min(self.height, inner_size.height)
	else
	-- 其它滑动方向,居中横向位置
		local line = math.ceil(#self.items / self.line_count)
		inner_size.width = line * self.line_dis
		size.width = math.min(self.width, inner_size.width)
	end

	-- 忽略大小
	if ignore_size then
		view:setContentSize(inner_size)
	else
		view:setContentSize(size)
	end
	view:setInnerContainerSize(inner_size)
	view:jumpToTop()
end