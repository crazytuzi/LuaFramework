-----------------------------------------------------
--基础list组件
--提供增删等基础操作，结合ListViewItem 操作
--1.CreateView 创建list对象，并提供item渲染器
--2.设置数据源SetDataList
----------------------------------------------------
ListView = ListView or BaseClass()

ListView.Top = 0
ListView.Right = 1
ListView.Bottom = 2
ListView.Left = 3

XuiListEventType = {
	Began = 0,
	Refresh = 1,
	Ended = 2,
	Canceled = 3,
}

function ListView:__init()
	self.items = {}
	self.data_list = {}
	self.list_view = nil
	self.item_render = nil
	self.cur_select_item = nil
	self.select_callback = nil
	
	self.width = 0
	self.height = 0
	self.ui_config = nil
	self.jump_top_index = nil
	self.jump_direction = nil						-- 跳转方向
	
	self.refresh_is_asc = true						-- 是否升序刷新
	self.is_use_step_calc = true 					-- 默认使用分步计算
	
	self.is_auto_supply = false						-- 空数据补充
	
	self.delay_create_count = 1000
end

function ListView:__delete()
	for i, v in ipairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
	if self.deley_refresh_timer then
		GlobalTimerQuest:CancelQuest(self.deley_refresh_timer)
	end
end

function ListView:GetView()
	return self.list_view
end

-- 根据参数构建基础list显示对象
-- @param_t 结构如 {width=100, height=100, direction=1, itemRender=ListViewItem, gravity=2, bounce=true}
function ListView:CreateView(t)
	return self:Create(t.x, t.y, t.width, t.height, t.direction, t.itemRender, t.gravity, t.bounce, t.ui_config)
end

function ListView:Create(x, y, w, h, direction, item_render, gravity, is_bounce, ui_config)
	if nil ~= self.list_view then
		return
	end
	
	self.item_render = item_render
	self.width = w
	self.height = h
	self.ui_config = ui_config
	
	self.list_view = XUI.CreateListView(x or 0, y or 0, w, h, direction or ScrollDir.Vertical)
	self.list_view:setGravity(gravity or ListViewGravity.CenterHorizontal)
	self.list_view:setBounceEnabled(is_bounce or false)		
	self.list_view:addListEventListener(BindTool.Bind1(self.ListEventCallback, self))
	return self.list_view
end

-- 获得数据源
function ListView:SetDelayCreateCount(count)
	self.delay_create_count = count
end

-- 获得数据源
function ListView:GetDataList()
	return self.data_list
end

-- 设置数据源
function ListView:SetData(data_list)
	self:SetDataList(data_list)
end

-- 设置数据源
function ListView:SetDataList(data_list)
	self.jump_top_index = nil
	self.data_list = data_list
	self:RefreshCurItems()
	self:RefreshItems()
end

-- 设置自动补充空数据
function ListView:SetAutoSupply(is_auto)
	self.is_auto_supply = is_auto and true or false
end

-- 获得数据源
function ListView:GetData()
	return self.data_list
end

-- 设置选中回调函数
function ListView:SetSelectCallBack(callback)
	self.select_callback = callback
end

-- 设置刷新顺序
function ListView:SetRefreshIsAsc(refresh_is_asc)
	self.refresh_is_asc = refresh_is_asc
end

--设置是否是分步计算
function ListView:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

-- 刷新items列表
function ListView:RefreshCurItems()
	if self.data_list == nil or self.item_render == nil or self.list_view == nil then
		return
	end
	if self.refresh_is_asc then						-- 升序刷新
		for i, v in ipairs(self.items) do
			if self.data_list[i] or self.is_auto_supply then
				v:SetIndex(i)
				v:SetData(self.data_list[i])
			end
		end
	else
		for i = #self.items, 1, - 1 do
			if self.data_list[i] or self.is_auto_supply then
				self.items[i]:SetIndex(i)
				self.items[i]:SetData(self.data_list[i])
			end
		end
	end
end

-- 刷新items列表
function ListView:RefreshItems()
	if self.deley_refresh_timer
	or self.data_list == nil
	or self.item_render == nil
	or self.list_view == nil then
		return
	end
	
	local item_count = #self.items
	local data_count = #self.data_list
	
	if self.is_auto_supply and nil ~= self.ui_config then
		local min_count = 0
		if self.list_view:getScorllDirection() == ScrollDir.Vertical then
			min_count = math.ceil(self.height / self.ui_config.h)
			min_count = math.ceil((self.height -(min_count - 1) * self.list_view:getItemsInterval()) / self.ui_config.h)
		elseif self.list_view:getScorllDirection() == ScrollDir.Horizontal then
			min_count = math.ceil(self.width / self.ui_config.w)
			min_count = math.ceil((self.width -(min_count - 1) * self.list_view:getItemsInterval()) / self.ui_config.w)
		end
		if data_count < min_count then
			data_count = min_count
		end
	end
	if item_count == data_count then
		return
	end
	local max_count = math.abs(item_count - data_count)
	
	if item_count > data_count then					-- item太多 删掉
		local end_index = max_count > self.delay_create_count and item_count - self.delay_create_count + 1 or data_count + 1
		for i = item_count, end_index, - 1 do
			self:RemoveAt(i)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		local end_index = max_count > self.delay_create_count and item_count + self.delay_create_count or data_count
		for i = item_count + 1, end_index do
			item = self.item_render.New(self.width, self.height, self.list_view)
			item:SetIsUseStepCalc(self.is_use_step_calc)
			if nil ~= self.ui_config then
				item:SetUiConfig(self.ui_config, false)
			end
			table.insert(self.items, item)
			self.list_view:pushBackItem(item:GetView())
		end
		if self.refresh_is_asc then						-- 升序刷新
			for i = item_count + 1, end_index do
				self.items[i]:SetIndex(i)
				self.items[i]:SetData(self.data_list[i])
			end
		else
			for i = end_index, item_count + 1, - 1 do
				self.items[i]:SetIndex(i)
				self.items[i]:SetData(self.data_list[i])
			end
		end
	end
	if max_count > self.delay_create_count then
		self.deley_refresh_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.deley_refresh_timer = nil
			self:RefreshItems()
		end, 0.1)
	end
end

function ListView:AddItemAt(item, index)
	if item ~= nil then
		table.insert(self.items, index, item)
		self.list_view:insertItem(item:GetView(), index - 1)
	end
end

function ListView:AddItem(item)
	table.insert(self.items, item)
	self.list_view:pushBackItem(item:GetView())
end

function ListView:RemoveAt(index)
	if index <= 0 then
		return
	end
	
	local item = self:GetItemAt(index)
	if nil == item then
		return
	end
	
	if self.cur_select_item == item then
		self.cur_select_item = nil
	end
	
	self.list_view:removeItemByIndex(index - 1)
	item:DeleteMe()
	
	table.remove(self.items, index)
end

function ListView:RemoveItem(item)
	self:RemoveAt(self:GetItemIndex(item))
end

-- 获得某个索引下的item
function ListView:GetItemAt(index)
	return self.items[index]
end

-- 获得item在列表中的索引
function ListView:GetItemIndex(item)
	for k, v in pairs(self.items) do
		if v == item then
			return k
		end
	end
	
	return - 1
end

function ListView:GetAllItems()
	return self.items
end

-- 清除所有item
function ListView:RemoveAllItem()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
	self.cur_select_item = nil
	self.list_view:removeAllItems()
end

-- 设置当前选中index，有回调
function ListView:SelectIndex(index)
	self:SetSelectItem(self:GetItemAt(index), index)
	
	if self.select_callback ~= nil then
		self.select_callback(self.cur_select_item, index)
	end
end

-- 设置当前选中index，无回调
function ListView:ChangeToIndex(index)
	self:SetSelectItem(self:GetItemAt(index), index)
end

--设置当前选中item
function ListView:SetSelectItem(item, index)
	if self.cur_select_item ~= item then
		if self.cur_select_item ~= nil then
			self.cur_select_item:SetSelect(false)
		end
		
		self.cur_select_item = item
		
		if self.cur_select_item ~= nil then	
			self.cur_select_item:SetSelect(true)
		end
	end
end

--获得当前选择的item
function ListView:GetSelectItem()
	return self.cur_select_item
end

--获得当前选择的index
function ListView:GetSelectIndex()
	return self.list_view:getCurIndex() + 1
end

--list事件回调
function ListView:ListEventCallback(sender, event_type, index)
	if event_type == XuiListEventType.Ended then
		self:SelectIndex(index + 1)
	elseif event_type == XuiListEventType.Refresh then
		self:AutoJump()
	end
	
	local item = self:GetItemAt(index + 1)
	if nil ~= item then
		item:OnListEvent(event_type)
	end
	if self.list_event_call then
		self.list_event_call(sender, event_type, index)
	end
end

--list事件回调
function ListView:AddListEventListener(list_event_call)
	self.list_event_call = list_event_call
end

-- 第index项置顶
function ListView:SetSelectItemToTop(index)
	if index <= 0 or nil == self.list_view or #self.items <= 0 then
		return
	end
	
	self.jump_top_index = index
	local item_node = self.list_view:getItem(index - 1)
	if nil == item_node then
		return
	end
	
	local inner_pos = self.list_view:getInnerPosition()
	inner_pos.y = self.list_view:getContentSize().height -(item_node:getPositionY() + item_node:getContentSize().height / 2)
	if 1 == index then
		inner_pos.y = inner_pos.y - self.list_view:getMargin()
	else
		inner_pos.y = inner_pos.y - self.list_view:getItemsInterval() / 2
	end
	if inner_pos.y > 0 then
		inner_pos.y = 0
	end
	self.list_view:jumpToPosition(inner_pos)
end

-- 第index项置左
function ListView:SetSelectItemToLeft(index)
	if not index or index <= 0 or nil == self.list_view or #self.items <= 0 then
		return
	end
	local item_node = self.list_view:getItem(index - 1)
	if nil == item_node then
		return
	end
	local item_size = item_node:getContentSize()
	local show_max = self.list_view:getContentSize().width / (item_size.width + self.list_view:getItemsInterval())
	index = math.min(math.max(index, 1), #self.items - show_max + 1)
	local inner_pos = cc.p((1 - index) * (item_size.width + self.list_view:getItemsInterval()), self.list_view:getInnerPosition().y)
	self.list_view:jumpToPosition(inner_pos)
end

-- 取消选中
function ListView:CancelSelect()
	if nil ~= self.cur_select_item then
		self.cur_select_item:SetSelect(false)
		self.cur_select_item = nil
	end
end

-- 首尾留空
function ListView:SetMargin(margin)
	self.list_view:setMargin(margin)
end

-- 单元间隔
function ListView:SetItemsInterval(interval)
	self.list_view:setItemsInterval(interval)
end

--布局 默认水平居中
function ListView:SetGravity(gravity)
	self.list_view:setGravity(gravity or ListViewGravity.CenterHorizontal)
end

-- 获取item数量
function ListView:GetCount()
	return #self.items
end

-- 移动第一条到最后
function ListView:MoveFrontToLast()
	if #self.items <= 1 then
		return
	end
	
	local item_node = self.list_view:getItem(0)
	if nil == item_node then
		return
	end
	
	item_node:retain()
	self.list_view:removeItem(0)
	self.list_view:pushBackItem(item_node)
	item_node:release()
	
	local item = table.remove(self.items, 1)
	table.insert(self.items, item)
end

function ListView:JumpToTop(need_refresh)
	if need_refresh then
		self.list_view:refreshView()
	end
	self.list_view:jumpToTop()
end

-- 设置跳转方向，设置之后每次刷新都会自动跳转
function ListView:SetJumpDirection(jump_direction)
	self.jump_direction = jump_direction
	self:AutoJump()
end

-- 自动跳转，SetJumpDirection之后才有效
function ListView:AutoJump()
	if nil == self.list_view then
		return
	end
	
	if nil ~= self.jump_top_index then
		self:SetSelectItemToTop(self.jump_top_index)
		return
	end
	
	if self.jump_direction == ListView.Top then
		self.list_view:jumpToTop()
	elseif self.jump_direction == ListView.Right then
		self.list_view:jumpToRight()
	elseif self.jump_direction == ListView.Bottom then
		self.list_view:jumpToBottom()
	elseif self.jump_direction == ListView.Left then
		self.list_view:jumpToLeft()
	end
end

function ListView:ListMoveVertical(btn_top_node, btn_bottom_node, dis)
	self.btn_top_node = btn_top_node
	self.btn_bottom_node = btn_bottom_node
	self.dis = dis or 100
	XUI.AddClickEventListener(self.btn_top_node, BindTool.Bind2(self.OnlickHandler, self, true))
	XUI.AddClickEventListener(self.btn_bottom_node, BindTool.Bind2(self.OnlickHandler, self, false))
	self:CheckButtonVisible()
end

function ListView:OnlickHandler(is_top)
	local inner_pos = self.list_view:getInnerPosition()
	local move_to_posy = 0
	if is_top then
		move_to_posy = inner_pos.y - self.dis
	else
		move_to_posy = inner_pos.y + self.dis
	end
	self:CheckButtonVisible()
	self.list_view:scrollToPositionY(move_to_posy, 0.3, false)
end

function ListView:CheckButtonVisible()
	if self.btn_top_node == nil or self.btn_bottom_node == nil then return end
	local inner_size = self.list_view:getInnerContainerSize()
	local content_size = self.list_view:getContentSize()
	local limit_pos = content_size.height - inner_size.height
	local inner_pos = self.list_view:getInnerPosition()
	self.btn_top_node:setVisible(inner_pos.y > limit_pos)
	self.btn_bottom_node:setVisible(inner_pos.y < - 1)
end 

-- 居中处理
-- line_count-行数 仅用于判断尺寸
-- ignore_size-忽略大小   true-忽略大小   false或nil-不忽略大小
function ListView:SetCenter(line_count, ignore_size)
	line_count = line_count or 1
	local view = self.list_view
	local size = view:getContentSize()
	local inner_size = cc.size(size.width, size.height)
	local interval = view:getItemsInterval() --item之间的间隔
	local margin = view:getMargin() -- 首尾留空

	-- 纵向滑动时,居中纵向位置
	if view:getScorllDirection() == ScrollDir.Vertical then
		local line = math.ceil(#self.items / line_count)
		inner_size.height = line * (self.ui_config.h + interval) - interval

		local height = inner_size.height + margin * 2
		if ignore_size then	-- 忽略大小
			size.height = height
		else			
			size.height = math.min(self.height, height)
		end
	else
	-- 其它滑动方向,居中横向位置
		local line = math.ceil(#self.items / line_count)
		inner_size.width = line * (self.ui_config.w + interval) - interval

		local width = inner_size.width + margin * 2
		if ignore_size then	-- 忽略大小
			size.width = width
		else			
			size.width = math.min(self.width, width)
		end
	end

	view:setContentSize(size)
	view:setInnerContainerSize(inner_size)
	view:jumpToTop()
end