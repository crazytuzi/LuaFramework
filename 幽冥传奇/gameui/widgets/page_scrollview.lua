-----------------
--副本带放大动作的翻页滚动scrolllview控件
----------------
PageScrollView = PageScrollView or BaseClass()
function PageScrollView:__init()	
	self.scroll_view = nil
	self.item_scale = 1
	self.items = {}
	self.cur_select_index = nil
	self.cur_select_item = nil

	self.data_list = {}
	self.select_callback = nil
	self.refresh_is_asc = true
	self.is_use_step_calc = true 					-- 默认使用分步计算

	self.off_pos = {x = 0, y = 0}
end

function PageScrollView:__delete()
	
end

function PageScrollView:SetCellScale(scale)
	self.item_scale = scale
end

function PageScrollView:GetOffSize(index)
	return index % 2 == 0 and 20 or 0
end

--{t.x, t.y, t.w, t.h, t.cell_count, t.item_scale, t.itemRender, t.direction, t.ui_config}
function PageScrollView:CreateView(t)
	self.item_scale = t.item_scale
	self.direction = t.direction
	self.width = t.w
	self.height = t.h
	self.item_render = t.itemRender
	self.ui_config = t.ui_config

	self.view = XUI.CreateLayout(t.x, t.y, t.w, t.h)

	self.touch_layout = XUI.CreateLayout(t.w / 2, t.h / 2, t.w, t.h)
	self.touch_layout:setTouchEnabled(true)
	self.view:addChild(self.touch_layout)
	self.touch_layout:addTouchEventListener(BindTool.Bind(self.OnScrollTouchListener, self))

	self.scroll_view = XUI.CreateScrollView(t.w / 2, t.h / 2, t.w, t.h, t.direction)
	self.scroll_view:setTouchEnabled(false)	--不知为何设置这个没用，上面的事件还是传递了下来
	self.view:addChild(self.scroll_view)
end

function PageScrollView:SetTouchEnabled(is_enabled)
	self.touch_layout:setTouchEnabled(is_enabled)
	self.touch_layout_former:setTouchEnabled(is_enabled)
	self.touch_layout_next:setTouchEnabled(is_enabled)
end

function PageScrollView:SetClickPageChange(is_click_change)
	if is_click_change then
		self.touch_layout:setContentWH(self.ui_config.w, self.ui_config.h)

		if nil == self.touch_layout_former then
			if ScrollDir.Vertical == self.direction then
				local layout_height = (self.height - self.ui_config.h) / 2
				self.touch_layout_former = XUI.CreateLayout(self.width / 2, self.height - layout_height / 2, self.ui_config.w * self.item_scale, layout_height)
			else
				local layout_width = (self.width - self.ui_config.w) / 2
				self.touch_layout_former = XUI.CreateLayout(layout_width / 2, self.height / 2, layout_width, self.ui_config.h * self.item_scale)
			end
			self.view:addChild(self.touch_layout_former)
			self.touch_layout_former:addTouchEventListener(BindTool.Bind(self.OnScrollChangePageFormer, self))
		end
		self.touch_layout_former:setTouchEnabled(true)

		if nil == self.touch_layout_next then
			if ScrollDir.Vertical == self.direction then
				local layout_height = (self.height - self.ui_config.h) / 2
				self.touch_layout_next = XUI.CreateLayout(self.width / 2, layout_height / 2, self.ui_config.w * self.item_scale, layout_height)
			else
				local layout_width = (self.width - self.ui_config.w) / 2
				self.touch_layout_next = XUI.CreateLayout(self.width - layout_width / 2, self.height / 2, layout_width, self.ui_config.h * self.item_scale)
			end
			self.view:addChild(self.touch_layout_next)
			self.touch_layout_next:addTouchEventListener(BindTool.Bind(self.OnScrollChangePageNext, self))
		end
		self.touch_layout_next:setTouchEnabled(true)
	else
		self.touch_layout:setContentWH(self.width, self.height)
		if self.touch_layout_former then
			self.touch_layout_former:setTouchEnabled(false)
		end
		if self.touch_layout_next then
			self.touch_layout_next:setTouchEnabled(false)
		end
	end
end

function PageScrollView:OnScrollChangePageFormer(sender, event_type, touch)
	if event_type == XuiTouchEventType.Ended then
		self:ScrollToPage(self.cur_select_index - 1)
	end
end

function PageScrollView:OnScrollChangePageNext(sender, event_type, touch)
	if event_type == XuiTouchEventType.Ended then
		self:ScrollToPage(self.cur_select_index + 1)
	end
end

function PageScrollView:OnScrollTouchListener(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self:OnScrollTouchBegan(sender, event_type, touch)
	elseif event_type == XuiTouchEventType.Moved then
		self:OnScrollTouchMoved(sender, event_type, touch)
	elseif event_type == XuiTouchEventType.Ended then
		self:OnScrollTouchEnded(sender, event_type, touch)
	elseif event_type == XuiTouchEventType.Canceled then
		self:OnScrollTouchEnded(sender, event_type, touch)
	end
end

function PageScrollView:OnScrollTouchBegan(sender, event_type, touch)
	self.touch_began_pose = sender:convertToNodeSpace(touch:getLocation())
	self.inner_begen_pose = self.scroll_view:getInnerPosition()
end

function PageScrollView:OnScrollTouchMoved(sender, event_type, touch)
	local pre_pos = sender:convertToNodeSpace(touch:getPreviousLocation())
	local cur_pos = sender:convertToNodeSpace(touch:getLocation())
	local start_pos = sender:convertToNodeSpace(touch:getStartLocation())

	local move_pos = {}
	move_pos.x = cur_pos.x - pre_pos.x
	move_pos.y = cur_pos.y - pre_pos.y

	local front_pos = self:GetPagePos(math.max(self.cur_select_index - 1, 1))
	local next_pos = self:GetPagePos(math.min(#self.data_list, self.cur_select_index + 1))

	local move_distance = 0
	local total_distance = 0

	local to_pos = self.inner_begen_pose
	if ScrollDir.Vertical == self.direction then
		to_pos.y = to_pos.y + move_pos.y
		to_pos.y = to_pos.y < front_pos.y and front_pos.y or to_pos.y
		to_pos.y = to_pos.y > next_pos.y and next_pos.y or to_pos.y
		move_distance = cur_pos.y - start_pos.y
		total_distance = self.ui_config.h + self.ui_config.h * self.item_scale
	else
		to_pos.x = to_pos.x + move_pos.x
		to_pos.x = to_pos.x > front_pos.x and front_pos.x or to_pos.x
		to_pos.x = to_pos.x < next_pos.x and next_pos.x or to_pos.x
		move_distance = cur_pos.x - start_pos.x
		total_distance = self.ui_config.w + self.ui_config.w * self.item_scale
	end
	if total_distance == 0 then
		ErrorLog("total_distance == 0 !!!")
		return
	end
	--放大缩小倍数
	local scale_to_big = self.item_scale + (1 - self.item_scale) * ( math.abs(move_distance) / total_distance)
	scale_to_big = math.min(scale_to_big, 1)
	local scale_to_small = 1 - (1 - self.item_scale) * (math.abs(move_distance) / total_distance)
	scale_to_small = math.max(scale_to_small, self.item_scale)

	--重设锚点位置等等
	if ScrollDir.Vertical == self.direction then
		if move_distance < 0 then
			local font_item = self:GetItemAt(self.cur_select_index - 1)
			if nil == font_item then
				return
			end
			font_item:GetView():setScale(scale_to_big)
			local cur_item = self:GetItemAt(self.cur_select_index)
			cur_item:GetView():setAnchorPoint(0.5, 0)
			cur_item:GetView():setPosition(self.width / 2, (#self.data_list - self.cur_select_index + 1) * self.item_scale * self.ui_config.h)
			cur_item:GetView():setScale(scale_to_small)
		else
			local next_item = self:GetItemAt(self.cur_select_index + 1)
			if nil == next_item then
				return
			end
			next_item:GetView():setScale(scale_to_big)
			local cur_item = self:GetItemAt(self.cur_select_index)
			cur_item:GetView():setAnchorPoint(0.5, 1)
			cur_item:GetView():setPosition(self.width / 2, (#self.data_list - self.cur_select_index + 1) * self.item_scale * self.ui_config.h + self.ui_config.h)
			cur_item:GetView():setScale(scale_to_small)
		end
	else
		if move_distance > 0 then
			local font_item = self:GetItemAt(self.cur_select_index - 1)
			if nil == font_item then
				return
			end
			font_item:GetView():setScale(scale_to_big)
			local cur_item = self:GetItemAt(self.cur_select_index)
			cur_item:GetView():setAnchorPoint(1, 0.5)
			cur_item:GetView():setPosition(self.cur_select_index * self.item_scale * self.ui_config.w + self.ui_config.w, self.height / 2)
			cur_item:GetView():setScale(scale_to_small)
		else
			local next_item = self:GetItemAt(self.cur_select_index + 1)
			if nil == next_item then
				return
			end
			next_item:GetView():setScale(scale_to_big)
			local cur_item = self:GetItemAt(self.cur_select_index)
			cur_item:GetView():setAnchorPoint(0, 0.5)
			cur_item:GetView():setPosition(self.cur_select_index * self.item_scale * self.ui_config.w, self.height / 2)
			cur_item:GetView():setScale(scale_to_small)
		end
	end

	self.scroll_view:jumpToPosition(to_pos)
end

function PageScrollView:OnScrollTouchEnded(sender, event_type, touch)
	local end_pos = sender:convertToNodeSpace(touch:getLocation())
	local pre_pos = sender:convertToNodeSpace(touch:getStartLocation())

	local delta_pos = {}
	delta_pos.x = end_pos.x - self.touch_began_pose.x
	delta_pos.y = end_pos.y - self.touch_began_pose.y

	--翻到过半或者速度够快就可以翻页
	local next_page_index = self.cur_select_index
	if ScrollDir.Vertical == self.direction then
		if delta_pos.y < -self.ui_config.h / 2  or end_pos.y - pre_pos.y < -self.ui_config.h / 4 then
			next_page_index = next_page_index - 1
		elseif delta_pos.y > self.ui_config.h / 2 or end_pos.y - pre_pos.y > self.ui_config.h / 4 then
			next_page_index = next_page_index + 1
		end
	else
		if delta_pos.x < -self.ui_config.w / 2 or end_pos.x - pre_pos.x < -self.ui_config.w / 4 then
			next_page_index = next_page_index + 1
		elseif delta_pos.x > self.ui_config.w / 2 or end_pos.x - pre_pos.x > self.ui_config.w / 4 then
			next_page_index = next_page_index - 1
		end
	end
	self:ScrollToPage(next_page_index, delta_pos)
end

function PageScrollView:GetView()
	return self.view
end

-- 获得数据源
function PageScrollView:GetDataList()
	return self.data_list
end

-- 设置数据源
function PageScrollView:SetDataList(data_list)
	self.data_list = data_list
	self:RefreshItems()
end

-- 设置选中回调函数
function PageScrollView:SetSelectCallBack(callback)
	self.select_callback = callback
end

-- 设置刷新顺序
function PageScrollView:SetRefreshIsAsc(refresh_is_asc)
	self.refresh_is_asc = refresh_is_asc
end

--设置是否是分步计算
function PageScrollView:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

-- 刷新items列表
function PageScrollView:RefreshItems()
	if self.data_list == nil or self.item_render == nil or self.scroll_view == nil then
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
			item:SetIsUseStepCalc(self.is_use_step_calc)
			if nil ~= self.ui_config then
				item:SetUiConfig(self.ui_config, false)
			end
			table.insert(self.items, item)
			self.scroll_view:addChild(item:GetView())
		end
	end

	if ScrollDir.Vertical == self.direction then
		self.scroll_view:setInnerContainerSize(cc.size(self.width, (data_count + 1) * self.item_scale * self.ui_config.h + self.ui_config.h))
	else
		self.scroll_view:setInnerContainerSize(cc.size((data_count + 1) * self.item_scale * self.ui_config.w + self.ui_config.w, self.height))
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
	if nil == self.cur_select_index then
		self.cur_select_index = 1
		self:JumpToPage(self.cur_select_index)
	end
end

function PageScrollView:RemoveAt(index)
	if index <= 0 then
		return
	end

	local item = self:GetItemAt(index)
	if nil == item then
		return
	end

	item:GetView():removeFromParent()
	item:DeleteMe()

	table.remove(self.items, index)
end

-- 获得某个索引下的item
function PageScrollView:GetItemAt(index)
	return self.items[index]
end

--外部不能调用这个方法请用JumpToPage
function PageScrollView:ScrollToPage(index, delta_pos)
	if index < 1 or index > #self.data_list then
		return
	end
	self.scroll_to_index = index
	self.scroll_view:scrollToPosition(self:GetPagePos(index), 0.2, false)

	--缩小的item
	local item_to_small = nil
	if index ~= self.cur_select_index then --如果已经翻页
		item_to_small = self:GetItemAt(self.cur_select_index)
	else
		if ScrollDir.Vertical == self.direction then
			if delta_pos.y < 0 then
				item_to_small = self:GetItemAt(self.cur_select_index - 1)
			else
				item_to_small = self:GetItemAt(self.cur_select_index + 1)
			end
		else
			if delta_pos.x < 0 then
				item_to_small = self:GetItemAt(self.cur_select_index + 1)
			else
				item_to_small = self:GetItemAt(self.cur_select_index - 1)
			end
		end
	end
	if nil == item_to_small then
		return
	end
	local scale_to_s = cc.ScaleTo:create(0.2, self.item_scale, self.item_scale)
	item_to_small:GetView():runAction(scale_to_s)

	--放大的item
	local scale_to_b = cc.ScaleTo:create(0.2, 1, 1)
	local call_back_b = cc.CallFunc:create(function()
		self.cur_select_index = self.scroll_to_index
		self:SelectIndex(self.cur_select_index)
	end)
	local sequence = cc.Sequence:create(scale_to_b, call_back_b)
	local item_to_big = self:GetItemAt(self.scroll_to_index)
	item_to_big:GetView():runAction(sequence)
end

function PageScrollView:JumpToPage(index)
	if index < 1 or index > #self.data_list then
		return
	end
	self.scroll_view:jumpToPosition(self:GetPagePos(index))
	self.cur_select_index = index
	self:SelectIndex(self.cur_select_index)
end

function PageScrollView:GetPagePos(index)
	local pos = cc.p(0, 0)
	if ScrollDir.Vertical == self.direction then
		pos.y = - ((#self.data_list - index + 1) * self.item_scale * self.ui_config.h + self.ui_config.h / 2 - self.height / 2)
	else
		pos.x = -(self.item_scale * self.ui_config.w * index + self.ui_config.w / 2 - self.width / 2)
	end
	return pos
end

function PageScrollView:SelectIndex(index)
	self:SetSelectItem(self:GetItemAt(index), index)

	if self.select_callback ~= nil then
		self.select_callback(self.cur_select_item, index)
	end
end

--设置当前选中item
function PageScrollView:SetSelectItem(item, index)
	if self.cur_select_item ~= item then
		if self.cur_select_item ~= nil then
			self.cur_select_item:SetSelect(false)
		end

		self.cur_select_item = item

		if self.cur_select_item ~= nil then	
			self.cur_select_item:SetSelect(true)
		end
	end
	self:ReCalculateItemPos()
end

function PageScrollView:ReCalculateItemPos()
	local data_count = #self.data_list
	for i,v in ipairs(self.items) do
		if ScrollDir.Vertical == self.direction then
			if i > self.cur_select_index then
				v:GetView():setAnchorPoint(0.5, 0)
				v:GetView():setScale(self.item_scale)
				v:GetView():setPosition(self.width / 2, (data_count - i + 1) * self.item_scale * self.ui_config.h)
			elseif i == self.cur_select_index then
				v:GetView():setAnchorPoint(0.5, 0.5)
				v:GetView():setScale(1)
				v:GetView():setPosition(self.width / 2, (data_count - i + 1) * self.item_scale * self.ui_config.h + self.ui_config.h / 2)
			elseif i < self.cur_select_index then
				v:GetView():setAnchorPoint(0.5, 1)
				v:GetView():setScale(self.item_scale)
				v:GetView():setPosition(self.width / 2, (data_count - i + 1) * self.item_scale * self.ui_config.h + self.ui_config.h)
			end
		else
			if i > self.cur_select_index then
				v:GetView():setAnchorPoint(1, 0.5)
				v:GetView():setScale(self.item_scale)
				v:GetView():setPosition(i * self.item_scale * self.ui_config.w + self.ui_config.w, self.height / 2)
			elseif i == self.cur_select_index then
				v:GetView():setAnchorPoint(0.5, 0.5)
				v:GetView():setScale(1)
				v:GetView():setPosition(i * self.item_scale * self.ui_config.w + self.ui_config.w / 2, self.height / 2)
			elseif i < self.cur_select_index then
				v:GetView():setAnchorPoint(0, 0.5)
				v:GetView():setScale(self.item_scale)
				v:GetView():setPosition(i * self.item_scale * self.ui_config.w, self.height / 2)
			end
		end
	end
end
