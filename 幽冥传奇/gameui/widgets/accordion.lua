-----------------------------------------------------
--手风琴控件，定制节点请继承AccordionItemRender
--注：以下index从1开始
-----------------------------------------------------
Accordion = Accordion or BaseClass()
Accordion.ActionTime = 0.2

function Accordion:__init()
	self.view = nil
	self.width = 370
	self.height = 550
	self.data = nil
	self.items = {}									-- {{item = item, childs={}}, }
	self.item_render = nil							-- 节点渲染器
	self.def_tree_index = nil
	self.def_child_index = nil

	self.total_height = 0
	self.is_tween = true							-- 是否缓动移动
	self.cur_tree_index = 0							-- 当前展开的节点index	
	self.select_child_index	= 0						-- 当前选择的子节点index


	self.expand_callback = nil						-- 展开树节点回调
	self.unexpand_callback = nil					-- 折叠树节点回调
	self.select_callback = nil						-- 选择子节点回调
	self.select_tree_callback = nil 				-- 选择数节点回调

	self.is_use_step_calc = true 					-- 是否使用分步式计算
	self.interval = 0 								--间隔
end

function Accordion:__delete()
	self.view = nil
	self.data = nil

	for k, v in pairs(self.items) do
		for k2, v2 in pairs(v.childs) do
			v2:DeleteMe()
		end
		v.item:DeleteMe()
	end
	self.items = {}
end

function Accordion:GetView()
	return self.view
end

--创建视图 {width = 370, height = 550, itemRender = AccordionItemRender, tree_index = 0}
function Accordion:CreateView(param)
	if nil == param then
		return nil
	end

	return self:Create(0, 0, param.width, param.height, param.itemRender, param.tree_index, param.child_index, param.tree_ui_config, param.child_ui_config, param.tree_height, param.child_height, param.child_x, param.child_y_down)
end

-- @item_render 节点渲染器
-- @tree_index 默认展开的树索引
-- @child_index 默认选中的子节点
-- @tree_ui_config 树节点UI
-- @child_ui_config 子节点UI
-- @tree_height 树节点高度
-- @child_height 子节点高度
-- @child_x 子节点x坐标 默认居中
-- @child_y_down 子节点下调 避免子节点紧挨着树节点
function Accordion:Create(x, y, w, h, item_render, tree_index, child_index, tree_ui_config, child_ui_config, tree_height, child_height, child_x, child_y_down)
	self.width = w
	self.height = h
	self.item_render = item_render
	self.def_tree_index = tree_index
	self.def_child_index = child_index
	self.tree_ui_config = tree_ui_config
	self.child_ui_config = child_ui_config
	self.tree_height = tree_height or tree_ui_config.h + 5
	self.child_height = child_height or child_ui_config.h + 4
	self.child_x = child_x or ( tree_ui_config.x) / 2
	self.child_y_down = child_y_down or 4

	self.view = XUI.CreateScrollView(x, y, w, h, ScrollDir.Vertical)
	self.view:setAnchorPoint(0, 0)
	return self.view
end

--设置数据源：结构为
--{
--{name="tree1", child={data1, data2, data3}},
--{name="tree1", child={data1, data2, data3}},}
function Accordion:SetData(data)
	if nil == data or nil == self.item_render then
		return
	end

	self:RemoveAll()
	self.data = data
	self:CreatNodes()

	if nil ~= self.def_tree_index then
		self:SetSelectChildIndex(self.def_child_index or 0, self.def_tree_index, false)
	end
end

function Accordion:SetIsTween(is_tween)
	self.is_tween = is_tween
end

function Accordion:FlushExpandItems()
	local tree = self.items[self.cur_tree_index]
	if nil ~= tree then
		for i, v in ipairs(tree.childs) do
			v:Flush()
		end
	end
end

--创建树节点
function Accordion:CreatNodes()
	-- self.total_height = 0

	-- for i, v in ipairs(self.data) do
	-- 	local item = self.item_render.New(self.width, self.tree_height)
	-- 	item:SetIndex(i)
	-- 	item:SetAnchorPoint(0, 1)
	-- 	item:CreateChildView()
	-- 	item:GetChildView():setVisible(false)
	-- 	item:SetIsUseStepCalc(self.is_use_step_calc)
	-- 	item:SetData(v)
	-- 	item:AddClickEventListener(BindTool.Bind1(self.OnClickItem, self))
	-- 	if nil ~= self.tree_ui_config then
	-- 		item:SetUiConfig(self.tree_ui_config, false)
	-- 	end
	-- 	self.view:addChild(item:GetView())
	-- 	table.insert(self.items, {["item"] = item, childs = {}})

	-- 	self.total_height = self.total_height + item:GetHeight()
	-- end

	-- self.total_height = math.max(self.height, self.total_height + 1)
	-- self.view:setInnerContainerSize(cc.size(self.width, self.total_height))
	-- local tree_offset_y = self.total_height - 1

	-- for i, v in ipairs(self.data) do
	-- 	local tree = self.items[i]
	-- 	local item = tree.item
	-- 	item:SetPosition(0, tree_offset_y)
	-- 	item:SetTargetY(tree_offset_y)
	-- 	tree_offset_y = tree_offset_y - item:GetHeight()

	-- 	local childs_height = 0
	-- 	for i2, v2 in ipairs(v.child) do
	-- 		local child = self.item_render.New(self.width, self.child_height)
	-- 		child:SetIndex(i2)
	-- 		child:SetAnchorPoint(0, 1)
	-- 		child:SetIsUseStepCalc(self.is_use_step_calc)
	-- 		child:SetData(v2)
	-- 		child:AddClickEventListener(BindTool.Bind1(self.OnClickItem, self))
	-- 		if nil ~= self.child_ui_config then
	-- 			child:SetUiConfig(self.child_ui_config, false)
	-- 		end

	-- 		item:GetChildView():addChild(child:GetView())
	-- 		table.insert(tree.childs, child)

	-- 		childs_height = childs_height + child:GetHeight()
	-- 	end

	-- 	item:GetChildView():setContentWH(self.width, childs_height)

	-- 	local child_offset_y = childs_height
	-- 	for i2, v2 in ipairs(tree.childs) do
	-- 		v2:SetPosition(self.child_x, child_offset_y - self.child_y_down)
	-- 		v2:SetTargetY(child_offset_y)
	-- 		child_offset_y = child_offset_y - v2:GetHeight()
	-- 	end
	-- end

	-- self.view:jumpToTop()
	self:RefreshItemsCount()
	self:InitViewShow()
end


function Accordion:RefreshItemsCount()
	local item_count = #self.items
	self.total_count = #self.data
	if item_count > self.total_count then -- 多则删除
		local end_index = self.total_count + 1
		for i = item_count, end_index, -1 do
			self:RemoveAt(i)
		end
	else 					-- 少则创建
		local end_index = self.total_count
		local item, v = nil
		for i = item_count + 1, end_index, 1 do
			v = self.data[i]
			item = self.item_render.New(self.width, self.tree_height)
			item:SetIndex(i)
			item:SetAnchorPoint(0, 1)
			item:CreateChildView()
			item:GetChildView():setVisible(false)
			item:SetIsUseStepCalc(self.is_use_step_calc)
			item:AddClickEventListener(BindTool.Bind1(self.OnClickItem, self))
			if nil ~= self.tree_ui_config then
				item:SetUiConfig(self.tree_ui_config, false)
			end
			self.view:addChild(item:GetView())
			table.insert(self.items, {["item"] = item, childs = {}})
		end
	end
end

function Accordion:InitViewShow()
	self:SetScrollViewInnerHeight()
	self:SetItemsDataAndPosition()

	self:SetSelectChildIndex(0, 0, false)
	self.view:jumpToTop()
end

function Accordion:SetScrollViewInnerHeight()
	self.total_height = 0
	for i, v in ipairs(self.data) do
		item = self.items[i].item
		self.total_height = self.total_height + item:GetHeight() + self.interval
	end
	self.total_height = math.max(self.height, self.total_height)
	self.orig_total_height = self.total_height
end

function Accordion:SetItemsDataAndPosition()
	local tree_offset_y = self.total_height
	for i, v in ipairs(self.data) do
		local tree = self.items[i]
		local item = tree.item
		item:SetData(v)
		item:SetPosition(0, tree_offset_y)
		item:SetTargetY(tree_offset_y)
		tree_offset_y = tree_offset_y - item:GetHeight() - self.interval
		local childs_height = 0
		for i2, v2 in ipairs(v.child) do
			local child = item:GetChildNodeByIndex(i2)
			if not child then
				child = self.item_render.New(self.width, self.child_height)
				child:SetIndex(i2)
				child:SetAnchorPoint(0, 1)
				child:SetIsUseStepCalc(self.is_use_step_calc)
				child:AddClickEventListener(BindTool.Bind1(self.OnClickItem, self))
				item:GetChildView():addChild(child:GetView())
				item:PushBackChildNode(child)
				table.insert(tree.childs, child)
				if nil ~= self.child_ui_config then
					child:SetUiConfig(self.child_ui_config, false)
				end
			end
			child:SetData(v2)
			childs_height = childs_height + child:GetHeight()
		end
		item:GetChildView():setContentWH(self.width, childs_height)
		local child_offset_y = childs_height
		for i2, v2 in ipairs(tree.childs) do
			-- :SetPosition(self.child_x, child_offset_y - self.child_y_down)
			v2:SetPosition(self.child_x, child_offset_y- self.child_y_down)
			v2:SetTargetY(child_offset_y)
			child_offset_y = child_offset_y - v2:GetHeight()
		end
	end
end

-- 选中某项并置顶
-- @child_index 子节点索引。
-- @tree_index 树节点索引。没有设置时认是当前树节点下
function Accordion:SetSelectItemToTop(child_index, tree_index)
	tree_index = tree_index or self.cur_tree_index
	self:SetSelectChildIndex(child_index, tree_index)

	self:SetItemToTop(child_index, tree_index)
end

-- 将某一项置顶
function Accordion:SetItemToTop(child_index, tree_index)
	tree_index = tree_index or self.cur_tree_index
	local tree = self.items[tree_index]
	if nil == tree then
		return
	end

	local tree_item = tree.item
	local y = tree_item:GetTargetY()

	if nil ~= child_index then
		local child_item = tree.childs[child_index]
		if nil ~= child_item then
			y = y - tree_item:GetHeight()
			y = y - (tree_item:GetChildView():getContentSize().height - child_item:GetTargetY())
		end
	end

	y = math.min(self.height - y, 0)
	self.view:jumpToPosition(cc.p(0, y))
end

-- 展开树节点，从1开始。0时全关闭
function Accordion:SetExpandByIndex(index, is_tween)
	if self.cur_tree_index == index then
		return
	end
	local tree_item = self:GetCurTreeNode()
	if tree_item ~= nil then
		if self.unexpand_callback ~= nil then
			self.unexpand_callback(tree_item)
		end
		tree_item:SetSelect(false)
		tree_item:GetChildView():setVisible(false)
	end

	self:CancelSelectState()

	self.cur_tree_index = index

	local tree_item = self:GetCurTreeNode()
	if tree_item ~= nil then
		tree_item:SetSelect(true)
		tree_item:GetChildView():setVisible(false)
	end

	if nil == is_tween then is_tween = self.is_tween end
	self:UpdateTreeNodePos(is_tween)

	if self.expand_callback ~= nil and tree_item ~= nil then
		self.expand_callback(tree_item)
	end
end

-- 选择当前子节点
-- @child_index 子节点索引。
-- @tree_index 树节点索引。没有设置时认是当前树节点下
function Accordion:SetSelectChildIndex(child_index, tree_index, is_tween)
	tree_index = tree_index or self.cur_tree_index
	self:SetExpandByIndex(tree_index, is_tween)		-- 当前树节点

	local item = self:GetCurChidNode()
	if nil ~= item then
		item:SetSelect(false)
	end


	self.select_child_index = child_index

	item = self:GetCurChidNode()
	if nil ~= item then
		item:SetSelect(true)
		if self.select_callback ~= nil then
			self.select_callback(item)
		end
	end
end

-- 取消选中效果
function Accordion:CancelSelectState()
	if self:GetCurChidNode() ~= nil then
		self:GetCurChidNode():SetSelect(false)
	end
	self.select_child_index = 0
end

--更新节点位置
function Accordion:UpdateTreeNodePos(is_tween)
	local total_height = 0
	local cur_tree_item = nil

	-- 计算总高度
	for i, v in ipairs(self.items) do
		total_height = total_height + v.item:GetHeight()
		if self.cur_tree_index == v.item:GetIndex() then
			cur_tree_item = v.item
			total_height = total_height + v.item:GetChildView():getContentSize().height
		end
	end
	total_height = math.max(self.height, total_height + 1)

	local inner_y = self.view:getInnerPosition().y
	local new_inner_y = math.min(inner_y + self.total_height - total_height, 0)

	-- 调整内部节点位置
	local tree_offset_y = total_height
	for i, v in ipairs(self.items) do
		-- 树节点位置
		v.item:SetTargetY(tree_offset_y)
		v.item:GetView():stopAllActions()
		if is_tween then
			local new_y = v.item:GetView():getPositionY() - (new_inner_y - inner_y)
			v.item:SetPosition(0, new_y)
			if new_y ~= tree_offset_y then
				v.item:GetView():runAction(cc.MoveTo:create(Accordion.ActionTime, cc.p(0, tree_offset_y)))
			end
		else
			v.item:SetPosition(0, tree_offset_y)
		end

		tree_offset_y = tree_offset_y - v.item:GetHeight()

		-- 展开子节点
		if self.cur_tree_index == v.item:GetIndex() then
			v.item:GetChildView():setVisible(true)

			v.item:GetChildView():stopAllActions()
			if is_tween then
				v.item:GetChildView():setScaleY(0)
				v.item:GetChildView():runAction(cc.ScaleTo:create(Accordion.ActionTime, 1))
			end

			tree_offset_y = tree_offset_y - v.item:GetChildView():getContentSize().height
		end
	end

	-- 调整scroll内部容器位置
	self.total_height = total_height
	self.view:setInnerContainerSize(cc.size(self.width, total_height))
	self.view:jumpToPosition(cc.p(0, new_inner_y))

	if nil ~= cur_tree_item then
		-- 将展开节点移动到视口中
		local tree_y_top = cur_tree_item:GetTargetY()
		local tree_y_bottom = tree_y_top - cur_tree_item:GetHeight() - cur_tree_item:GetChildView():getContentSize().height

		local is_change = false
		if tree_y_bottom + new_inner_y < 0 then
			is_change = true
			new_inner_y = -tree_y_bottom
		end
		if tree_y_top + new_inner_y > self.height then
			is_change = true
			new_inner_y = math.min(self.height - tree_y_top, 0)
		end

		if is_change then
			if is_tween then
				self.view:scrollToPosition(cc.p(0, new_inner_y), Accordion.ActionTime, false)
			else
				self.view:jumpToPosition(cc.p(0, new_inner_y))
			end
		end
	end
end

function Accordion:SetSpaceInterval(interval)
	self.interval = interval
	if nil == interval or nil == next(self.items) then return end
	for k, v in ipairs(self.items) do
		local tree_node = v.item
		local childs_height = 0
		for k2, v2 in ipairs(v.childs) do
			childs_height = childs_height + v2:GetHeight() + interval
		end
		tree_node:GetChildView():setContentWH(self.width, childs_height)
		local child_offset_y = childs_height - interval * 0.5
		for k2, v2 in ipairs(v.childs) do
			v2:SetPosition(self.width * 0.5, child_offset_y)
			v2:SetTargetY(child_offset_y)
			child_offset_y = child_offset_y - v2:GetHeight() - interval
		end
	end
end

-- 当前展开第几个，树节点index
function Accordion:GetExpandIndex()
	return self.cur_tree_index
end

-- 获得当前选中的子节点index
function Accordion:GetSelectChildIndex()
	return self.select_child_index
end

--设置当前选中子节点
function Accordion:SetCurSelectChildIndex(index)
	self.select_child_index = index
	self:SetSelectChildIndex(self.select_child_index, self.cur_tree_index, false)
end

-- 获得当前展开的树节点
function Accordion:GetCurTreeNode()
	return self.items[self.cur_tree_index] and self.items[self.cur_tree_index].item
end

function Accordion:GetTreeNodeByTreeIndex( tree_index)
	return self.items[tree_index] and self.items[tree_index].item
end

-- 获得当前选择的子节点
function Accordion:GetCurChidNode()
	return self.items[self.cur_tree_index] and self.items[self.cur_tree_index].childs[self.select_child_index]
end

function Accordion:GetChidNodeByIndex(tree_index, child_index)
	return self.items[tree_index] and self.items[tree_index].childs[child_index]
end

-- 设置展开内容支持弹跳
function Accordion:SetBounce(is_bounce)
	if nil ~= self.view then
		self.view:setBounceEnabled(is_bounce)
	end
end

--删除所有
function Accordion:RemoveAll()
	self.cur_tree_index = 0
	self.data = {}

	for k, v in pairs(self.items) do
		for k2, v2 in pairs(v.childs) do
			v2:DeleteMe()
		end
		v.item:DeleteMe()
	end
	self.items = {}

	self.view:removeAllChildren()
end

-- 设置展开树节点回调
function Accordion:SetExpandCallBack(expand_callback)
	self.expand_callback = expand_callback
end

-- 设置折叠树节点回调
function Accordion:SetUnExpandCallBack(unexpand_callback)
	self.unexpand_callback = unexpand_callback
end

-- 设置选择子节点回调
function Accordion:SetSelectCallBack(select_callback)
	self.select_callback = select_callback
end

-- 设置是否是分步计算
function Accordion:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

function Accordion:SetTreeCallBack(select_tree_callback)
	self.select_tree_callback = select_tree_callback
end
-- 点击节点处理
function Accordion:OnClickItem(item)
	if not item:IsChild() then
		if item:GetIndex() == self.cur_tree_index then
			self:SetExpandByIndex(0, self.is_tween)
		else
			self:SetExpandByIndex(item:GetIndex(), self.is_tween)
		end
		if self.select_tree_callback  then
			self.select_tree_callback(item)
		end
	else
		self:SetSelectChildIndex(item:GetIndex(), self.cur_tree_index, self.is_tween)
	end
end

-----------------------------------------------------
--手风琴ItemRender
-----------------------------------------------------
AccordionItemRender = AccordionItemRender or BaseClass(BaseRender)
function AccordionItemRender:__init(w, h)
	self.width = w
	self.height = h
	self.target_y = 0
	self.children_list = {}		-- 保存自身子节点列表
	self.child_view = nil
end

function AccordionItemRender:__delete()
end

function AccordionItemRender:GetHeight()
	return self.height
end

function AccordionItemRender:SetTargetY(y)
	self.target_y = y
end

function AccordionItemRender:GetTargetY()
	return self.target_y
end

function AccordionItemRender:IsChild()
	return nil == self.child_view
end

function AccordionItemRender:GetChildView()
	return self.child_view
end

function AccordionItemRender:CreateChildView()
	if nil == self.child_view then
		self.child_view = XLayout:create(0, 0)
		self.child_view:setAnchorPoint(0, 1)
		self.view:addChild(self.child_view, -1)
	end
end

function AccordionItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self.view:setContentWH(self.width, self.height)
end

function AccordionItemRender:CreateSelectEffect()
	if self:IsChild() then
		local size = self.view:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 16, size.height + 8, ResPath.GetCommon("cell_select_bg"), true)
		self.view:addChild(self.select_effect, 200, 200)
	end
end


function AccordionItemRender:CleardChildrenList()
	self.children_list = {}
end

function AccordionItemRender:GetChildrenList()
	return self.children_list
end

function AccordionItemRender:IsHaveChildren()
	return nil ~= next(self.children_list)
end

function AccordionItemRender:GetSelectedChild()
	return self.children_list[self.cur_selected_child_index]
end

function AccordionItemRender:GetChildNodeByIndex(index)
	return self.children_list[index]
end

function AccordionItemRender:PushBackChildNode(child_node)
	if child_node then
		self.children_list[#self.children_list + 1] = child_node
	end
end